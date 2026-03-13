import Foundation

enum ViewState: Equatable {
    case loading
    case portrait(Recipe)
    case landscape([Recipe])
    case error(String)
}

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Published var isSortedByTime: Bool = false

    private var recipes: [Recipe] = []
    private var isLandscape: Bool = false
    private let sorter: RecipeSorting

    init(sorter: RecipeSorting = RecipeSorter()) {
        self.sorter = sorter
    }

    func loadRecipes() {
        state = .loading

        guard let url = Bundle.main.url(forResource: "recipesSample", withExtension: "json") else {
            state = .error("Could not find recipe data.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
            recipes = response.recipes
            updateState()
        } catch {
            state = .error("Failed to load recipes: \(error.localizedDescription)")
        }
    }

    func updateOrientation(width: CGFloat, height: CGFloat) {
        let newIsLandscape = width > height
        guard newIsLandscape != isLandscape || state == .loading else { return }
        isLandscape = newIsLandscape
        updateState()
    }

    func toggleSort() {
        isSortedByTime.toggle()
        updateState()
    }

    private func updateState() {
        guard !recipes.isEmpty else {
            if case .loading = state { return }
            state = .error("No recipes available.")
            return
        }

        if isLandscape {
            let displayRecipes = isSortedByTime ? sorter.sorted(recipes) : recipes
            state = .landscape(displayRecipes)
        } else {
            if let first = recipes.first {
                state = .portrait(first)
            }
        }
    }
}
