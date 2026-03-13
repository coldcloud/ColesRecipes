import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    @ScaledMetric private var detailIconSize: CGFloat = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroImage
                recipeHeader
                detailsRow
                ingredientsList
            }
        }
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        AsyncImage(url: recipe.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                imagePlaceholder
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
            @unknown default:
                imagePlaceholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipped()
        .accessibilityLabel(recipe.dynamicThumbnailAlt ?? recipe.dynamicTitle)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }

    // MARK: - Header

    private var recipeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.dynamicTitle)
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text(recipe.dynamicDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Details Row

    private var detailsRow: some View {
        Group {
            if let details = recipe.recipeDetails {
                HStack(spacing: 0) {
                    if let label = details.amountLabel, let number = details.amountNumber {
                        detailItem(
                            label: label,
                            value: "\(number)",
                            accessibilityLabel: "\(label) \(number)"
                        )
                    }

                    if let label = details.prepLabel, let time = details.prepTime {
                        Divider().frame(height: 40)
                        detailItem(
                            label: label,
                            value: time,
                            note: details.prepNote,
                            accessibilityLabel: "\(label) \(time)\(details.prepNote.map { ", \($0)" } ?? "")"
                        )
                    }

                    if let label = details.cookingLabel, let time = details.cookingTime {
                        Divider().frame(height: 40)
                        detailItem(
                            label: label,
                            value: time,
                            accessibilityLabel: "\(label) \(time)"
                        )
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func detailItem(
        label: String,
        value: String,
        note: String? = nil,
        accessibilityLabel: String
    ) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            if let note = note {
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Ingredients

    private var ingredientsList: some View {
        Group {
            if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.title3)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(ingredients) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            Text(item.ingredient)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    RecipeDetailView(recipe: .preview)
}

// MARK: - Preview Helper

extension Recipe {
    static var preview: Recipe {
        Recipe(
            dynamicTitle: "Sample Recipe",
            dynamicDescription: "A delicious sample recipe for preview purposes.",
            dynamicThumbnail: "/content/dam/coles/sample.jpg",
            dynamicThumbnailAlt: "A sample dish",
            recipeDetails: RecipeDetails(
                amountLabel: "Serves",
                amountNumber: 4,
                prepLabel: "Prep",
                prepTime: "15m",
                prepNote: "+ cooling time",
                cookingLabel: "Cooking",
                cookingTime: "30m",
                cookTimeAsMinutes: 30,
                prepTimeAsMinutes: 15
            ),
            ingredients: [
                Ingredient(ingredient: "2 cups flour"),
                Ingredient(ingredient: "1 cup sugar"),
                Ingredient(ingredient: "3 eggs")
            ]
        )
    }

    /// Preview recipe with nil thumbnail so AsyncImage renders the placeholder deterministically.
    /// Use this in snapshot tests to avoid network-dependent flakiness.
    static var snapshotPreview: Recipe {
        Recipe(
            dynamicTitle: "Sample Recipe",
            dynamicDescription: "A delicious sample recipe for preview purposes.",
            dynamicThumbnail: nil,
            dynamicThumbnailAlt: "A sample dish",
            recipeDetails: RecipeDetails(
                amountLabel: "Serves",
                amountNumber: 4,
                prepLabel: "Prep",
                prepTime: "15m",
                prepNote: "+ cooling time",
                cookingLabel: "Cooking",
                cookingTime: "30m",
                cookTimeAsMinutes: 30,
                prepTimeAsMinutes: 15
            ),
            ingredients: [
                Ingredient(ingredient: "2 cups flour"),
                Ingredient(ingredient: "1 cup sugar"),
                Ingredient(ingredient: "3 eggs")
            ]
        )
    }
}
