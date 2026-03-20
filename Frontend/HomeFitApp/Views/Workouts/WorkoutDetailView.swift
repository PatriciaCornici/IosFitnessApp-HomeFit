import SwiftUI
import AVKit

struct WorkoutDetailView: View {
    let workout: WorkoutCardModel
    @State private var player: AVPlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Workout image
                /*AsyncImage(url: URL(string: workout.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    @unknown default:
                        EmptyView()
                    }
                }*/

                // Video player
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(height: 220)
                        .cornerRadius(12)
                        .onAppear {
                            print("📹 Video URL:", workout.videoUrl)
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                        }
                } else {
                    Text("Unable to load video.")
                        .foregroundColor(.red)
                }

                // Workout information
                Text(workout.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.homefitTextDark)

                Group {
                    Text("Instructor: \(workout.instructorName)")
                    Text("Contact Info: \(workout.instructorEmail)")
                    Text("Duration: \(workout.duration)")
                    Text("Level: \(workout.levelCategory)")
                    Text("Workout Type: \(workout.workoutType)")
                    Text("Workout Type: \(workout.bodyArea)")
                    Text("Workout Type: \(workout.bodyPart)")
                }

                Text("Description:")
                    .font(.headline)

                Text(workout.description)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .background(Color.homefitBackground)
        .onAppear {
            if let url = URL(string: workout.videoUrl) {
                let player = AVPlayer(url: url)
                player.isMuted = true
                self.player = player
                player.play()
            }
       }
    }
}

