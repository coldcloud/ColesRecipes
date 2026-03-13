import SwiftUI

struct RecipeGridView: View {
    let recipes: [Recipe]
    let isSorted: Bool
    let onToggleSort: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(recipes) { recipe in
                        RecipeCardView(recipe: recipe)
                    }
                }
                .padding()
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onToggleSort()
                    } label: {
                        Label(
                            isSorted ? "Original Order" : "Sort by Time",
                            systemImage: isSorted ? "arrow.counterclockwise" : "clock.arrow.2.circlepath"
                        )
                    }
                    .accessibilityLabel(isSorted ? "Show original order" : "Sort recipes by total cooking time")
                }
            }
        }
    }
}

#Preview {
    RecipeGridView(
        recipes: [.preview, .preview],
        isSorted: false,
        onToggleSort: {}
    )
}
