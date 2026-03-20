import SwiftUI
import UserNotifications

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var userVM: UserViewModel

    @State private var showEditProfile = false

    // Fitness Preferences
    @State private var weeklyTarget = "4"
    @State private var fitnessLevel = "Intermediate"
    @State private var preferredStyle = "Pilates"
    let levels = ["None", "Beginner", "Intermediate", "Advanced"]
    let styles = ["None", "Pilates", "Yoga", "Power Pilates", "Strength Pilates"]

    // Time Saved
    @State private var showTimeSavedMessage = false
    @State private var reminderSaved = false

    // Daily Reminder
    @State private var remindersEnabled = false
    @State private var reminderTime: Date = Date()

    // Calendar
    @State private var workoutDates: Set<Date> = []
    @State private var currentMonth = Date()

    // Dietary
    @State private var isVegetarian = true
    @State private var isVegan = false
    @State private var isHighProtein = true
    @State private var isLowCarb = false

    // Water
    @State private var waterIntake: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Profile Image & Greeting
                VStack(spacing: 8) {
                    Image(userVM.userProfile.profileImageName ?? "profile-image")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 4)

                    Text("Welcome, \(userVM.userProfile.name ?? "")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.homefitTextDark)

                    Text("Goal: \(userVM.userProfile.goal ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Email: \(userVM.userProfile.email ?? "")")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                // Fitness Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fitness Preferences")
                        .font(.headline)
                        .foregroundColor(.homefitTextDark)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Level:")
                            Spacer()
                            Menu {
                                ForEach(levels, id: \.self) { level in
                                    Button { fitnessLevel = level } label: { Text(level) }
                                }
                            } label: {
                                Text(fitnessLevel)
                                    .foregroundColor(.gray)
                            }
                        }

                        HStack {
                            Text("Preferred Style:")
                            Spacer()
                            Menu {
                                ForEach(styles, id: \.self) { style in
                                    Button { preferredStyle = style } label: { Text(style) }
                                }
                            } label: {
                                Text(preferredStyle)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.91, green: 0.86, blue: 0.81))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                // Dietary Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dietary Preferences")
                        .font(.headline)
                        .foregroundColor(.homefitTextDark)

                    Toggle("Vegetarian", isOn: $isVegetarian).tint(.homefitAccent)
                    Toggle("Vegan", isOn: $isVegan).tint(.homefitAccent)
                    Toggle("High Protein", isOn: $isHighProtein).tint(.homefitAccent)
                    Toggle("Low Carb", isOn: $isLowCarb).tint(.homefitAccent)
                }
                .padding()
                .background(Color(red: 0.91, green: 0.86, blue: 0.81))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                .padding(.horizontal)

                // 🚀 PROGRESS Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Progress")
                        .font(.headline)
                        .foregroundColor(.homefitTextDark)

                    // Daily Reminder Toggle
                    Toggle("Daily Workout Reminder", isOn: $remindersEnabled)
                        .tint(.homefitAccent)
                        .onChange(of: remindersEnabled) {
                            if remindersEnabled {
                                scheduleWorkoutReminder()
                                reminderSaved = false
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                reminderSaved = false
                            }
                        }

                    // Show DatePicker & Save button only if not saved
                    if remindersEnabled && !reminderSaved {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(.top, 8)
                            .onChange(of: reminderTime) {
                                scheduleWorkoutReminder()
                            }

                        Button("Save") {
                            scheduleWorkoutReminder()
                            reminderSaved = true
                            showTimeSavedMessage = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showTimeSavedMessage = false
                            }
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.homefitAccent)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }

                    // Calendar
                    Text("Workout Calendar")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.homefitTextDark)

                    calendarView

                    // Water Intake
                    Text("Water Intake (200 ml cups)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.homefitTextDark)

                    HStack(spacing: 8) {
                        ForEach(0..<10, id: \.self) { index in
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(index < waterIntake ? .homefitAccent : .gray.opacity(0.3))
                                .onTapGesture {
                                    waterIntake = (index + 1 == waterIntake) ? index : index + 1
                                }
                        }
                    }

                }
                .padding()
                .background(Color(red: 0.91, green: 0.86, blue: 0.81))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                .padding(.horizontal)

                // Edit Profile Button
                Button("Edit Profile") {
                    showEditProfile = true
                }
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.homefitAccent)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(userVM: userVM)
                }

            }
            .padding(.vertical)
        }
        .background(Color.homefitBackground)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .overlay(
            Group {
                if showTimeSavedMessage {
                    VStack {
                        Text("Time Saved ✨")
                            .font(.body)
                            .fontWeight(.medium)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                            .transition(.scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2).ignoresSafeArea())
                    .transition(.opacity)
                }
            }
        )
    }

    // MARK: - Calendar View
    var calendarView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)! }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)! }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            let days = generateDaysInMonth(for: currentMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { date in
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(workoutDates.contains(date) ? .homefitAccent : .gray.opacity(0.3))
                        .overlay(
                            Text(dayNumberString(date))
                                .font(.footnote)
                                .foregroundColor(.black)
                        )
                        .onTapGesture {
                            if workoutDates.contains(date) {
                                workoutDates.remove(date)
                            } else {
                                workoutDates.insert(date)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Calendar Helpers
    func generateDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func dayNumberString(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }

    // MARK: - Notification
    func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time to workout!"
        content.body = "Stay consistent and reach your goals ✨"
        content.sound = .default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "WorkoutReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request)
    }
}

