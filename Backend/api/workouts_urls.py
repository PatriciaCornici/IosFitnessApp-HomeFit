from django.urls import path
from .views import WorkoutListCreateAPIView

urlpatterns = [
    path('', WorkoutListCreateAPIView.as_view(), name='workout-list'),
]
