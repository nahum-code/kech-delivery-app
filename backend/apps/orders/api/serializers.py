from __future__ import annotations

from rest_framework import serializers

from apps.orders.models import Order, OrderItem
from core.models import User


class DeliveryAddressSerializer(serializers.Serializer):
    receiver_name = serializers.CharField(max_length=150)
    phone = serializers.CharField(max_length=32)
    address_line = serializers.CharField(max_length=500)
    landmark = serializers.CharField(max_length=255, required=False, allow_blank=True, default="")


class OrderItemInputSerializer(serializers.Serializer):
    menu_item_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1)


class OrderCreateSerializer(serializers.Serializer):
    restaurant_id = serializers.IntegerField()
    items = OrderItemInputSerializer(many=True)
    delivery_address = DeliveryAddressSerializer()
    customer_note = serializers.CharField(required=False, allow_blank=True, default="")
    delivery_fee = serializers.DecimalField(max_digits=10, decimal_places=2, required=False)


class SalesOrderCreateSerializer(OrderCreateSerializer):
    customer_id = serializers.IntegerField()


class OrderItemSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = OrderItem
        fields = (
            "id",
            "menu_item",
            "item_name",
            "quantity",
            "unit_price",
            "total_price",
            "image_url",
        )

    def get_image_url(self, obj: OrderItem) -> str | None:
        request = self.context.get("request")
        image = getattr(obj.menu_item, "image", None)
        if not image:
            return None
        url = image.url
        if request:
            return request.build_absolute_uri(url)
        return url


class OrderListSerializer(serializers.ModelSerializer):
    restaurant_name = serializers.CharField(source="restaurant.name", read_only=True)
    customer_phone = serializers.CharField(source="customer.phone", read_only=True)
    customer_name = serializers.SerializerMethodField()
    assigned_driver_name = serializers.SerializerMethodField()
    item_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Order
        fields = (
            "id",
            "reference",
            "restaurant",
            "restaurant_name",
            "customer_phone",
            "customer_name",
            "assigned_driver",
            "assigned_driver_name",
            "status",
            "payment_status",
            "subtotal",
            "delivery_fee",
            "total_amount",
            "placed_at",
            "updated_at",
            "item_count",
        )

    def get_customer_name(self, obj: Order) -> str:
        profile = getattr(obj.customer, "customer_profile", None)
        if profile and profile.full_name:
            return profile.full_name
        return obj.customer.phone

    def get_assigned_driver_name(self, obj: Order) -> str | None:
        driver = obj.assigned_driver
        if not driver:
            return None
        profile = getattr(driver, "driver_profile", None)
        if profile and profile.full_name:
            return profile.full_name
        return driver.phone


class OrderDetailSerializer(serializers.ModelSerializer):
    restaurant_name = serializers.CharField(source="restaurant.name", read_only=True)
    restaurant_address = serializers.CharField(source="restaurant.address_text", read_only=True)
    items = OrderItemSerializer(many=True, read_only=True)
    customer_phone = serializers.CharField(source="customer.phone", read_only=True)

    class Meta:
        model = Order
        fields = (
            "id",
            "reference",
            "customer",
            "customer_phone",
            "restaurant",
            "restaurant_name",
            "restaurant_address",
            "sales_agent",
            "assigned_driver",
            "status",
            "payment_status",
            "subtotal",
            "delivery_fee",
            "total_amount",
            "delivery_address",
            "customer_note",
            "placed_at",
            "updated_at",
            "items",
        )


class OrderStatusUpdateSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=Order.Status.choices)


class AssignDriverSerializer(serializers.Serializer):
    driver_id = serializers.IntegerField()
