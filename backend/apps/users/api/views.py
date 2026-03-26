from rest_framework import permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import (
    CustomerRegisterSerializer,
    DriverRegisterSerializer,
    LoginSerializer,
)

from .serializers import PhoneTokenObtainPairSerializer


class PhoneTokenObtainPairView(TokenObtainPairView):
    """
    JWT login endpoint for phone + password authentication.
    """

    serializer_class = PhoneTokenObtainPairSerializer


class CustomerRegisterView(APIView):
    """
    Customer registration endpoint.

    POST /auth/register/customer
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = CustomerRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        return Response(
            {
                "user_id": user.id,
                "role": str(user.role),
            },
            status=status.HTTP_201_CREATED,
        )


class DriverRegisterView(APIView):
    """
    Driver registration endpoint.

    POST /auth/register/driver
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = DriverRegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        driver_profile = user.driver_profile

        return Response(
            {
                "id": user.id,
                "phone": user.phone,
                "role": str(user.role),
                "approval_status": driver_profile.approval_status,
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    """
    Phone/password login endpoint.

    POST /auth/login
    Response shape:
      {
        "token": "<access_token>",
        "role": "<role>",
        "user_id": <id>
      }
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]

        # AccessToken is enough for MVP (refresh token endpoint already exists).
        access = AccessToken.for_user(user)

        return Response(
            {
                "token": str(access),
                "role": str(user.role),
                "user_id": user.id,
            },
            status=status.HTTP_200_OK,
        )


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
