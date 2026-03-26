from django.contrib import admin

from .models import DriverProfile


@admin.register(DriverProfile)
class DriverProfileAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "approval_status", "created_at")
    list_filter = ("approval_status",)
    search_fields = ("user__phone",)
    autocomplete_fields = ("user",)
