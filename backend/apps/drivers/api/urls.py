from django.urls import path

from .onboarding_views import (
    DriverDocumentUploadView,
    DriverOnboardingStatusView,
    DriverRequiredDocumentsView,
)
from apps.orders.api.views import DriverOrdersListView

from .views import DriverStatusView

urlpatterns = [
    path("orders/", DriverOrdersListView.as_view(), name="driver_orders"),
    path("me/status/", DriverStatusView.as_view(), name="driver_me_status"),
    path("onboarding/status/", DriverOnboardingStatusView.as_view(), name="driver_onboarding_status"),
    path("onboarding/documents/", DriverDocumentUploadView.as_view(), name="driver_onboarding_documents"),
    path(
        "onboarding/documents/required/",
        DriverRequiredDocumentsView.as_view(),
        name="driver_onboarding_documents_required",
    ),
]
