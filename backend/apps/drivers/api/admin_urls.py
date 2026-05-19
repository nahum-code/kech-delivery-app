from django.urls import path

from .views import (
    ApprovedDriversListView,
    ApproveDriverView,
    PendingDriversListView,
    RejectDriverView,
    SuspendDriverView,
)

urlpatterns = [
    path("approved/", ApprovedDriversListView.as_view(), name="admin_drivers_approved"),
    path("pending/", PendingDriversListView.as_view(), name="admin_drivers_pending"),
    path("<int:user_id>/approve/", ApproveDriverView.as_view(), name="admin_driver_approve"),
    path("<int:user_id>/reject/", RejectDriverView.as_view(), name="admin_driver_reject"),
    path("<int:user_id>/suspend/", SuspendDriverView.as_view(), name="admin_driver_suspend"),
]
