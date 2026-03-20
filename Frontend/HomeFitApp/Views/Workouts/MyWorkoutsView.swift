import SwiftUI

struct MyWorkoutsView: View {
    @ObservedObject var userVM: UserViewModel
    @State private var workouts: [WorkoutCardModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading workouts...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(workouts) { workout in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(workout.title).font(.headline)
                        Text("Duration: \(workout.duration)")
                        Text("Type: \(workout.workoutType)")
                        Text("Instructor: \(workout.instructorName)")

                        AsyncImage(url: URL(string: workout.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFit().frame(height: 120).cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("My Workouts")
        .background(Color.homefitBackground)
        .onAppear {
            if userVM.workoutListNeedsRefresh || workouts.isEmpty {
                fetchInstructorWorkouts()
                userVM.workoutListNeedsRefresh = false
            }
        }
    }

    private func fetchInstructorWorkouts() {
        isLoading = true
        APIService.fetchWorkouts { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let allWorkouts):
                    workouts = allWorkouts.filter { $0.instructorEmail == userVM.userProfile.email }
                case .failure(let error):
                    errorMessage = "Failed to load workouts: \(error.localizedDescription)"
                }
            }
        }
    }
}

