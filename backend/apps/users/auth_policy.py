"""
Central rules for whether a user may receive JWTs (token pair, refresh).

Uses a single client-facing error message to reduce account enumeration.
"""

from __future__ import annotations

from rest_framework.exceptions import ValidationError

from apps.drivers.models import DriverProfile
from core.models import User

_CLIENT_MSG = "Invalid credentials."


def assert_jwt_eligible(user: User) -> None:
    """
    Raise ValidationError if this user must not be issued or refreshed tokens.

    Drivers must be approved; other roles only require an active account.
    All failures use the same message (anti-enumeration).
    """
    if not user.is_active:
        raise ValidationError(_CLIENT_MSG)

    if user.role != User.Role.DRIVER:
        return

    try:
        profile = user.driver_profile
    except DriverProfile.DoesNotExist:
        raise ValidationError(_CLIENT_MSG)

    if profile.approval_status == DriverProfile.ApprovalStatus.APPROVED:
        return

    raise ValidationError(_CLIENT_MSG)
