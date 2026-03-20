HomeFit — Personalized Fitness & Nutrition iOS App
HomeFit is a mobile application for iOS that helps users work out and eat healthy from home. It provides personalized workout routines, meal plans, and tracks user progress — all in one place. The app also includes an AI-powered chat assistant that answers fitness and nutrition questions in real time.


What the App Does

Personalized Workouts — Users can browse workouts filtered by difficulty level (beginner, intermediate, advanced) and target body area (arms, legs, core, full-body)
Meal Planning — Meals are filtered by dietary preference: vegetarian, vegan, high-protein, or low-carb
Progress Tracking — Users can log completed workouts, track daily water intake, and monitor calories burned over time
AI Assistant — A built-in chat powered by the OpenAI API answers questions like "suggest a beginner workout" or "what should I eat for muscle gain"
Favorites — Users can save their favorite workouts and meals for quick access
Instructor Role — A separate role that allows fitness instructors to create and publish their own workouts and meal plans through the app


How It Was Built:

The project is split into two parts:
Frontend (iOS App)

Built with SwiftUI — Apple's modern framework for building iOS apps
Handles all screens: Home, Workouts, Meals, Progress, Profile, and AI Assistant
Communicates with the backend through secure API calls
Stores some data locally on the device using SQLite for offline access

Backend (REST API)

Built with Node.js and Django REST Framework (Python)
Manages all the data: users, workouts, meals, and progress records
Handles user login and security using JWT (JSON Web Tokens)
Connected to a PostgreSQL database for storing all app data


Security

All communication between the app and the server is encrypted via HTTPS
User authentication is handled with JWT tokens — no passwords are stored in plain text
Each API request is validated and authorized before returning any data


Database Structure
The app stores four main types of data:

Users — profile info, fitness level, dietary preferences, account type
Workouts — title, difficulty, body area, duration, calories burned, equipment needed
Meals — ingredients, calories, dietary tags, preparation time
Progress — workout history, water intake logs, calories burned over time


AI Assistant
The assistant is powered by the OpenAI ChatGPT API. Users can ask it anything related to fitness or nutrition and get real-time answers directly inside the app, without leaving the platform.
