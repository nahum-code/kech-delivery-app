"""
Phone normalization for auth and storage (single canonical form per account).

Basic rule: strip non-digits, require at least one digit, store as +<digits>.
Clients should send country code; local leading zeros are not stripped (add later if needed).
"""

from __future__ import annotations

import re

from rest_framework.exceptions import ValidationError

_ENUM_MSG = "Invalid credentials."


def normalize_phone(phone: str | None) -> str:
    if phone is None or not str(phone).strip():
        raise ValidationError(_ENUM_MSG)
    digits = re.sub(r"\D", "", str(phone))
    if not digits or len(digits) > 15:
        raise ValidationError(_ENUM_MSG)
    return f"+{digits}"
