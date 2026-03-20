from django.urls import path
from .views import SavedWorkoutListAPIView

urlpatterns = [
    path('', SavedWorkoutListAPIView.as_view(), name='saved-workouts'),
]
