from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models


class DriverProfile(models.Model):
    """
    Driver-specific operational profile.

    Authentication remains in a single User model. This table stores
    role-specific fields for users with role=driver.
    """

    class ApprovalStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        APPROVED = "approved", "Approved"
        REJECTED = "rejected", "Rejected"
        SUSPENDED = "suspended", "Suspended"

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="driver_profile",
    )
    full_name = models.CharField(max_length=150, blank=True)
    approval_status = models.CharField(
        max_length=20,
        choices=ApprovalStatus.choices,
        default=ApprovalStatus.PENDING,
        db_index=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def clean(self):
        # Protect data consistency: driver profile should only belong to driver role.
        if self.user and getattr(self.user, "role", None) != "driver":
            raise ValidationError("DriverProfile can only be attached to a driver user.")

    def save(self, *args, **kwargs):
        self.full_clean()
        return super().save(*args, **kwargs)

    def __str__(self) -> str:
        return f"DriverProfile<{self.user}> [{self.approval_status}]"
