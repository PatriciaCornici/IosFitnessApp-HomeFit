import SwiftUI

struct SavedWorkoutsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedLevel = "Beginner"
    @State private var savedWorkouts: [WorkoutCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let levels = ["Beginner", "Intermediate", "Advanced"]

    var filteredWorkouts: [WorkoutCardModel] {
        savedWorkouts.filter { workout in
            workout.levelCategory.lowercased() == selectedLevel.lowercased()
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CompactSegmentedPicker(selection: $selectedLevel, options: levels)
                    .padding(.horizontal)
                    .padding(.top, 20)

                if isLoading {
                    ProgressView("Loading saved workouts...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredWorkouts.isEmpty {
                    Text("No saved workouts for this level.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredWorkouts, id: \.id) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                RoutineCard(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Saved Workouts")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.homefitBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            loadSavedWorkouts()
        }
    }

    private func loadSavedWorkouts() {
        guard let token = userVM.token ?? UserDefaults.standard.string(forKey: "accessToken") else {
            self.errorMessage = "Missing access token"
            self.isLoading = false
            return
        }

        APIService.fetchSavedWorkouts(token: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let workouts):
                    self.savedWorkouts = workouts
                    userVM.savedWorkoutIDs = Set(workouts.map { $0.id }) // ✅ sync with global state
                case .failure(let error):
                    self.errorMessage = "Failed to load workouts: \(error.localizedDescription)"
                }
            }
        }
    }
}

