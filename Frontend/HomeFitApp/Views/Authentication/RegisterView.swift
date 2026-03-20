import SwiftUI
import Foundation

struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var userVM: UserViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var userType: String = "User"
    let userTypes = ["User", "Instructor"]
    @State private var registrationError = ""

    var body: some View {
        VStack(spacing: 16) {
            Image("HomeFitLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.homefitTextDark)

            CustomSegmentedPicker(selection: $userType, options: userTypes)
                .padding(.bottom, 10)

            RoundedInputField(placeholder: "Name", text: $name)
            RoundedInputField(placeholder: "Email", text: $email)
            RoundedInputField(placeholder: "Password", text: $password, isSecure: true)
            RoundedInputField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)

            if !registrationError.isEmpty {
                Text(registrationError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            RoundedButton(title: "Register") {
                guard password == confirmPassword else {
                    registrationError = "Passwords don't match"
                    return
                }

                APIService.register(name: name, email: email, password: password, userType: userType) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            userVM.login(
                                email: email,
                                password: password,
                                onSuccess: {
                                    isLoggedIn = true
                                },
                                onFailure: { error in
                                    registrationError = error.localizedDescription
                                }
                            )
                        case .failure(let error):
                            registrationError = error.localizedDescription
                        }
                    }
                }
            }
            .padding(.top, 25)

            Spacer()
        }
        .padding()
        .background(Color.homefitBackground)
        .navigationBarBackButtonHidden(true)
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
    }
}

