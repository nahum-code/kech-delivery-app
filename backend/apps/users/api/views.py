from rest_framework import permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

from apps.users import auth_logging
from apps.users.permissions import IsAdminOrSales

from .serializers import (
    CustomerRegisterSerializer,
    DriverRegisterSerializer,
    MeSerializer,
    PhoneTokenObtainPairSerializer,
    RestrictedTokenRefreshSerializer,
)


class PhoneTokenObtainPairView(TokenObtainPairView):
    """
    Single login entrypoint: POST returns access + refresh + user_id + role.

    Use this instead of a separate access-only login route.
    """

    serializer_class = PhoneTokenObtainPairSerializer
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_token"

    def post(self, request, *args, **kwargs):
        phone = request.data.get("phone") if isinstance(request.data, dict) else None
        response = super().post(request, *args, **kwargs)
        if response.status_code == status.HTTP_200_OK:
            auth_logging.log_token_success(phone)
        return response


class RestrictedTokenRefreshView(TokenRefreshView):
    serializer_class = RestrictedTokenRefreshSerializer
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_refresh"

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code in (status.HTTP_400_BAD_REQUEST, status.HTTP_401_UNAUTHORIZED):
            auth_logging.log_token_failure(None, response.status_code)
            response.data = {"detail": "Invalid credentials."}
        return response


class ThrottledTokenVerifyView(TokenVerifyView):
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_verify"

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code in (status.HTTP_400_BAD_REQUEST, status.HTTP_401_UNAUTHORIZED):
            auth_logging.log_token_failure(None, response.status_code)
            response.data = {"detail": "Invalid credentials."}
        return response


class CustomerRegisterView(APIView):
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_register"

    def post(self, request, *args, **kwargs):
        serializer = CustomerRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        auth_logging.log_register_success(user.id, str(user.role))

        return Response(
            {
                "user_id": user.id,
                "role": str(user.role),
            },
            status=status.HTTP_201_CREATED,
        )


class DriverRegisterView(APIView):
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_register"

    def post(self, request, *args, **kwargs):
        serializer = DriverRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        driver_profile = user.driver_profile
        auth_logging.log_register_success(user.id, str(user.role))

        return Response(
            {
                "id": user.id,
                "phone": user.phone,
                "role": str(user.role),
                "approval_status": driver_profile.approval_status,
            },
            status=status.HTTP_201_CREATED,
        )


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        return Response(MeSerializer(request.user).data)


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_logout"

    def post(self, request, *args, **kwargs):
        raw = request.data.get("refresh")
        if not raw or not isinstance(raw, str):
            return Response({"detail": "Field 'refresh' is required."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            token = RefreshToken(raw)
            token.blacklist()
        except TokenError:
            pass
        auth_logging.log_logout(request.user.id)
        return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def test_auth(request):
    return Response(
        {
            "message": "Authenticated",
            "user_id": request.user.id,
            "role": request.user.role,
        }
    )


class StaffOpsCheckView(APIView):
    permission_classes = [IsAuthenticated, IsAdminOrSales]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "auth_staff"

    def get(self, request, *args, **kwargs):
        return Response(
            {
                "ok": True,
                "user_id": request.user.id,
                "role": request.user.role,
            }
        )
