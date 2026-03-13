import Foundation

protocol RecipeSorting {
    func sorted(_ recipes: [Recipe]) -> [Recipe]
}

struct RecipeSorter: RecipeSorting {
    /// Sorts recipes by total time (prep + cooking) in ascending order.
    /// Recipes with nil details are placed at the end.
    func sorted(_ recipes: [Recipe]) -> [Recipe] {
        recipes.sorted { lhs, rhs in
            switch (lhs.totalTimeMinutes, rhs.totalTimeMinutes) {
            case let (lhsTime?, rhsTime?):
                return lhsTime < rhsTime
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return false
            }
        }
    }
}
