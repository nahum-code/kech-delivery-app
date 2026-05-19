from django.urls import path

from .onboarding_views import (
    DriverDocumentUploadView,
    DriverOnboardingStatusView,
    DriverRequiredDocumentsView,
)
from apps.orders.api.views import DriverOrdersListView

from .delivery_views import (
    DriverAvailabilityView,
    DriverOrderAcceptView,
    DriverOrderCompleteView,
    DriverOrderDetailView,
    DriverOrderPickupView,
    DriverOrderStartDeliveryView,
)
from .views import DriverStatusView

urlpatterns = [
    path("orders/", DriverOrdersListView.as_view(), name="driver_orders"),
    path("orders/<int:order_id>/", DriverOrderDetailView.as_view(), name="driver_order_detail"),
    path("orders/<int:order_id>/accept/", DriverOrderAcceptView.as_view(), name="driver_order_accept"),
    path("orders/<int:order_id>/pickup/", DriverOrderPickupView.as_view(), name="driver_order_pickup"),
    path(
        "orders/<int:order_id>/start-delivery/",
        DriverOrderStartDeliveryView.as_view(),
        name="driver_order_start_delivery",
    ),
    path("orders/<int:order_id>/complete/", DriverOrderCompleteView.as_view(), name="driver_order_complete"),
    path("me/availability/", DriverAvailabilityView.as_view(), name="driver_availability"),
    path("me/status/", DriverStatusView.as_view(), name="driver_me_status"),
    path("onboarding/status/", DriverOnboardingStatusView.as_view(), name="driver_onboarding_status"),
    path("onboarding/documents/", DriverDocumentUploadView.as_view(), name="driver_onboarding_documents"),
    path(
        "onboarding/documents/required/",
        DriverRequiredDocumentsView.as_view(),
        name="driver_onboarding_documents_required",
    ),
]
