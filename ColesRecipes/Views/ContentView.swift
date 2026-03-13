import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeViewModel()

    var body: some View {
        contentForState
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewModel.updateOrientation(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                        }
                        .onChange(of: geometry.size) { _, newSize in
                            viewModel.updateOrientation(width: newSize.width, height: newSize.height)
                        }
                }
            }
            .task {
                viewModel.loadRecipes()
            }
    }

    @ViewBuilder
    private var contentForState: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading recipes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))

        case .portrait(let recipe):
            RecipeDetailView(recipe: recipe)

        case .landscape(let recipes):
            RecipeGridView(
                recipes: recipes,
                isSorted: viewModel.isSortedByTime,
                onToggleSort: { viewModel.toggleSort() }
            )

        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") {
                    viewModel.loadRecipes()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

#Preview("Portrait", traits: .portrait) {
    ContentView()
}

#Preview("Landscape", traits: .landscapeLeft) {
    ContentView()
}
