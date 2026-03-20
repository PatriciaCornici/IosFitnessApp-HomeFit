import SwiftUI

struct RoutineCard: View {
    let workout: WorkoutCardModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var isSaved: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: workout.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo").resizable().scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.headline)
                    .foregroundColor(.homefitTextDark)

                Text("\(workout.duration) • \(workout.levelCategory)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
               guard let token = userVM.token else {
                   print("❌ Missing token when trying to toggle saved workout")
                   return
               }

               print("🟡 Toggling saved state for workout ID: \(workout.id)")

               APIService.toggleSavedWorkout(workoutID: workout.id, token: token) { added in
                   DispatchQueue.main.async {
                       print("✅ Toggle API responded: added = \(added) for workout ID: \(workout.id)")
                       isSaved = added

                       if added {
                           userVM.savedWorkoutIDs.insert(workout.id)
                       } else {
                           userVM.savedWorkoutIDs.remove(workout.id)
                       }

                       print("🧠 Current savedWorkoutIDs: \(userVM.savedWorkoutIDs)")
                   }
               }
           }) {
               Image(systemName: isSaved ? "heart.fill" : "heart")
                   .foregroundColor(.red)
                   .imageScale(.large)
           }
        }
        .padding()
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            isSaved = userVM.savedWorkoutIDs.contains(workout.id)
        }
    }
}

