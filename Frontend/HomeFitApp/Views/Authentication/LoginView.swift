import SwiftUI
import Foundation

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var userVM: UserViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var loginError = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            Image("HomeFitLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)

            Text("Welcome Back")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.homefitTextDark)

            RoundedInputField(placeholder: "Email", text: $email)
            RoundedInputField(placeholder: "Password", text: $password, isSecure: true)

            if !loginError.isEmpty {
                Text(loginError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            RoundedButton(title: "Login") {
                userVM.login(email: email, password: password) {
                       alertMessage = "Logged in as: \(userVM.userProfile.userType.rawValue)"
                       showAlert = true
                       isLoggedIn = true
                   } onFailure: { error in
                       loginError = "Invalid username or password!"
                       print("Login failed:", error.localizedDescription)
                   }
            }
            .padding(.top, 40)

            NavigationLink {
                RegisterView(isLoggedIn: $isLoggedIn)
            } label: {
                Text("Don't have an account? Register")
                    .font(.footnote)
                    .foregroundColor(.homefitTextLight)
            }

            Spacer()
        }
        .padding()
        .background(Color.homefitBackground)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

