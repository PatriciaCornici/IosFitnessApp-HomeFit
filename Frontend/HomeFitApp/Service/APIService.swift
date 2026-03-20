import Foundation
import SwiftUI

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct APIService {
    static let baseURL = "http://192.168.1.7:8000"
    
    static func fetchUserProfile(token: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/users/me/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            print("USER PROFILE RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                print("✅ Successfully decoded user type: \(profile.userType.rawValue)")
                completion(.success(profile))

            } catch {
                print("❌ Decoding error:", error)
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("🧩 Raw JSON structure:", json)
                }
                completion(.failure(error))
            }
        }.resume()
    }

    static func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/jwt/create/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": email,
            "password": password
        ]

        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let result = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            completion(.success(result.access))
        }.resume()
    }

    static func register(name: String, email: String, password: String, userType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/users/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": email,
            "email": email,
            "password": password,
            "name": name,
            "user_type": userType
        ]

        print("REGISTER BODY:", body)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                        print("RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")
                    }
            
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    static func fetchWorkouts(completion: @escaping (Result<[WorkoutCardModel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/workouts/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            do {
                let decoder = JSONDecoder()
                if let raw = String(data: data, encoding: .utf8) {
                        print("🔵 RAW WORKOUT JSON:\n\(raw)")
                    }
                let workouts = try decoder.decode([WorkoutCardModel].self, from: data)

                completion(.success(workouts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func fetchSavedWorkouts(token: String, completion: @escaping (Result<[WorkoutCardModel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/saved-workouts/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([SavedWorkoutResponse].self, from: data)
                let workouts = decoded.map { $0.workout }
                completion(.success(workouts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func toggleSavedWorkout(workoutID: Int, token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/saved-workouts/toggle/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["workout_id": workoutID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            if let responseDict = try? JSONDecoder().decode([String: String].self, from: data),
               let status = responseDict["status"] {
                completion(status == "added")
            } else {
                completion(false)
            }
        }.resume()
    }
    
    static func fetchMeals(completion: @escaping (Result<[MealCardModel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/meals/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            do {
                let decoder = JSONDecoder()
                if let raw = String(data: data, encoding: .utf8) {
                    print("🥗 RAW MEAL JSON:\n\(raw)")
                }
                let meals = try decoder.decode([MealCardModel].self, from: data)
                completion(.success(meals))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func fetchSavedMeals(token: String, completion: @escaping (Result<[MealCardModel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/saved-meals/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([SavedMealResponse].self, from: data)
                let meals = decoded.map { $0.meal }
                completion(.success(meals))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func toggleSavedMeal(mealID: Int, token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/saved-meals/toggle/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["meal_id": mealID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            if let responseDict = try? JSONDecoder().decode([String: String].self, from: data),
               let status = responseDict["status"] {
                completion(status == "added")
            } else {
                completion(false)
            }
        }.resume()
    }
    
    static func uploadWorkout(
        token: String,
        title: String,
        duration: String,
        levelCategory: String,
        workoutType: String,
        caloriesBurned: Int,
        equipmentNeeded: [String],
        bodyPart: String,
        bodyArea: String,
        description: String,
        videoData: Data?,
        videoFilename: String?,
        imageData: Data?,
        imageFilename: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/workouts/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendFormField(name: "title", value: title)
        appendFormField(name: "duration", value: duration)
        appendFormField(name: "level_category", value: levelCategory)
        appendFormField(name: "workout_type", value: workoutType)
        appendFormField(name: "calories_burned", value: String(caloriesBurned))
        appendFormField(name: "body_part", value: bodyPart)
        appendFormField(name: "body_area", value: bodyArea)
        appendFormField(name: "description", value: description)

        // Serialize equipment list
        let equipmentStr = equipmentNeeded.joined(separator: ", ")
        appendFormField(name: "equipment_needed", value: equipmentStr)


        // Attach video
        if let videoData = videoData, let videoFilename = videoFilename {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(videoFilename)\"\r\n")
            body.append("Content-Type: video/mp4\r\n\r\n")
            body.append(videoData)
            body.append("\r\n")
        }

        // Attach image
        if let imageData = imageData, let imageFilename = imageFilename {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageFilename)\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }

            if httpResponse.statusCode == 201 {
                completion(.success(()))
            } else {
                if let data = data {
                    print("🟥 Upload workout failed:", String(data: data, encoding: .utf8) ?? "Invalid response body")
                }
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    static func uploadMeal(
        token: String,
        title: String,
        preparationTime: String,
        mealType: String,
        ingredients: [String],
        calories: Int,
        isVegetarian: Bool,
        isVegan: Bool,
        isHighProtein: Bool,
        isLowCarb: Bool,
        description: String,
        imageData: Data?,
        imageFilename: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/meals/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendFormField(name: "title", value: title)
        appendFormField(name: "preparation_time", value: preparationTime)
        appendFormField(name: "meal_type", value: mealType)
        appendFormField(name: "calories", value: String(calories))
        appendFormField(name: "is_vegetarian", value: isVegetarian ? "true" : "false")
        appendFormField(name: "is_vegan", value: isVegan ? "true" : "false")
        appendFormField(name: "is_high_protein", value: isHighProtein ? "true" : "false")
        appendFormField(name: "is_low_carb", value: isLowCarb ? "true" : "false")
        appendFormField(name: "description", value: description)

        // Serialize ingredients list
        let ingredientsStr = ingredients.joined(separator: ", ")
        appendFormField(name: "ingredients", value: ingredientsStr)

        // Attach image
        if let imageData = imageData, let imageFilename = imageFilename {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageFilename)\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0)))
                return
            }

            if httpResponse.statusCode == 201 {
                completion(.success(()))
            } else {
                if let data = data {
                    print("🟥 Upload meal failed:", String(data: data, encoding: .utf8) ?? "Invalid response body")
                }
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}

struct TokenResponse: Codable {
    let access: String
    let refresh: String
}

struct SavedWorkoutResponse: Decodable {
    let id: Int
    let workout: WorkoutCardModel
}

struct SavedMealResponse: Decodable {
    let id: Int
    let meal: MealCardModel
}
