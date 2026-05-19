"""Order lifecycle and creation (business rules outside views)."""

from __future__ import annotations

from decimal import Decimal
from typing import Any

from django.db import transaction
from django.utils import timezone

from apps.orders.models import Order, OrderItem
from apps.restaurants.models import MenuItem, Restaurant
from core.models import User

DEFAULT_DELIVERY_FEE = Decimal("25.00")
MAX_ACTIVE_DRIVER_ORDERS = 5

ALLOWED_STATUS_TRANSITIONS: dict[str, set[str]] = {
    Order.Status.PENDING: {Order.Status.CONFIRMED, Order.Status.CANCELLED},
    Order.Status.CONFIRMED: {Order.Status.PREPARING, Order.Status.CANCELLED},
    Order.Status.PREPARING: {Order.Status.READY_FOR_PICKUP, Order.Status.CANCELLED},
    Order.Status.READY_FOR_PICKUP: {Order.Status.ASSIGNED, Order.Status.CANCELLED},
    Order.Status.ASSIGNED: {Order.Status.PICKED_UP, Order.Status.CANCELLED},
    Order.Status.PICKED_UP: {Order.Status.DELIVERING, Order.Status.CANCELLED},
    Order.Status.DELIVERING: {Order.Status.DELIVERED},
    Order.Status.DELIVERED: set(),
    Order.Status.CANCELLED: set(),
}


class OrderServiceError(Exception):
    def __init__(self, message: str, *, status_code: int = 400) -> None:
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def _generate_reference(order_id: int) -> str:
    return f"KD-{order_id:04d}"


def _validate_delivery_address(address: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(address, dict):
        raise OrderServiceError("delivery_address must be an object.")
    receiver = (address.get("receiver_name") or "").strip()
    phone = (address.get("phone") or "").strip()
    line = (address.get("address_line") or "").strip()
    if not receiver:
        raise OrderServiceError("Receiver name is required.")
    if not phone or len(phone) < 8:
        raise OrderServiceError("A valid delivery phone is required.")
    if not line:
        raise OrderServiceError("Delivery address line is required.")
    return {
        "receiver_name": receiver,
        "phone": phone,
        "address_line": line,
        "landmark": (address.get("landmark") or "").strip(),
    }


@transaction.atomic
def create_order(
    *,
    customer: User,
    restaurant_id: int,
    items: list[dict[str, Any]],
    delivery_address: dict[str, Any],
    customer_note: str = "",
    sales_agent: User | None = None,
    delivery_fee: Decimal | None = None,
) -> Order:
    if customer.role != User.Role.CUSTOMER:
        raise OrderServiceError("Orders must be placed for a customer account.", status_code=403)

    try:
        restaurant = Restaurant.objects.get(pk=restaurant_id, is_active=True)
    except Restaurant.DoesNotExist as exc:
        raise OrderServiceError("Restaurant not found or inactive.", status_code=404) from exc

    if not items:
        raise OrderServiceError("At least one menu item is required.")

    validated_address = _validate_delivery_address(delivery_address)
    fee = delivery_fee if delivery_fee is not None else DEFAULT_DELIVERY_FEE
    if fee < 0:
        raise OrderServiceError("delivery_fee cannot be negative.")

    order = Order.objects.create(
        reference="KD-PENDING",
        customer=customer,
        restaurant=restaurant,
        sales_agent=sales_agent if sales_agent and sales_agent.role == User.Role.SALES else None,
        status=Order.Status.PENDING,
        delivery_address=validated_address,
        customer_note=(customer_note or "").strip(),
        delivery_fee=fee,
    )
    order.reference = _generate_reference(order.pk)
    order.save(update_fields=["reference"])

    subtotal = Decimal("0.00")
    for line in items:
        menu_item_id = line.get("menu_item_id")
        quantity = int(line.get("quantity") or 0)
        if quantity < 1:
            raise OrderServiceError("Item quantity must be at least 1.")
        try:
            menu_item = MenuItem.objects.select_related("category").get(
                pk=menu_item_id,
                restaurant=restaurant,
                is_available=True,
                category__is_active=True,
            )
        except MenuItem.DoesNotExist as exc:
            raise OrderServiceError(f"Menu item {menu_item_id} is unavailable.", status_code=400) from exc

        unit = menu_item.price
        line_total = unit * quantity
        subtotal += line_total
        OrderItem.objects.create(
            order=order,
            menu_item=menu_item,
            item_name=menu_item.name,
            quantity=quantity,
            unit_price=unit,
            total_price=line_total,
        )

    order.subtotal = subtotal
    order.total_amount = subtotal + fee
    order.save(update_fields=["subtotal", "total_amount", "updated_at"])
    return order


@transaction.atomic
def transition_order_status(order: Order, new_status: str) -> Order:
    if order.is_terminal:
        raise OrderServiceError("Delivered or cancelled orders cannot be modified.", status_code=409)

    allowed = ALLOWED_STATUS_TRANSITIONS.get(order.status, set())
    if new_status not in allowed:
        raise OrderServiceError(
            f"Cannot transition from {order.status} to {new_status}.",
            status_code=409,
        )

    order.status = new_status
    order.updated_at = timezone.now()
    order.save(update_fields=["status", "updated_at"])
    return order
