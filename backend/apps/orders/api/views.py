from __future__ import annotations

from django.db.models import Count, Q
from rest_framework import status
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.orders.api.serializers import (
    AssignDriverSerializer,
    OrderCreateSerializer,
    OrderDetailSerializer,
    OrderListSerializer,
    OrderStatusUpdateSerializer,
    SalesOrderCreateSerializer,
)
from apps.orders.models import Order
from apps.orders.permissions import (
    CanAssignDriver,
    CanCreateCustomerOrder,
    CanCreateSalesOrder,
    CanListStaffOrders,
    CanUpdateOrderStatus,
    CanViewDriverOrders,
    IsOrderAssignedDriver,
    IsOrderCustomer,
    IsSalesOrAdmin,
)
from apps.orders.services.assignment import assign_driver_to_order
from apps.orders.services.order import OrderServiceError, create_order, transition_order_status
from core.models import User


class OrderPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = "page_size"
    max_page_size = 100


def _order_queryset():
    return (
        Order.objects.select_related(
            "customer",
            "customer__customer_profile",
            "restaurant",
            "assigned_driver",
            "assigned_driver__driver_profile",
            "sales_agent",
        )
        .prefetch_related("items__menu_item")
        .annotate(item_count=Count("items", distinct=True))
    )


def _filter_orders(qs, request):
    status_param = request.query_params.get("status")
    if status_param:
        qs = qs.filter(status=status_param)
    search = (request.query_params.get("search") or "").strip()
    if search:
        qs = qs.filter(
            Q(reference__icontains=search)
            | Q(customer__phone__icontains=search)
            | Q(restaurant__name__icontains=search)
        )
    restaurant_id = request.query_params.get("restaurant_id")
    if restaurant_id:
        qs = qs.filter(restaurant_id=restaurant_id)
    assigned = request.query_params.get("assigned")
    if assigned == "false":
        qs = qs.filter(assigned_driver__isnull=True)
    elif assigned == "true":
        qs = qs.filter(assigned_driver__isnull=False)
    return qs


class OrderListCreateView(APIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), CanListStaffOrders()]
        user = getattr(self.request, "user", None)
        if user and user.is_authenticated and user.role == User.Role.SALES:
            return [IsAuthenticated(), CanCreateSalesOrder()]
        return [IsAuthenticated(), CanCreateCustomerOrder()]

    def get(self, request, *args, **kwargs):
        qs = _filter_orders(_order_queryset(), request)
        paginator = OrderPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = OrderListSerializer(page, many=True, context={"request": request})
        return paginator.get_paginated_response(serializer.data)

    def post(self, request, *args, **kwargs):
        if request.user.role == User.Role.SALES:
            body = SalesOrderCreateSerializer(data=request.data)
            body.is_valid(raise_exception=True)
            data = body.validated_data
            try:
                customer = User.objects.get(pk=data["customer_id"], role=User.Role.CUSTOMER)
            except User.DoesNotExist:
                return Response({"detail": "Customer not found."}, status=status.HTTP_404_NOT_FOUND)
            try:
                order = create_order(
                    customer=customer,
                    restaurant_id=data["restaurant_id"],
                    items=data["items"],
                    delivery_address=data["delivery_address"],
                    customer_note=data.get("customer_note", ""),
                    sales_agent=request.user,
                    delivery_fee=data.get("delivery_fee"),
                )
            except OrderServiceError as exc:
                return Response({"detail": exc.message}, status=exc.status_code)
        else:
            body = OrderCreateSerializer(data=request.data)
            body.is_valid(raise_exception=True)
            data = body.validated_data
            try:
                order = create_order(
                    customer=request.user,
                    restaurant_id=data["restaurant_id"],
                    items=data["items"],
                    delivery_address=data["delivery_address"],
                    customer_note=data.get("customer_note", ""),
                    delivery_fee=data.get("delivery_fee"),
                )
            except OrderServiceError as exc:
                return Response({"detail": exc.message}, status=exc.status_code)

        order = _order_queryset().get(pk=order.pk)
        return Response(
            OrderDetailSerializer(order, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


class MyOrdersListView(APIView):
    permission_classes = [IsAuthenticated, CanCreateCustomerOrder]

    def get(self, request, *args, **kwargs):
        qs = _filter_orders(_order_queryset().filter(customer=request.user), request)
        paginator = OrderPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = OrderListSerializer(page, many=True, context={"request": request})
        return paginator.get_paginated_response(serializer.data)


class OrderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, request, order_id: int) -> Order | None:
        try:
            order = _order_queryset().get(pk=order_id)
        except Order.DoesNotExist:
            return None

        user = request.user
        if user.role in (User.Role.ADMIN, User.Role.SALES):
            return order
        if user.role == User.Role.CUSTOMER and order.customer_id == user.pk:
            return order
        if user.role == User.Role.DRIVER and order.assigned_driver_id == user.pk:
            return order
        return None

    def get(self, request, order_id: int, *args, **kwargs):
        order = self.get_object(request, order_id)
        if order is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(OrderDetailSerializer(order, context={"request": request}).data)


class OrderStatusUpdateView(APIView):
    permission_classes = [IsAuthenticated, CanUpdateOrderStatus]

    def patch(self, request, order_id: int, *args, **kwargs):
        try:
            order = Order.objects.get(pk=order_id)
        except Order.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

        body = OrderStatusUpdateSerializer(data=request.data)
        body.is_valid(raise_exception=True)
        try:
            order = transition_order_status(order, body.validated_data["status"])
        except OrderServiceError as exc:
            return Response({"detail": exc.message}, status=exc.status_code)

        order = _order_queryset().get(pk=order.pk)
        return Response(OrderDetailSerializer(order, context={"request": request}).data)


class AssignDriverView(APIView):
    permission_classes = [IsAuthenticated, CanAssignDriver]

    def post(self, request, order_id: int, *args, **kwargs):
        try:
            order = Order.objects.get(pk=order_id)
        except Order.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)

        body = AssignDriverSerializer(data=request.data)
        body.is_valid(raise_exception=True)
        try:
            driver = User.objects.get(pk=body.validated_data["driver_id"], role=User.Role.DRIVER)
        except User.DoesNotExist:
            return Response({"detail": "Driver not found."}, status=status.HTTP_404_NOT_FOUND)

        try:
            order = assign_driver_to_order(order=order, driver=driver, assigned_by=request.user)
        except OrderServiceError as exc:
            return Response({"detail": exc.message}, status=exc.status_code)

        order = _order_queryset().get(pk=order.pk)
        return Response(OrderDetailSerializer(order, context={"request": request}).data)


class DriverOrdersListView(APIView):
    permission_classes = [IsAuthenticated, CanViewDriverOrders]

    def get(self, request, *args, **kwargs):
        qs = _filter_orders(
            _order_queryset().filter(assigned_driver=request.user),
            request,
        )
        paginator = OrderPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = OrderListSerializer(page, many=True, context={"request": request})
        return paginator.get_paginated_response(serializer.data)
