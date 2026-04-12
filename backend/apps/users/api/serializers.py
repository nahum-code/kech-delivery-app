from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer, TokenRefreshSerializer
from rest_framework_simplejwt.tokens import RefreshToken

from apps.drivers.models import DriverProfile
from apps.users.auth_policy import assert_jwt_eligible
from apps.users.models import CustomerProfile
from apps.users.phone_utils import normalize_phone
from core.models import User

_ENUM = "Invalid credentials."


class PhoneTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    JWT login serializer for the custom phone-based user model.

    Returns access + refresh; adds role and user_id to the response body.
    """

    def validate_phone(self, value: str) -> str:
        return normalize_phone(value)

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        assert_jwt_eligible(self.user)
        data["role"] = str(self.user.role)
        data["user_id"] = self.user.id
        return data


class RestrictedTokenRefreshSerializer(TokenRefreshSerializer):
    """Refresh access tokens only if the user still satisfies login policy."""

    def validate(self, attrs):
        try:
            refresh = RefreshToken(attrs["refresh"])
            user = User.objects.get(pk=refresh["user_id"])
        except (User.DoesNotExist, TokenError, KeyError) as exc:
            raise ValidationError(_ENUM) from exc

        assert_jwt_eligible(user)
        return super().validate(attrs)


class CustomerRegisterSerializer(serializers.Serializer):
    """Register a customer user + create CustomerProfile."""

    phone = serializers.CharField(max_length=32)
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(max_length=150)

    def validate_phone(self, value: str) -> str:
        return normalize_phone(value)

    def validate_password(self, value: str) -> str:
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise ValidationError(_ENUM) from e
        return value

    def create(self, validated_data):
        phone = validated_data["phone"]
        password = validated_data["password"]
        name = validated_data["name"]

        with transaction.atomic():
            if User.objects.filter(phone=phone).exists():
                raise ValidationError(_ENUM)

            user = User.objects.create_user(phone=phone, password=password, role=User.Role.CUSTOMER)
            CustomerProfile.objects.create(user=user, full_name=name)
            return user


class DriverRegisterSerializer(serializers.Serializer):
    """Register a driver user + create DriverProfile with approval_status=pending."""

    phone = serializers.CharField(max_length=32)
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(max_length=150)

    def validate_phone(self, value: str) -> str:
        return normalize_phone(value)

    def validate_password(self, value: str) -> str:
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise ValidationError(_ENUM) from e
        return value

    def create(self, validated_data):
        phone = validated_data["phone"]
        password = validated_data["password"]
        name = validated_data["name"]

        with transaction.atomic():
            if User.objects.filter(phone=phone).exists():
                raise ValidationError(_ENUM)

            user = User.objects.create_user(phone=phone, password=password, role=User.Role.DRIVER)
            DriverProfile.objects.create(user=user, full_name=name, approval_status=DriverProfile.ApprovalStatus.PENDING)
            return user


class MeSerializer(serializers.ModelSerializer):
    """Current user + role-specific profile snippet for /auth/me."""

    profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ("id", "phone", "role", "is_active", "created_at", "profile")
        read_only_fields = fields

    def get_profile(self, obj: User) -> dict:
        if obj.role == User.Role.CUSTOMER:
            try:
                cp = obj.customer_profile
            except CustomerProfile.DoesNotExist:
                return {"type": "customer", "full_name": None}
            return {"type": "customer", "full_name": cp.full_name}

        if obj.role == User.Role.DRIVER:
            try:
                dp = obj.driver_profile
            except DriverProfile.DoesNotExist:
                return {"type": "driver", "full_name": None, "approval_status": None}
            return {
                "type": "driver",
                "full_name": dp.full_name,
                "approval_status": dp.approval_status,
            }

        return {"type": str(obj.role)}
