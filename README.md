# ColesRecipes

A SwiftUI iOS app that displays recipe content from a JSON dataset, built for the Coles App Engineering Coding Exercise.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Getting Started

```bash
# Generate the Xcode project
xcodegen generate

# Open in Xcode
open ColesRecipes.xcodeproj
```

The `.xcodeproj` is generated from `project.yml` and excluded from git.

## Architecture

**MVVM (Model-View-ViewModel)** with clear separation of concerns:

```
Models/          → Codable data models (Recipe, RecipeDetails, Ingredient)
Utilities/       → RecipeSorter with injectable RecipeSorting protocol
ViewModels/      → RecipeViewModel with ViewState enum (loading/portrait/landscape/error)
Views/           → SwiftUI views (ContentView, RecipeDetailView, RecipeGridView, RecipeCardView)
```

### Key Architectural Decisions

1. **ViewState enum with orientation baked in** — The `ViewState` enum includes `.portrait(Recipe)` and `.landscape([Recipe])` cases, so the view switches on a single state property rather than checking orientation separately. This keeps the view layer simple and makes state transitions explicit.

2. **Protocol-based dependency injection** — `RecipeSorting` protocol allows the ViewModel to accept a mock sorter in tests, making the sorting logic independently testable without coupling to a concrete implementation.

3. **GeometryReader for orientation detection** — Uses a background `GeometryReader` to detect size changes and determine orientation (`width > height`). This avoids interfering with the content layout while reliably tracking rotation.

4. **Optional model fields** — All model properties that could be missing are `Optional`, following the brief's requirement to handle incomplete data gracefully. Image URLs return `nil` when the thumbnail path is missing.

### Algorithm: Sort by Total Time

Recipes can be sorted by total time (prep + cooking minutes) in the landscape grid view. The `RecipeSorter` computes `totalTimeMinutes` from `prepTimeAsMinutes + cookTimeAsMinutes`, sorting ascending. Recipes with missing time data sort to the end.

## Trade-offs

- **Local JSON only** — The app loads data synchronously from the bundle. In production, this would use `async/await` with a network layer and caching.
- **No navigation in portrait** — Per the brief, portrait shows the first recipe only. With more time, tapping a card in landscape could navigate to a detail view.
- **AsyncImage without caching** — Uses SwiftUI's built-in `AsyncImage` which doesn't cache across recompositions. A production app would use a dedicated image caching library (e.g., Kingfisher, Nuke).
- **Snapshot tests require reference images** — First run with `isRecording = true` generates baseline snapshots. CI would need stored reference images.
- **Portrait upside down not supported** — Modern iPhones (without home button) do not support portrait upside down at the OS level.

## Accessibility

1. **Accessibility labels** — Images use `dynamicThumbnailAlt` text for VoiceOver descriptions. Recipe detail rows have combined descriptive labels.
2. **Dynamic Type** — All text uses semantic font styles (`.title2`, `.body`, `.caption`) that scale with the user's preferred text size. `@ScaledMetric` is used for custom spacing.
3. **VoiceOver grouping** — Recipe detail rows (Serves/Prep/Cooking) use `accessibilityElement(children: .combine)` so VoiceOver reads them as a single coherent element. Decorative bullet points are hidden with `accessibilityHidden(true)`.

## What I Would Improve With More Time

- Add a network layer with proper `async/await` data fetching and error retry logic
- Implement image caching (Nuke or Kingfisher)
- Add navigation from landscape grid cards to detail views
- Support iPad with multi-column adaptive layouts
- Add loading shimmer/skeleton views
- Expand test coverage with more edge cases and integration tests
- Add Dark Mode support with proper colour assets
- Implement search and filtering
- Add animations for orientation transitions

## Running Tests

Generate the project with `xcodegen generate`, open in Xcode, and press `Cmd+U`.

- **Unit tests** (16 tests): RecipeSorter logic, ViewModel state management, JSON decoding, image URL construction
- **Snapshot tests**: RecipeDetailView, RecipeCardView, RecipeGridView (requires `swift-snapshot-testing` SPM package; set `isRecording = true` on first run to generate reference images)
