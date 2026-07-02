from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("orders", "0007_orderitem_takeaway_box_price"),
    ]

    operations = [
        migrations.AlterField(
            model_name="order",
            name="status",
            field=models.CharField(
                choices=[
                    ("pending", "Pending"),
                    ("awaiting_confirmation", "Awaiting confirmation"),
                    ("confirmed", "Confirmed"),
                    ("searching_driver", "Searching driver"),
                    ("preparing", "Preparing"),
                    ("ready_for_pickup", "Ready for pickup"),
                    ("assigned", "Assigned"),
                    ("declined", "Declined"),
                    ("picked_up", "Picked up"),
                    ("delivering", "Delivering"),
                    ("delivered", "Delivered"),
                    ("cancelled", "Cancelled"),
                ],
                db_index=True,
                default="pending",
                max_length=32,
            ),
        ),
    ]
