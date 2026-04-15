from django.conf import settings
from django.urls import path

from .views import (
    AdminUsersListView,
    CreateSalesAgentView,
    CustomerRegisterView,
    DriverRegisterView,
    LogoutView,
    MeView,
    PhoneTokenObtainPairView,
    RestrictedTokenRefreshView,
    StaffOpsCheckView,
    ThrottledTokenVerifyView,
    test_auth,
)

urlpatterns = [
    path("token/", PhoneTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", RestrictedTokenRefreshView.as_view(), name="token_refresh"),
    path("token/verify/", ThrottledTokenVerifyView.as_view(), name="token_verify"),
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
    path(
        "create-sales-agent/",
        CreateSalesAgentView.as_view(),
        name="create_sales_agent",
    ),
    path(
        "users/",
        AdminUsersListView.as_view(),
        name="admin_users_list",
    ),
    path("logout", LogoutView.as_view(), name="logout"),
    path("me", MeView.as_view(), name="me"),
    path("staff/ops-check", StaffOpsCheckView.as_view(), name="staff_ops_check"),
]

if settings.DEBUG:
    urlpatterns.append(path("test-auth", test_auth, name="test_auth"))
