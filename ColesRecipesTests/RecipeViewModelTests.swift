import XCTest
@testable import ColesRecipes

final class RecipeViewModelTests: XCTestCase {

    // MARK: - Image URL

    func testImageURLPrependsBaseURL() {
        let recipe = Recipe(
            dynamicTitle: "Test",
            dynamicDescription: "",
            dynamicThumbnail: "/content/dam/coles/test.jpg",
            dynamicThumbnailAlt: nil,
            recipeDetails: nil,
            ingredients: nil
        )

        XCTAssertEqual(
            recipe.imageURL?.absoluteString,
            "https://coles.com.au/content/dam/coles/test.jpg"
        )
    }

    func testImageURLIsNilWhenThumbnailIsNil() {
        let recipe = Recipe(
            dynamicTitle: "Test",
            dynamicDescription: "",
            dynamicThumbnail: nil,
            dynamicThumbnailAlt: nil,
            recipeDetails: nil,
            ingredients: nil
        )

        XCTAssertNil(recipe.imageURL)
    }

    // MARK: - ViewModel State

    @MainActor
    func testInitialStateIsLoading() {
        let viewModel = RecipeViewModel()
        XCTAssertEqual(viewModel.state, .loading)
    }

    @MainActor
    func testToggleSortFlipsFlag() {
        let viewModel = RecipeViewModel()
        XCTAssertFalse(viewModel.isSortedByTime)

        viewModel.toggleSort()
        XCTAssertTrue(viewModel.isSortedByTime)

        viewModel.toggleSort()
        XCTAssertFalse(viewModel.isSortedByTime)
    }

    // MARK: - Sorting Integration

    @MainActor
    func testToggleSortUsesMockSorter() {
        let mockSorter = MockRecipeSorter()
        let viewModel = RecipeViewModel(sorter: mockSorter)

        // Simulate loading recipes by setting landscape state
        viewModel.loadRecipes()
        viewModel.updateOrientation(width: 800, height: 400)
        viewModel.toggleSort()

        XCTAssertTrue(mockSorter.sortedWasCalled)
    }

    // MARK: - Total Time

    func testTotalTimeWithBothValues() {
        let recipe = makeRecipe(prep: 15, cook: 30)
        XCTAssertEqual(recipe.totalTimeMinutes, 45)
    }

    func testTotalTimeWithNilDetails() {
        let recipe = Recipe(
            dynamicTitle: "Test",
            dynamicDescription: "",
            dynamicThumbnail: nil,
            dynamicThumbnailAlt: nil,
            recipeDetails: nil,
            ingredients: nil
        )
        XCTAssertNil(recipe.totalTimeMinutes)
    }

    // MARK: - JSON Decoding

    func testDecodesRecipeFromJSON() throws {
        let json = """
        {
            "dynamicTitle": "Test Recipe",
            "dynamicDescription": "Desc",
            "dynamicThumbnail": "/test.jpg",
            "dynamicThumbnailAlt": "Alt text",
            "recipeDetails": {
                "amountLabel": "Serves",
                "amountNumber": 4,
                "prepLabel": "Prep",
                "prepTime": "15m",
                "cookingLabel": "Cooking",
                "cookingTime": "30m",
                "cookTimeAsMinutes": 30,
                "prepTimeAsMinutes": 15
            },
            "ingredients": [
                {"ingredient": "1 cup flour"}
            ]
        }
        """

        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(Recipe.self, from: data)

        XCTAssertEqual(recipe.dynamicTitle, "Test Recipe")
        XCTAssertEqual(recipe.recipeDetails?.amountNumber, 4)
        XCTAssertEqual(recipe.ingredients?.count, 1)
        XCTAssertEqual(recipe.totalTimeMinutes, 45)
    }

    func testDecodesRecipeWithMissingOptionalFields() throws {
        let json = """
        {
            "dynamicTitle": "Minimal Recipe",
            "dynamicDescription": "No extras"
        }
        """

        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(Recipe.self, from: data)

        XCTAssertEqual(recipe.dynamicTitle, "Minimal Recipe")
        XCTAssertNil(recipe.dynamicThumbnail)
        XCTAssertNil(recipe.recipeDetails)
        XCTAssertNil(recipe.ingredients)
    }

    // MARK: - Helpers

    private func makeRecipe(prep: Int, cook: Int) -> Recipe {
        Recipe(
            dynamicTitle: "Test",
            dynamicDescription: "",
            dynamicThumbnail: nil,
            dynamicThumbnailAlt: nil,
            recipeDetails: RecipeDetails(
                amountLabel: nil,
                amountNumber: nil,
                prepLabel: nil,
                prepTime: nil,
                prepNote: nil,
                cookingLabel: nil,
                cookingTime: nil,
                cookTimeAsMinutes: cook,
                prepTimeAsMinutes: prep
            ),
            ingredients: nil
        )
    }
}

// MARK: - Mock

final class MockRecipeSorter: RecipeSorting {
    var sortedWasCalled = false

    func sorted(_ recipes: [Recipe]) -> [Recipe] {
        sortedWasCalled = true
        return recipes.reversed()
    }
}
