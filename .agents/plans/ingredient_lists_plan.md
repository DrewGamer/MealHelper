# Feature Plan: User-Managed Ingredient Lists (Final)

## Overview
Add user-managed ingredient lists (per workspace) with two categories: **Protein Sources** and **Ingredients**. These custom lists populate dropdown/picker controls when creating or editing meals, replacing the current free-form tags approach with structured, reusable data. This lays the groundwork for the future Smart Meal Randomizer.

---

## Current State

| Asset | Current Behavior |
|---|---|
| [meal.dart](file:///C:/SourceCode/MealHelper/lib/domain/models/meal.dart) | Has `tags` (free-form comma-separated strings). No structured protein or ingredient fields. |
| [meal_detail_screen.dart](file:///C:/SourceCode/MealHelper/lib/presentation/screens/meal_detail_screen.dart) | Single `TextFormField` for tags. No dropdowns or pickers. |
| [home_screen.dart](file:///C:/SourceCode/MealHelper/lib/presentation/screens/home_screen.dart) | 3 bottom tabs: Plan, Meals, Settings. |
| Firestore schema | No collection for user-defined ingredient options. |

---

## Firestore Schema Addition

A single document per workspace stores the user-managed option lists:

```
databases/{dbId}/settings/ingredient_options
├── proteinSources: ["Chicken", "Beef", "Pork", "Fish", ...]    (Array<String>)
└── ingredients: ["Rice", "Pasta", "Potatoes", "Broccoli", ...]  (Array<String>)
```

> [!NOTE]
> Using a single document keeps reads cheap (1 read to get both lists) and Firestore array operations (`arrayUnion`, `arrayRemove`) make add/remove atomic and safe for concurrent collaborators.

---

## Meal Model Changes

```dart
class Meal {
  final String id;
  final String name;
  final String description;
  final String? proteinSource;      // NEW — single-select from workspace list
  final List<String> ingredients;   // NEW — multi-select from workspace list
  final DateTime? lastUsedDate;
  final String createdBy;
}
```

| Field | Selection | Source |
|---|---|---|
| `proteinSource` | Single-select (dropdown) | Workspace's `proteinSources` list |
| `ingredients` | Multi-select (chip picker) | Workspace's `ingredients` list |

> [!IMPORTANT]
> **Tags field removed.** The existing `tags` field will be dropped from the model and UI. The structured `proteinSource` and `ingredients` fields fully replace its purpose.

> [!NOTE]
> **Migration:** Existing meals will have `proteinSource: null` and `ingredients: []`. This is gracefully handled — the fields are optional and the UI will simply show them as empty/unset until the user edits the meal. The `tags` field in Firestore documents will be left in place (ignored) — no destructive migration needed.

---

## New Screen: Ingredient Manager

**Navigation:** 4th bottom tab in `HomeScreen` — positioned between "Meals" and "Settings".

```
[Plan]  [Meals]  [Ingredients]  [Settings]
                   🍽️ / 🔪
```

> [!TIP]
> **Icon choice:** Using an inclusive, food-general icon (e.g. `Icons.kitchen`, `Icons.egg_alt`, `Icons.set_meal`, or `Icons.restaurant`) rather than a meat-specific icon. Final icon will be chosen during implementation from Flutter's Material icon set for the best visual fit.

> [!NOTE]
> If user feedback later prefers 3 tabs, this can be moved to an AppBar button on the Meals screen in ~10 lines of code.

### Screen Layout

```
┌─────────────────────────────────┐
│  AppBar: "Ingredients"          │
├─────────────────────────────────┤
│  Section Header: PROTEIN SOURCES│
│  ┌─────────────────────────┐    │
│  │ Chicken           ✏️  ✕ │    │
│  │ Beef              ✏️  ✕ │    │
│  │ Pork              ✏️  ✕ │    │
│  │ Fish              ✏️  ✕ │    │
│  │ [+ Add Protein Source]  │    │
│  └─────────────────────────┘    │
│                                 │
│  Section Header: INGREDIENTS    │
│  ┌─────────────────────────┐    │
│  │ Rice              ✏️  ✕ │    │
│  │ Pasta             ✏️  ✕ │    │
│  │ Potatoes          ✏️  ✕ │    │
│  │ Broccoli          ✏️  ✕ │    │
│  │ [+ Add Ingredient]     │    │
│  └─────────────────────────┘    │
│                                 │
│  (empty state hint when no      │
│   items: "Tap + to add your     │
│   first protein source /        │
│   ingredient")                  │
└─────────────────────────────────┘
```

### Behaviors

- **Add:** Tapping "+ Add" opens a simple text input dialog
- **Edit (✏️):** Tapping the edit icon opens a text input dialog pre-filled with the current name. On save:
  - The name is updated in the `ingredient_options` document
  - **All meals referencing the old name are cascade-updated** to the new name (batch write)
- **Delete (✕):** Tapping the delete icon triggers a **confirmation dialog** that:
  - Lists the meals currently using this ingredient (if any)
  - Warns the user: *"This ingredient will be removed from X meals. Are you sure?"*
  - On confirm: removes the ingredient from the options list **and** from all meals referencing it (batch write)
  - If no meals use it: simpler confirmation — *"Delete 'Rice'?"*
- **Real-time sync:** Firestore `snapshots()` stream — collaborators see changes instantly
- **Alphabetical sort:** Options are displayed sorted alphabetically for easy scanning
- **No starter data:** Lists start empty with helpful hint text

> [!NOTE]
> **Future extensibility:** Additional sorting methods (e.g. most-used, recently added, custom drag-to-reorder) can be added later behind a sort toggle button in the AppBar without major refactoring.

---

## Meal Detail Screen Updates

The [MealDetailScreen](file:///C:/SourceCode/MealHelper/lib/presentation/screens/meal_detail_screen.dart) gets two new input controls and loses the tags field:

### Protein Source — Dropdown
```
┌─────────────────────────────────┐
│  Protein Source (optional)      │
│  ┌─────────────────────────┐    │
│  │ Chicken            ▼    │    │
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```
- `DropdownButtonFormField` populated from the workspace's `proteinSources` list
- Includes a "None" / clear option
- If the list is empty, shows a hint: *"Add protein sources in the Ingredients tab"*

### Ingredients — Multi-Select Chips
```
┌─────────────────────────────────┐
│  Ingredients (optional)         │
│  [Rice ✕] [Broccoli ✕] [+ Add] │
└─────────────────────────────────┘
```
- Tapping "+ Add" opens a dialog with checkboxes for all available ingredients
- Selected ingredients appear as dismissible `Chip` widgets
- If the list is empty, shows a hint: *"Add ingredients in the Ingredients tab"*

### Updated Form Field Order
```
1. Name (required)           — existing
2. Description               — existing  
3. Protein Source (dropdown)  — NEW
4. Ingredients (chips)        — NEW
5. [Save]                    — existing
```

> Tags field removed from the form.

---

## Implementation Phases

### T9: Data Layer — Ingredient Options & Meal Model

| Change | Details |
|---|---|
| Create `IngredientOptionsRepository` | New repository with CRUD methods for the `ingredient_options` document. Uses `arrayUnion`/`arrayRemove` for atomic add/remove. |
| Add `streamIngredientOptions()` | Returns a `Stream` of the current protein sources and ingredients lists. |
| Add `renameIngredient()` method | Renames in the options doc + batch-updates all meals referencing the old name. |
| Add `deleteIngredient()` method | Removes from the options doc + batch-removes from all meals referencing it. |
| Add `getMealsUsingIngredient()` method | Queries meals collection to find which meals reference a given ingredient (for the deletion confirmation dialog). |
| Update `Meal` model | Add `proteinSource` (String?) and `ingredients` (List\<String\>). Remove `tags`. Update `toMap`/`fromMap`/`copyWith`. |
| Add Riverpod providers | `ingredientOptionsRepositoryProvider` and `ingredientOptionsStreamProvider`. |

### T10: Ingredient Manager UI

| Change | Details |
|---|---|
| Create `IngredientManagerScreen` | Two-section scrollable list with add / edit / delete for both categories. |
| Update `HomeScreen` | Add 4th bottom tab ("Ingredients" with a food-inclusive icon). |
| Real-time streaming | UI watches `ingredientOptionsStreamProvider` for live updates. |
| Edit dialog | Text input dialog pre-filled with current name; triggers cascade-rename on save. |
| Delete confirmation | Dialog listing affected meals; triggers cascade-remove on confirm. |
| Empty state hints | Helpful text when lists are empty (e.g. *"Tap + to add your first protein source"*). |

### T11: Meal Form Integration

| Change | Details |
|---|---|
| Update `MealDetailScreen` | Add protein source dropdown and ingredient chip picker. Remove tags `TextFormField`. |
| Wire to workspace data | Dropdowns populated from `ingredientOptionsStreamProvider`. |
| Save/load | `_saveMeal()` writes the new fields; editing a meal pre-populates the selections. |
| Empty state hints | If no options exist yet, show helpful text pointing to the Ingredients tab. |

---

## Updated Backlog (Proposed)

| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T9 | Data Layer: Ingredient Options & Meal Model Enhancements | pending | xp-developer | T5 |
| T10 | Ingredient Manager UI (4th bottom tab) | pending | xp-developer | T9 |
| T11 | Meal Form Integration (protein dropdown + ingredient chips) | pending | xp-developer | T9, T10 |

---

## Resolved Design Decisions

| Question | Decision |
|---|---|
| Keep existing `tags` field? | **No** — remove it. Structured fields replace its purpose. |
| Starter data for new workspaces? | **No** — start empty with hint text. |
| Cascade-update on rename? | **Yes** — batch-update all meals referencing the old name. |
| Cascade-remove on delete? | **Yes** — remove from all meals + show confirmation dialog listing affected meals. |
| Sort order? | **Alphabetical** for now. Additional sort methods can be added later. |
| Bottom tab icon? | **Food-inclusive** (e.g. `Icons.kitchen` or `Icons.set_meal`), not meat-specific. |
| Fallback to 3 tabs? | Easy ~10-line swap if user feedback prefers it. |
