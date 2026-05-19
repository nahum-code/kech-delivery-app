"""Driver assignment rules and audit logging."""

from __future__ import annotations

from django.db import transaction
from django.utils import timezone

from apps.drivers.models import DriverProfile
from apps.orders.models import DriverAssignmentLog, Order
from apps.orders.services.order import MAX_ACTIVE_DRIVER_ORDERS, OrderServiceError
from core.models import User

ACTIVE_DRIVER_STATUSES = {
    Order.Status.ASSIGNED,
    Order.Status.PICKED_UP,
    Order.Status.DELIVERING,
}


@transaction.atomic
def assign_driver_to_order(*, order: Order, driver: User, assigned_by: User) -> Order:
    if order.is_terminal:
        raise OrderServiceError("Cannot assign driver to a completed order.", status_code=409)

    if order.status == Order.Status.CANCELLED:
        raise OrderServiceError("Cancelled orders cannot be reassigned.", status_code=409)

    if driver.role != User.Role.DRIVER:
        raise OrderServiceError("Selected user is not a driver.", status_code=400)

    try:
        profile = driver.driver_profile
    except DriverProfile.DoesNotExist as exc:
        raise OrderServiceError("Driver profile not found.", status_code=404) from exc

    if profile.approval_status != DriverProfile.ApprovalStatus.APPROVED:
        raise OrderServiceError("Only approved drivers can be assigned.", status_code=400)

    if not driver.is_active:
        raise OrderServiceError("Driver account is inactive.", status_code=400)

    active_count = Order.objects.filter(
        assigned_driver=driver,
        status__in=ACTIVE_DRIVER_STATUSES,
    ).exclude(pk=order.pk).count()

    if active_count >= MAX_ACTIVE_DRIVER_ORDERS:
        raise OrderServiceError(
            f"Driver already has {MAX_ACTIVE_DRIVER_ORDERS} active deliveries.",
            status_code=409,
        )

    order.assigned_driver = driver
    if order.status in {Order.Status.PENDING, Order.Status.CONFIRMED, Order.Status.PREPARING, Order.Status.READY_FOR_PICKUP}:
        order.status = Order.Status.ASSIGNED
    order.updated_at = timezone.now()
    order.save(update_fields=["assigned_driver", "status", "updated_at"])

    DriverAssignmentLog.objects.create(
        order=order,
        driver=driver,
        assigned_by=assigned_by,
    )
    return order
