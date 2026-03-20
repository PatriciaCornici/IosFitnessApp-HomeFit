import SwiftUI

struct PilatesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedLevel = "Beginner"
    let levels = ["Beginner", "Intermediate", "Advanced"]

    @State private var allWorkouts: [WorkoutCardModel] = []
    @State private var isLoading = true

    var filteredWorkouts: [WorkoutCardModel] {
        allWorkouts
            .filter { $0.workoutType.lowercased() == "pilates" }
            .filter { $0.levelCategory.lowercased() == selectedLevel.lowercased() }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CompactSegmentedPicker(selection: $selectedLevel, options: levels)
                    .padding(.horizontal)
                    .padding(.top, 20)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if filteredWorkouts.isEmpty {
                    Text("No Pilates workouts found for \(selectedLevel).")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredWorkouts, id: \.id) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                RoutineCard(workout: workout)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Pilates")
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
            if userVM.workoutListNeedsRefresh || allWorkouts.isEmpty {
                loadWorkouts()
                userVM.workoutListNeedsRefresh = false
            }
        }
    }

    private func loadWorkouts() {
        isLoading = true

        APIService.fetchWorkouts { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let workouts) = result {
                    self.allWorkouts = workouts
                }
            }
        }

        if let token = userVM.token {
            APIService.fetchSavedWorkouts(token: token) { result in
                DispatchQueue.main.async {
                    if case .success(let savedWorkouts) = result {
                        userVM.savedWorkoutIDs = Set(savedWorkouts.map { $0.id })
                    }
                }
            }
        }
    }
}

