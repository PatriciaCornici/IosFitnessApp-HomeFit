from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from api.views import WorkoutViewSet, SavedWorkoutViewSet,  MealViewSet, SavedMealViewSet

router = DefaultRouter()
router.register(r'workouts', WorkoutViewSet, basename='workout')
router.register(r'saved-workouts', SavedWorkoutViewSet, basename='savedworkout')
router.register(r'meals', MealViewSet, basename='meal')
router.register(r'saved-meals', SavedMealViewSet, basename='savedmeal')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('djoser.urls')),
    path('auth/', include('djoser.urls.jwt')),
    path('', include(router.urls)),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
