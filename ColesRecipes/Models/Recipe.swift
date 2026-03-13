import Foundation

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Identifiable, Equatable {
    var id: String { dynamicTitle }

    let dynamicTitle: String
    let dynamicDescription: String
    let dynamicThumbnail: String?
    let dynamicThumbnailAlt: String?
    let recipeDetails: RecipeDetails?
    let ingredients: [Ingredient]?

    var imageURL: URL? {
        guard let path = dynamicThumbnail else { return nil }
        return URL(string: "https://coles.com.au\(path)")
    }

    var totalTimeMinutes: Int? {
        guard let details = recipeDetails else { return nil }
        let prep = details.prepTimeAsMinutes ?? 0
        let cook = details.cookTimeAsMinutes ?? 0
        return prep + cook
    }
}

struct RecipeDetails: Codable, Equatable {
    let amountLabel: String?
    let amountNumber: Int?
    let prepLabel: String?
    let prepTime: String?
    let prepNote: String?
    let cookingLabel: String?
    let cookingTime: String?
    let cookTimeAsMinutes: Int?
    let prepTimeAsMinutes: Int?
}

struct Ingredient: Codable, Identifiable, Equatable {
    var id: String { ingredient }
    let ingredient: String
}
