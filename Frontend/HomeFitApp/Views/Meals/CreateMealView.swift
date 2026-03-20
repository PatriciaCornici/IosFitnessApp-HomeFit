import SwiftUI
import PhotosUI

struct CreateMealView: View {
    @ObservedObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var preparationTime = ""
    @State private var selectedMealType: String = "Breakfast"
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    @State private var ingredients = ""
    @State private var calories = ""
    @State private var isVegetarian = false
    @State private var isVegan = false
    @State private var isHighProtein = false
    @State private var isLowCarb = false
    @State private var description = ""

    @State private var selectedImageData: Data?
    @State private var selectedImageFilename: String = ""
    @State private var imageItem: PhotosPickerItem?

    @State private var uploadStatus = ""

    var body: some View {
        Form {
            Section(header: Text("Meal Info")) {
                TextField("Title", text: $title)
                TextField("Preparation Time", text: $preparationTime)

                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(mealTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }

                TextField("Ingredients (comma-separated)", text: $ingredients)
                TextField("Calories", text: $calories)
                    .keyboardType(.numberPad)
                TextField("Description", text: $description)
            }

            Section(header: Text("Tags")) {
                Toggle("Vegetarian", isOn: $isVegetarian)
                Toggle("Vegan", isOn: $isVegan)
                Toggle("High Protein", isOn: $isHighProtein)
                Toggle("Low Carb", isOn: $isLowCarb)
            }

            Section(header: Text("Image")) {
                PhotosPicker(
                    selection: $imageItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select Meal Image").foregroundColor(.blue)
                }
                .onChange(of: imageItem) { newItem in
                    Task {
                        if let item = newItem,
                           let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            selectedImageFilename = "selected_meal_image.jpg"
                        } else {
                            uploadStatus = "Failed to load image."
                        }
                    }
                }

                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                    Text("✅ Image selected: \(selectedImageFilename)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Section {
                Button("Save Meal") {
                    uploadMeal()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.homefitAccent)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if !uploadStatus.isEmpty {
                    Text(uploadStatus)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Create Meal")
        .background(Color.homefitBackground)
    }

    private func uploadMeal() {
        guard let imageData = selectedImageData,
              let url = URL(string: "\(APIService.baseURL)/meals/"),
              let token = userVM.token else {
            uploadStatus = "Missing image, URL, or token."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func appendFormField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendFormField("title", title)
        appendFormField("preparation_time", preparationTime)
        appendFormField("meal_type", selectedMealType)
        if let ingredientsData = try? JSONSerialization.data(withJSONObject: ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }) {
            let jsonString = String(data: ingredientsData, encoding: .utf8) ?? "[]"
            appendFormField("ingredients", jsonString)
        }
        guard let caloriesInt = Int(calories) else {
            uploadStatus = "Calories must be a valid number."
            return
        }
        appendFormField("calories", String(caloriesInt))
        appendFormField("is_vegetarian", "\(isVegetarian)")
        appendFormField("is_vegan", "\(isVegan)")
        appendFormField("is_high_protein", "\(isHighProtein)")
        appendFormField("is_low_carb", "\(isLowCarb)")
        appendFormField("description", description)

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(selectedImageFilename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    uploadStatus = "Upload failed: \(error.localizedDescription)"
                    return
                }

                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    uploadStatus = "Server error: \(response.statusCode)"
                    return
                }

                uploadStatus = "Meal uploaded successfully ✅"
                resetFields()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }.resume()
    }

    private func resetFields() {
        title = ""
        preparationTime = ""
        selectedMealType = "Breakfast"
        ingredients = ""
        calories = ""
        isVegetarian = false
        isVegan = false
        isHighProtein = false
        isLowCarb = false
        description = ""
        selectedImageData = nil
        selectedImageFilename = ""
        imageItem = nil
    }
}

