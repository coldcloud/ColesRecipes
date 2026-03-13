import XCTest
@testable import ColesRecipes

final class RecipeSorterTests: XCTestCase {
    private var sorter: RecipeSorter!

    override func setUp() {
        super.setUp()
        sorter = RecipeSorter()
    }

    // MARK: - Sort Order

    func testSortsByTotalTimeAscending() {
        let recipes = [
            makeRecipe(title: "Slow", prep: 30, cook: 60),   // 90
            makeRecipe(title: "Fast", prep: 5, cook: 10),     // 15
            makeRecipe(title: "Medium", prep: 15, cook: 30),  // 45
        ]

        let sorted = sorter.sorted(recipes)

        XCTAssertEqual(sorted.map(\.dynamicTitle), ["Fast", "Medium", "Slow"])
    }

    func testRecipesWithSameTotalTimePreserveRelativeOrder() {
        let recipes = [
            makeRecipe(title: "A", prep: 10, cook: 20),  // 30
            makeRecipe(title: "B", prep: 15, cook: 15),  // 30
            makeRecipe(title: "C", prep: 5, cook: 25),   // 30
        ]

        let sorted = sorter.sorted(recipes)

        // All have the same total time, so relative order should be preserved
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted.map(\.dynamicTitle), ["A", "B", "C"])
    }

    // MARK: - Nil Handling

    func testRecipesWithNilDetailsGoToEnd() {
        let recipes = [
            makeRecipe(title: "No Details", prep: nil, cook: nil),
            makeRecipe(title: "Has Details", prep: 10, cook: 20),
        ]

        let sorted = sorter.sorted(recipes)

        XCTAssertEqual(sorted.first?.dynamicTitle, "Has Details")
        XCTAssertEqual(sorted.last?.dynamicTitle, "No Details")
    }

    func testRecipesWithPartialNilTimesDefaultToZero() {
        let recipe = makeRecipe(title: "Partial", prep: nil, cook: 20)
        let totalTime = recipe.totalTimeMinutes

        XCTAssertEqual(totalTime, 20)
    }

    // MARK: - Edge Cases

    func testEmptyArrayReturnsEmpty() {
        let sorted = sorter.sorted([])
        XCTAssertTrue(sorted.isEmpty)
    }

    func testSingleElementReturnsSameElement() {
        let recipes = [makeRecipe(title: "Only", prep: 10, cook: 10)]
        let sorted = sorter.sorted(recipes)

        XCTAssertEqual(sorted.count, 1)
        XCTAssertEqual(sorted.first?.dynamicTitle, "Only")
    }

    func testTotalTimeCalculation() {
        let recipe = makeRecipe(title: "Test", prep: 15, cook: 140)
        XCTAssertEqual(recipe.totalTimeMinutes, 155)
    }

    // MARK: - Helpers

    private func makeRecipe(title: String, prep: Int?, cook: Int?) -> Recipe {
        let details: RecipeDetails?
        if prep != nil || cook != nil {
            details = RecipeDetails(
                amountLabel: nil,
                amountNumber: nil,
                prepLabel: nil,
                prepTime: nil,
                prepNote: nil,
                cookingLabel: nil,
                cookingTime: nil,
                cookTimeAsMinutes: cook,
                prepTimeAsMinutes: prep
            )
        } else {
            details = nil
        }

        return Recipe(
            dynamicTitle: title,
            dynamicDescription: "",
            dynamicThumbnail: nil,
            dynamicThumbnailAlt: nil,
            recipeDetails: details,
            ingredients: nil
        )
    }
}
