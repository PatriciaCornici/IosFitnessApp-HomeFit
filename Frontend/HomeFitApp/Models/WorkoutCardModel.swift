struct InstructorInfo: Codable {
    let email: String
    let name: String
    let user_type: String
}

struct WorkoutCardModel: Codable, Identifiable {
    let id: Int
    let title: String
    let duration: String
    let levelCategory: String
    let workoutType: String
    let caloriesBurned: Int
    let equipmentNeeded: String
    let bodyPart: String
    let bodyArea: String
    let description: String
    let imageUrl: String
    let videoUrl: String
    let instructor: InstructorInfo
    
    var instructorEmail: String { instructor.email }
    var instructorName: String { instructor.name }
    var isSaved: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, title, duration, description, instructor
        case levelCategory = "level_category"
        case workoutType = "workout_type"
        case caloriesBurned = "calories_burned"
        case equipmentNeeded = "equipment_needed"
        case bodyPart = "body_part"
        case bodyArea = "body_area"
        case imageUrl = "image_url"
        case videoUrl = "video_url"
    }
}

