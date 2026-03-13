import XCTest
import SnapshotTesting
import SwiftUI
@testable import ColesRecipes

final class RecipeSnapshotTests: XCTestCase {

    override func invokeTest() {
        // Set to true to record new reference snapshots, then set back to false
        // isRecording = true
        super.invokeTest()
    }

    func testRecipeDetailView_portrait() {
        let view = RecipeDetailView(recipe: .snapshotPreview)
            .frame(width: 393, height: 852)
            .background(Color.white)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13)
        )
    }

    func testRecipeCardView() {
        let view = RecipeCardView(recipe: .snapshotPreview)
            .frame(width: 200)
            .padding()
            .background(Color.white)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(size: CGSize(width: 232, height: 250))
        )
    }

    func testRecipeGridView_landscape() {
        let recipes = [Recipe.snapshotPreview, Recipe.snapshotPreview, Recipe.snapshotPreview]
        let view = RecipeGridView(
            recipes: recipes,
            isSorted: false,
            onToggleSort: {}
        )
        .frame(width: 852, height: 393)
        .background(Color.white)

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13(.landscape))
        )
    }
}
