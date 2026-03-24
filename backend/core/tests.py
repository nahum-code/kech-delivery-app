from django.test import TestCase
from celery import shared_task

# Create your tests here.

@shared_task
def add(x, y):
    return x + y
