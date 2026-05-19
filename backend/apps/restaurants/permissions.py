"""Catalog RBAC: admin writes, sales reads, customers public read (active only enforced in queryset)."""

from __future__ import annotations

from rest_framework.permissions import BasePermission, SAFE_METHODS

from apps.users.permissions import HasAnyUserRole, IsAdminUserRole
from core.models import User


class IsRestaurantAdmin(HasAnyUserRole):
    """Admin-only restaurant/menu mutations."""

    allowed_roles = (User.Role.ADMIN,)


class IsRestaurantStaffRead(HasAnyUserRole):
    """Admin + sales can list all restaurants (including inactive)."""

    allowed_roles = (User.Role.ADMIN, User.Role.SALES)


class IsRestaurantCustomerOrPublic(BasePermission):
    """
    Safe reads for catalog: unauthenticated customers, customers, and staff.
    Write operations must use IsRestaurantAdmin on the view.
    """

    def has_permission(self, request, view) -> bool:
        if request.method in SAFE_METHODS:
            return True
        return False
