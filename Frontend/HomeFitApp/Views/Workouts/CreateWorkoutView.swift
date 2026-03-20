import SwiftUI
import PhotosUI
import AVKit

struct CreateWorkoutView: View {
    @ObservedObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var duration = ""

    let levelCategories = ["Beginner", "Intermediate", "Advanced"]
    let workoutTypes = ["Pilates", "Strength", "Cardio", "Yoga"]
    let bodyParts = ["Core", "Arms", "Legs", "Back", "Chest", "Shoulders", "Glutes"]
    let bodyAreas = ["Upper Body", "Lower Body", "Full Body", "Midsection"]

    @State private var selectedLevelCategory = "Beginner"
    @State private var selectedWorkoutType = "Pilates"
    @State private var selectedBodyPart = "Core"
    @State private var selectedBodyArea = "Full Body"

    @State private var caloriesBurned = ""
    @State private var equipmentNeeded = ""
    @State private var description = ""

    @State private var selectedVideoData: Data?
    @State private var selectedVideoFilename: String = ""
    @State private var videoPreviewURL: URL?

    @State private var selectedImageData: Data?
    @State private var selectedImageFilename: String = ""

    @State private var videoItem: PhotosPickerItem?
    @State private var imageItem: PhotosPickerItem?

    @State private var uploadStatus = ""

    var body: some View {
        Form {
            Section(header: Text("Workout Info")) {
                TextField("Title", text: $title)
                TextField("Duration", text: $duration)

                Picker("Level Category", selection: $selectedLevelCategory) {
                    ForEach(levelCategories, id: \.self) { level in
                        Text(level)
                    }
                }

                Picker("Workout Type", selection: $selectedWorkoutType) {
                    ForEach(workoutTypes, id: \.self) { type in
                        Text(type)
                    }
                }

                TextField("Calories Burned", text: $caloriesBurned)
                    .keyboardType(.numberPad)

                TextField("Equipment Needed (comma-separated)", text: $equipmentNeeded)

                Picker("Body Part", selection: $selectedBodyPart) {
                    ForEach(bodyParts, id: \.self) { part in
                        Text(part)
                    }
                }

                Picker("Body Area", selection: $selectedBodyArea) {
                    ForEach(bodyAreas, id: \.self) { area in
                        Text(area)
                    }
                }

                TextField("Description", text: $description)
            }

            Section(header: Text("Media")) {
                PhotosPicker(
                    selection: $videoItem,
                    matching: .videos,
                    photoLibrary: .shared()
                ) {
                    Text("Select Video").foregroundColor(.blue)
                }
                .onChange(of: videoItem) { newItem in
                    Task {
                        if let item = newItem,
                           let data = try? await item.loadTransferable(type: Data.self) {
                            selectedVideoData = data
                            selectedVideoFilename = "selected_video.mp4"

                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview.mp4")
                            do {
                                try data.write(to: tempURL, options: .atomic)
                                videoPreviewURL = tempURL
                            } catch {
                                uploadStatus = "Failed to save video preview."
                            }
                        } else {
                            uploadStatus = "Failed to load video."
                        }
                    }
                }

                if let url = videoPreviewURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(10)
                    Text("✅ Video selected: \(selectedVideoFilename)")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                PhotosPicker(
                    selection: $imageItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select Image").foregroundColor(.blue)
                }
                .onChange(of: imageItem) { newItem in
                    Task {
                        if let item = newItem,
                           let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            selectedImageFilename = "selected_image.jpg"
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
                Button("Save Workout") {
                    uploadWorkout()
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
        .navigationTitle("Create Workout")
        .background(Color.homefitBackground)
    }

    private func uploadWorkout() {
        guard let videoData = selectedVideoData,
              let imageData = selectedImageData,
              let url = URL(string: "http://127.0.0.1:8000/workouts/") else {
            uploadStatus = "Missing video, image, or URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let token = userVM.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func appendFormField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendFormField("title", title)
        appendFormField("duration", duration)
        appendFormField("level_category", selectedLevelCategory)
        appendFormField("workout_type", selectedWorkoutType)
        appendFormField("calories_burned", caloriesBurned)
        appendFormField("equipment_needed", equipmentNeeded)
        appendFormField("body_part", selectedBodyPart)
        appendFormField("body_area", selectedBodyArea)
        appendFormField("description", description)

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(selectedImageFilename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(selectedVideoFilename)\"\r\n")
        body.append("Content-Type: video/mp4\r\n\r\n")
        body.append(videoData)
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

                uploadStatus = "Workout uploaded successfully ✅"
                resetFields()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }.resume()
    }

    private func resetFields() {
        title = ""
        duration = ""
        selectedLevelCategory = "Beginner"
        selectedWorkoutType = "Pilates"
        selectedBodyPart = "Core"
        selectedBodyArea = "Full Body"
        caloriesBurned = ""
        equipmentNeeded = ""
        description = ""
        selectedVideoData = nil
        selectedVideoFilename = ""
        videoPreviewURL = nil
        selectedImageData = nil
        selectedImageFilename = ""
        videoItem = nil
        imageItem = nil
    }
}

