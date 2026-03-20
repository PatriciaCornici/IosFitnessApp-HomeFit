from djoser.serializers import UserCreateSerializer, UserSerializer
from rest_framework import serializers 
from .models import User
from .models import Workout, SavedWorkout
from .models import Meal, SavedMeal

class CustomUserCreateSerializer(UserCreateSerializer):
    class Meta(UserCreateSerializer.Meta):
        model = User
        fields = ('id', 'username', 'email', 'password', 'name', 'user_type')

class CustomUserSerializer(UserSerializer):
    class Meta(UserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'username', 'name', 'user_type')


class WorkoutSerializer(serializers.ModelSerializer):
    instructor = CustomUserSerializer(read_only=True)
    video_url = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Workout
        fields = [
            'id', 'title', 'duration', 'level_category', 'workout_type',
            'calories_burned', 'equipment_needed', 'body_part', 'body_area',
            'description', 'image', 'video',
            'instructor',  # ✅ returns as nested object
            'image_url', 'video_url',
            'created_at'
        ]

    def get_video_url(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.video.url) if obj.video else None

    def get_image_url(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.image.url) if obj.image else None

class SavedWorkoutSerializer(serializers.ModelSerializer):
    workout = WorkoutSerializer(read_only=True)

    class Meta:
        model = SavedWorkout
        fields = ['id', 'workout']

class MealSerializer(serializers.ModelSerializer):
    instructor = CustomUserSerializer(read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Meal
        fields = [
            'id', 'title', 'preparation_time', 'meal_type', 'ingredients', 'calories',
            'is_vegetarian', 'is_vegan', 'is_high_protein', 'is_low_carb',
            'description', 'image', 'instructor', 'image_url', 'created_at'
        ]

    def get_image_url(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.image.url) if obj.image else None


class SavedMealSerializer(serializers.ModelSerializer):
    meal = MealSerializer(read_only=True)

    class Meta:
        model = SavedMeal
        fields = ['id', 'meal']

