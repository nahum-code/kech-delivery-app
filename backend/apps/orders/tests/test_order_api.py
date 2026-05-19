from decimal import Decimal

from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.drivers.models import DriverProfile
from apps.orders.models import Order
from apps.restaurants.models import MenuCategory, MenuItem, Restaurant
from core.models import User


class OrderApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.customer = User.objects.create_user(
            phone="+72000000001",
            password="ComplexPass1!",
            role=User.Role.CUSTOMER,
        )
        self.other_customer = User.objects.create_user(
            phone="+72000000002",
            password="ComplexPass1!",
            role=User.Role.CUSTOMER,
        )
        self.sales = User.objects.create_user(
            phone="+72000000003",
            password="ComplexPass1!",
            role=User.Role.SALES,
        )
        self.admin = User.objects.create_user(
            phone="+72000000004",
            password="ComplexPass1!",
            role=User.Role.ADMIN,
        )
        self.driver = User.objects.create_user(
            phone="+72000000005",
            password="ComplexPass1!",
            role=User.Role.DRIVER,
        )
        DriverProfile.objects.create(
            user=self.driver,
            full_name="Driver One",
            approval_status=DriverProfile.ApprovalStatus.APPROVED,
        )
        self.restaurant = Restaurant.objects.create(
            name="Test Bistro",
            latitude=Decimal("31.62"),
            longitude=Decimal("-7.98"),
            is_active=True,
        )
        self.category = MenuCategory.objects.create(restaurant=self.restaurant, name="Mains")
        self.menu_item = MenuItem.objects.create(
            restaurant=self.restaurant,
            category=self.category,
            name="Tagine",
            price=Decimal("85.00"),
            is_available=True,
        )

    def _order_payload(self):
        return {
            "restaurant_id": self.restaurant.id,
            "items": [{"menu_item_id": self.menu_item.id, "quantity": 2}],
            "delivery_address": {
                "receiver_name": "Amina",
                "phone": "+212600000000",
                "address_line": "Gueliz, Marrakech",
                "landmark": "Near cafe",
            },
            "customer_note": "No spice",
        }

    def test_customer_creates_order(self):
        self.client.force_authenticate(user=self.customer)
        res = self.client.post("/api/v1/orders/", self._order_payload(), format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertEqual(res.json()["status"], Order.Status.PENDING)
        self.assertEqual(Decimal(res.json()["subtotal"]), Decimal("170.00"))

    def test_customer_cannot_see_other_order(self):
        self.client.force_authenticate(user=self.customer)
        created = self.client.post("/api/v1/orders/", self._order_payload(), format="json")
        order_id = created.json()["id"]

        self.client.force_authenticate(user=self.other_customer)
        detail = self.client.get(f"/api/v1/orders/{order_id}/")
        self.assertEqual(detail.status_code, status.HTTP_404_NOT_FOUND)

    def test_invalid_status_transition(self):
        self.client.force_authenticate(user=self.customer)
        created = self.client.post("/api/v1/orders/", self._order_payload(), format="json")
        order_id = created.json()["id"]

        self.client.force_authenticate(user=self.admin)
        patch = self.client.patch(
            f"/api/v1/orders/{order_id}/status/",
            {"status": Order.Status.DELIVERED},
            format="json",
        )
        self.assertEqual(patch.status_code, status.HTTP_409_CONFLICT)

    def test_assign_approved_driver(self):
        self.client.force_authenticate(user=self.customer)
        created = self.client.post("/api/v1/orders/", self._order_payload(), format="json")
        order_id = created.json()["id"]

        self.client.force_authenticate(user=self.sales)
        for next_status in (
            Order.Status.CONFIRMED,
            Order.Status.PREPARING,
            Order.Status.READY_FOR_PICKUP,
        ):
            res = self.client.patch(
                f"/api/v1/orders/{order_id}/status/",
                {"status": next_status},
                format="json",
            )
            self.assertEqual(res.status_code, status.HTTP_200_OK, msg=next_status)
        assign = self.client.post(
            f"/api/v1/orders/{order_id}/assign-driver/",
            {"driver_id": self.driver.id},
            format="json",
        )
        self.assertEqual(assign.status_code, status.HTTP_200_OK)
        self.assertEqual(assign.json()["assigned_driver"], self.driver.id)

    def test_driver_sees_assigned_orders_only(self):
        order = Order.objects.create(
            reference="KD-9999",
            customer=self.customer,
            restaurant=self.restaurant,
            assigned_driver=self.driver,
            status=Order.Status.ASSIGNED,
            subtotal=Decimal("50"),
            delivery_fee=Decimal("25"),
            total_amount=Decimal("75"),
            delivery_address={"receiver_name": "X", "phone": "+212600000001", "address_line": "Y"},
        )
        Order.objects.create(
            reference="KD-9998",
            customer=self.customer,
            restaurant=self.restaurant,
            status=Order.Status.PENDING,
            subtotal=Decimal("50"),
            delivery_fee=Decimal("25"),
            total_amount=Decimal("75"),
            delivery_address={"receiver_name": "X", "phone": "+212600000001", "address_line": "Y"},
        )

        self.client.force_authenticate(user=self.driver)
        res = self.client.get("/api/v1/drivers/orders/")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        ids = [o["id"] for o in res.json()["results"]]
        self.assertEqual(ids, [order.id])

    def test_cancelled_order_cannot_be_reassigned(self):
        order = Order.objects.create(
            reference="KD-9997",
            customer=self.customer,
            restaurant=self.restaurant,
            status=Order.Status.CANCELLED,
            subtotal=Decimal("50"),
            delivery_fee=Decimal("25"),
            total_amount=Decimal("75"),
            delivery_address={"receiver_name": "X", "phone": "+212600000001", "address_line": "Y"},
        )
        self.client.force_authenticate(user=self.sales)
        res = self.client.post(
            f"/api/v1/orders/{order.id}/assign-driver/",
            {"driver_id": self.driver.id},
            format="json",
        )
        self.assertEqual(res.status_code, status.HTTP_409_CONFLICT)
