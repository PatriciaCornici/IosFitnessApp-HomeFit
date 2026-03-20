import SwiftUI

struct LoadableWorkoutList: View {
    let allWorkouts: [WorkoutCardModel]
    let workoutType: String
    let level: String

    var filteredWorkouts: [WorkoutCardModel] {
        allWorkouts
            .filter { $0.workoutType.lowercased() == workoutType.lowercased() }
            .filter { $0.levelCategory.lowercased() == level.lowercased() }
    }

    var body: some View {
        if filteredWorkouts.isEmpty {
            Text("No \(workoutType.capitalized) workouts found for \(level).")
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity)
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
}

