from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings  # required for referencing the custom user

# Custom User model
class User(AbstractUser):
    USER_TYPES = (
        ("User", "User"),
        ("Instructor", "Instructor"),
    )

    name = models.CharField(max_length=255)
    user_type = models.CharField(max_length=20, choices=USER_TYPES)

    def __str__(self):
        return self.email or self.username
        

# Workout model
class Workout(models.Model):
    title = models.CharField(max_length=100)
    duration = models.CharField(max_length=50)
    level_category = models.CharField(max_length=50)
    workout_type = models.CharField(max_length=50)  # e.g., Pilates, Yoga
    calories_burned = models.IntegerField()
    equipment_needed = models.CharField(max_length=255)

    body_part = models.CharField(max_length=50)
    body_area = models.CharField(max_length=50)
    description = models.TextField()

    image = models.ImageField(upload_to='workout_images/')
    video = models.FileField(upload_to='workout_videos/')

    instructor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='workouts'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} by {self.instructor.email}"


class SavedWorkout(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='saved_workouts')
    workout = models.ForeignKey(Workout, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('user', 'workout')

class Meal(models.Model):
    title = models.CharField(max_length=100)
    preparation_time = models.CharField(max_length=50)
    meal_type = models.CharField(max_length=50)  # Breakfast, Lunch, Dinner, Snack
    ingredients = models.JSONField()
    calories = models.IntegerField()
    is_vegetarian = models.BooleanField(default=False)
    is_vegan = models.BooleanField(default=False)
    is_high_protein = models.BooleanField(default=False)
    is_low_carb = models.BooleanField(default=False)
    image = models.ImageField(upload_to='meal_images/')
    description = models.TextField()

    instructor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='meals'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} by {self.instructor.email}"


class SavedMeal(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='saved_meals')
    meal = models.ForeignKey(Meal, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('user', 'meal')