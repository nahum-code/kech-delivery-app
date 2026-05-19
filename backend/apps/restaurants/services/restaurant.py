"""Restaurant write operations (business rules outside views)."""

from __future__ import annotations

from django.db import transaction

from apps.restaurants.models import Restaurant


class RestaurantServiceError(Exception):
    def __init__(self, message: str, *, status_code: int = 400) -> None:
        super().__init__(message)
        self.message = message
        self.status_code = status_code


@transaction.atomic
def create_restaurant(**fields) -> Restaurant:
    name = (fields.get("name") or "").strip()
    if not name:
        raise RestaurantServiceError("Restaurant name is required.")
    if Restaurant.objects.filter(name__iexact=name).exists():
        raise RestaurantServiceError("A restaurant with this name already exists.", status_code=409)
    return Restaurant.objects.create(**fields)


@transaction.atomic
def update_restaurant(restaurant: Restaurant, **fields) -> Restaurant:
    if "name" in fields:
        name = (fields["name"] or "").strip()
        if not name:
            raise RestaurantServiceError("Restaurant name is required.")
        if Restaurant.objects.filter(name__iexact=name).exclude(pk=restaurant.pk).exists():
            raise RestaurantServiceError("A restaurant with this name already exists.", status_code=409)
        fields["name"] = name

    for key, value in fields.items():
        setattr(restaurant, key, value)
    restaurant.save()
    return restaurant


def delete_restaurant(restaurant: Restaurant) -> None:
    restaurant.delete()
