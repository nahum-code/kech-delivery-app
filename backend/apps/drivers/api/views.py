from __future__ import annotations

from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.drivers.models import DriverProfile
from apps.drivers.services.approval import (
    DriverApprovalError,
    approve_driver,
    reject_driver,
    suspend_driver,
)
from apps.users.permissions import IsAdminUserRole, IsDriver, IsPlatformStaff

from .serializers import (
    DriverActionResponseSerializer,
    DriverStatusSerializer,
    PendingDriverSerializer,
    RejectDriverSerializer,
    SuspendDriverSerializer,
)


def _action_response(profile: DriverProfile, message: str) -> Response:
    payload = {
        "message": message,
        "driver_id": profile.user_id,
        "approval_status": profile.approval_status,
    }
    serializer = DriverActionResponseSerializer(payload)
    return Response(serializer.data, status=status.HTTP_200_OK)


class ApprovedDriversListView(APIView):
    """GET /api/v1/admin/drivers/approved/ — sales + admin (assignment UI)."""

    permission_classes = [IsAuthenticated, IsPlatformStaff]

    def get(self, request, *args, **kwargs):
        queryset = (
            DriverProfile.objects.filter(approval_status=DriverProfile.ApprovalStatus.APPROVED)
            .select_related("user")
            .filter(user__is_active=True)
        )
        if request.query_params.get("all") != "true":
            queryset = queryset.filter(operational_status=DriverProfile.OperationalStatus.ONLINE)
        queryset = queryset.order_by("full_name")
        data = [
            {
                "id": p.user_id,
                "full_name": p.full_name or p.user.phone,
                "phone": p.user.phone,
                "vehicle_type": p.vehicle_type,
                "operational_status": p.operational_status,
            }
            for p in queryset
        ]
        return Response(data)


class PendingDriversListView(APIView):
    """GET /api/v1/admin/drivers/pending/ — admin only."""

    permission_classes = [IsAuthenticated, IsAdminUserRole]

    def get(self, request, *args, **kwargs):
        queryset = (
            DriverProfile.objects.filter(approval_status=DriverProfile.ApprovalStatus.PENDING)
            .select_related("user")
            .order_by("-created_at")
        )
        serializer = PendingDriverSerializer(queryset, many=True)
        return Response(serializer.data)


class ApproveDriverView(APIView):
    """POST /api/v1/admin/drivers/{id}/approve/ — id is user_id."""

    permission_classes = [IsAuthenticated, IsAdminUserRole]

    def post(self, request, user_id: int, *args, **kwargs):
        try:
            profile = approve_driver(user_id=user_id, admin=request.user)
        except DriverApprovalError as exc:
            return Response({"detail": exc.message}, status=exc.status_code)

        return _action_response(profile, "Driver approved successfully.")


class RejectDriverView(APIView):
    """POST /api/v1/admin/drivers/{id}/reject/"""

    permission_classes = [IsAuthenticated, IsAdminUserRole]

    def post(self, request, user_id: int, *args, **kwargs):
        body = RejectDriverSerializer(data=request.data)
        body.is_valid(raise_exception=True)

        try:
            profile = reject_driver(
                user_id=user_id,
                admin=request.user,
                rejection_reason=body.validated_data["rejection_reason"],
            )
        except DriverApprovalError as exc:
            return Response({"detail": exc.message}, status=exc.status_code)

        return _action_response(profile, "Driver rejected successfully.")


class SuspendDriverView(APIView):
    """POST /api/v1/admin/drivers/{id}/suspend/"""

    permission_classes = [IsAuthenticated, IsAdminUserRole]

    def post(self, request, user_id: int, *args, **kwargs):
        body = SuspendDriverSerializer(data=request.data)
        body.is_valid(raise_exception=True)

        try:
            profile = suspend_driver(
                user_id=user_id,
                admin=request.user,
                suspension_reason=body.validated_data["suspension_reason"],
            )
        except DriverApprovalError as exc:
            return Response({"detail": exc.message}, status=exc.status_code)

        return _action_response(profile, "Driver suspended successfully.")


class DriverStatusView(APIView):
    """
    GET /api/v1/drivers/me/status/

    Authenticated driver only; returns this user's approval state for mobile onboarding UX.
    Uses IsDriver (not IsApprovedDriver) so the contract is stable when limited sessions exist.
    """

    permission_classes = [IsAuthenticated, IsDriver]

    def get(self, request, *args, **kwargs):
        try:
            profile = request.user.driver_profile
        except DriverProfile.DoesNotExist:
            return Response(
                {"detail": "Driver profile not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = DriverStatusSerializer(profile)
        return Response(serializer.data)
