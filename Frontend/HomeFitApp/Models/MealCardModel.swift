import Foundation

struct MealCardModel: Codable, Identifiable {
    let id: Int
    let title: String
    let preparationTime: String
    let mealType: String
    let ingredients: [String]
    let calories: Int
    let isVegetarian: Bool
    let isVegan: Bool
    let isHighProtein: Bool
    let isLowCarb: Bool
    let imageUrl: String
    let description: String
    let instructor: InstructorInfo

    var instructorEmail: String { instructor.email }
    var instructorName: String { instructor.name }

    enum CodingKeys: String, CodingKey {
        case id, title, ingredients, calories, description, instructor
        case preparationTime = "preparation_time"
        case mealType = "meal_type"
        case isVegetarian = "is_vegetarian"
        case isVegan = "is_vegan"
        case isHighProtein = "is_high_protein"
        case isLowCarb = "is_low_carb"
        case imageUrl = "image_url"
    }
}

