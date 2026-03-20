import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userVM: UserViewModel

    @State private var name: String
    @State private var goal: String
    @State private var profileImageName: String
    @State private var password: String

    let availableImages = ["profile-image", "profile-image-2", "profile-image-3"]

    init(userVM: UserViewModel) {
        self.userVM = userVM
        _name = State(initialValue: userVM.userProfile.name ?? "")
        _goal = State(initialValue: userVM.userProfile.goal ?? "")
        _profileImageName = State(initialValue: userVM.userProfile.profileImageName ?? "profile-image")
        _password = State(initialValue: userVM.userProfile.password ?? "")
    }


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter your name", text: $name)
                }

                Section(header: Text("Goal")) {
                    TextField("Enter your goal", text: $goal)
                }

                Section(header: Text("Password")) {
                    SecureField("Enter new password", text: $password)
                }

                Section(header: Text("Profile Photo")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableImages, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(profileImageName == imageName ? Color.homefitAccent : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        profileImageName = imageName
                                    }
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userVM.userProfile.name = name
                        userVM.userProfile.goal = goal
                        userVM.userProfile.profileImageName = profileImageName
                        userVM.userProfile.password = password

                        // Optionally send PATCH to backend here
                        // userVM.updateUserProfile()

                        dismiss()
                    }
                }
            }
        }
    }
}

