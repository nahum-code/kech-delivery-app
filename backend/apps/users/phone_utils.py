"""
Phone normalization for auth and storage (single canonical form per account).

Accepted format is international E.164-like: +<digits> (max 15 digits).
Examples: +251983204356, +14155552671.
"""

from __future__ import annotations

import re

from rest_framework.exceptions import ValidationError

_ENUM_MSG = "Invalid credentials."


def normalize_phone(phone: str | None) -> str:
    if phone is None or not str(phone).strip():
        raise ValidationError(_ENUM_MSG)
    value = str(phone).strip()
    if not re.fullmatch(r"\+[1-9]\d{7,14}", value):
        raise ValidationError(_ENUM_MSG)
    return value
