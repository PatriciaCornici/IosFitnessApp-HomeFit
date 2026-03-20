from rest_framework import viewsets, permissions, generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status
from .models import Workout, SavedWorkout
from .serializers import WorkoutSerializer
from .serializers import SavedWorkoutSerializer
from .models import Meal, SavedMeal
from .serializers import MealSerializer, SavedMealSerializer

class WorkoutViewSet(viewsets.ModelViewSet):
    queryset = Workout.objects.all().order_by('-created_at')
    serializer_class = WorkoutSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(instructor=self.request.user)

class SavedWorkoutViewSet(viewsets.ModelViewSet):
    serializer_class = SavedWorkoutSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SavedWorkout.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['post'], url_path='toggle')
    def toggle_saved(self, request):
        workout_id = request.data.get("workout_id")
        print(f"🟡 Received toggle request for workout_id: {workout_id}")

        if not workout_id:
            print("❌ workout_id missing")
            return Response({"error": "workout_id required"}, status=400)

        workout = Workout.objects.filter(id=workout_id).first()
        if not workout:
            print("❌ workout not found")
            return Response({"error": "Workout not found"}, status=404)

        saved, created = SavedWorkout.objects.get_or_create(user=request.user, workout=workout)
        if not created:
            print("🟠 Already existed — deleting it")
            saved.delete()
            return Response({"status": "removed"})

        print("✅ Created new saved workout")
        return Response({"status": "added"})

class WorkoutListCreateAPIView(generics.ListCreateAPIView):
    queryset = Workout.objects.all()
    serializer_class = WorkoutSerializer

class SavedWorkoutListAPIView(generics.ListAPIView):
    serializer_class = SavedWorkoutSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return SavedWorkout.objects.filter(user=self.request.user)
    
class MealViewSet(viewsets.ModelViewSet):
    queryset = Meal.objects.all().order_by('-created_at')
    serializer_class = MealSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(instructor=self.request.user)


class SavedMealViewSet(viewsets.ModelViewSet):
    serializer_class = SavedMealSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SavedMeal.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['post'], url_path='toggle')
    def toggle_saved(self, request):
        meal_id = request.data.get("meal_id")

        if not meal_id:
            return Response({"error": "meal_id required"}, status=400)

        meal = Meal.objects.filter(id=meal_id).first()
        if not meal:
            return Response({"error": "Meal not found"}, status=404)

        saved, created = SavedMeal.objects.get_or_create(user=request.user, meal=meal)
        if not created:
            saved.delete()
            return Response({"status": "removed"})

        return Response({"status": "added"})

