import Foundation

enum UserType: String, Codable {
    case user = "user"
    case instructor = "instructor"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        self = UserType(rawValue: rawValue) ?? .user
    }
}

struct UserProfile: Identifiable, Equatable, Codable {
    let id: Int
    var name: String
    var email: String
    var password: String?
    var profileImageName: String?
    var goal: String?
    var userType: UserType
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case password
            case profileImageName
            case goal
            case userType = "user_type"
        }
}

