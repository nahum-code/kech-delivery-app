from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import transaction
from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from apps.drivers.models import DriverProfile
from apps.users.models import CustomerProfile
from core.models import User


class PhoneTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    JWT login serializer for the custom phone-based user model.

    Extensible point: add more claims (permissions, tenant, etc.) here later
    without changing auth endpoint contracts.
    """

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        return token


class CustomerRegisterSerializer(serializers.Serializer):
    """
    Register a customer user + create CustomerProfile.
    """

    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(max_length=150)

    def validate_password(self, value: str) -> str:
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise ValidationError(list(e.messages))
        return value

    def create(self, validated_data):
        phone = validated_data["phone"]
        password = validated_data["password"]
        name = validated_data["name"]

        with transaction.atomic():
            if User.objects.filter(phone=phone).exists():
                raise ValidationError({"phone": "A user with this phone already exists."})

            user = User.objects.create_user(phone=phone, password=password, role=User.Role.CUSTOMER)
            CustomerProfile.objects.create(user=user, full_name=name)
            return user


class DriverRegisterSerializer(serializers.Serializer):
    """
    Register a driver user + create DriverProfile with approval_status=pending.
    """

    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(max_length=150)

    def validate_password(self, value: str) -> str:
        try:
            validate_password(value)
        except DjangoValidationError as e:
            raise ValidationError(list(e.messages))
        return value

    def create(self, validated_data):
        phone = validated_data["phone"]
        password = validated_data["password"]
        name = validated_data["name"]

        with transaction.atomic():
            if User.objects.filter(phone=phone).exists():
                raise ValidationError({"phone": "A user with this phone already exists."})

            user = User.objects.create_user(phone=phone, password=password, role=User.Role.DRIVER)
            DriverProfile.objects.create(user=user, full_name=name, approval_status=DriverProfile.ApprovalStatus.PENDING)
            return user


class LoginSerializer(serializers.Serializer):
    """
    Login serializer for phone + password.
    """

    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        phone = attrs.get("phone")
        password = attrs.get("password")

        try:
            user = User.objects.get(phone=phone)
        except User.DoesNotExist:
            raise ValidationError("Invalid phone or password.")

        if not user.check_password(password):
            raise ValidationError("Invalid phone or password.")

        if not user.is_active:
            raise ValidationError("This account is inactive.")

        attrs["user"] = user
        return attrs
