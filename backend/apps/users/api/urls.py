from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

from .views import (
    CustomerRegisterView,
    DriverRegisterView,
    LoginView,
    PhoneTokenObtainPairView,
    test_auth,
)

urlpatterns = [
    # Login: returns access + refresh token pair.
    path("token/", PhoneTokenObtainPairView.as_view(), name="token_obtain_pair"),
    # Refresh: exchange refresh token for a new access token.
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    # Verify: validate token integrity/expiry.
    path("token/verify/", TokenVerifyView.as_view(), name="token_verify"),

    # Registration endpoints (MVP).
    path(
        "register/customer",
        CustomerRegisterView.as_view(),
        name="register_customer",
    ),
    path(
        "register/driver",
        DriverRegisterView.as_view(),
        name="register_driver",
    ),

    # Login endpoint returning access token + role + user_id.
    path("login", LoginView.as_view(), name="login"),
    path("test-auth", test_auth, name="test_auth"),
]
