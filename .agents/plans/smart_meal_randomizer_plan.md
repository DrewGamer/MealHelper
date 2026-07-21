# Feature Plan: Smart Meal Randomizer

## Overview
Add the ability to randomly assign meals to the weekly plan with optional smart toggles that refine how meals are selected. This transforms the weekly plan from a fully manual process into a one-tap experience with intelligent variety.

## Current State (What We Have)

| Asset | Relevant Fields | Notes |
|---|---|---|
| [meal.dart](file:///C:/SourceCode/MealHelper/lib/domain/models/meal.dart) | `tags` (free-form list), `lastUsedDate` | `lastUsedDate` exists but is **never updated** — it's always `null` in practice |
| [weekly_plan.dart](file:///C:/SourceCode/MealHelper/lib/domain/models/weekly_plan.dart) | `mealIdsByDay` (Map\<int, String\>) | Maps day offset (0–6) → meal ID |
| [meal_detail_screen.dart](file:///C:/SourceCode/MealHelper/lib/presentation/screens/meal_detail_screen.dart) | Tags entered as free-form comma-separated text | No structured protein/ingredient fields |

---

## Design Decisions to Resolve

> [!IMPORTANT]
> These are the key decisions that should be confirmed before implementation begins.

### 1. Protein Source & Ingredients — Structured Fields vs. Tags

**Option A: Add dedicated fields to the Meal model** *(Recommended)*
- Add `proteinSource` (single string, e.g. "Chicken", "Beef", "Tofu", "Fish")
- Add `ingredients` (list of strings)
- Pro: Clean filtering logic, easy to build toggle UIs against
- Con: Requires Meal model migration + UI updates to the Add/Edit Meal screen

**Option B: Use a tag convention** (e.g. `protein:chicken`, `ingredient:rice`)
- Pro: No model changes needed
- Con: Fragile — relies on users following a naming convention, harder to build reliable toggles

**Option C: Hybrid — Structured `proteinSource` field + keep `tags` for general ingredients**
- Pro: Gets the best of both — protein is a first-class concept (dropdown/picker), while general ingredients stay flexible as tags
- Con: Slightly more model changes than Option B

### 2. "Last Eaten" Tracking — When to Update

Currently `lastUsedDate` exists on the `Meal` model but is never written to. We need to decide *when* it gets stamped:

- **Option A**: Update `lastUsedDate` when a meal is assigned to a plan *(simpler, immediate)*
- **Option B**: Update `lastUsedDate` when the plan's day actually passes *(more accurate, requires a background check or manual "mark as eaten" button)*
- **Option C**: Both — stamp on assignment, but allow the user to "mark as eaten" to refine it *(most flexible but more UI)*

### 3. Scope of Randomization

- Fill **all 7 days** at once, or let the user pick which days to auto-fill? (e.g. only fill empty slots)
- Should the randomizer respect days that already have a meal assigned? (i.e. "Fill remaining" mode)

---

## Proposed Implementation Phases

### Phase A: Meal Model Enhancements (T9)
**Goal:** Extend the `Meal` model with structured data needed for smart randomization.

| Change | Details |
|---|---|
| Add `proteinSource` field to `Meal` | Nullable `String?`, e.g. "Chicken", "Beef", "Pork", "Fish", "Tofu", "Vegetarian", "Other" |
| Start writing `lastUsedDate` | Update the field whenever a meal is assigned to a weekly plan slot |
| Update `MealDetailScreen` | Add a protein source dropdown/picker to the Add/Edit Meal form |
| Firestore migration | Existing meals get `proteinSource: null` (graceful — the randomizer just skips the protein filter for untagged meals) |

### Phase B: Randomizer Engine (T10)
**Goal:** Build the core randomization logic as a standalone service/utility.

```
class MealRandomizer {
  /// Given a pool of meals and toggle settings, returns
  /// a Map<int, String> of dayOffset → mealId assignments.
  Map<int, String> generatePlan({
    required List<Meal> availableMeals,
    required Set<int> daysToFill,       // which day offsets to randomize
    bool preferLeastRecent = false,      // Toggle 1: prioritize older lastUsedDate
    bool varyByProtein = false,          // Toggle 2: avoid back-to-back same protein
    Map<int, String>? existingAssignments, // preserve already-assigned days
  });
}
```

**Algorithm sketch:**
1. Start with the full meal pool
2. If `preferLeastRecent` is on → sort/weight by `lastUsedDate` (nulls first, then oldest first)
3. For each day to fill:
   - If `varyByProtein` is on → exclude meals with the same `proteinSource` as the previous day's pick
   - Pick from the remaining pool (weighted random if `preferLeastRecent`, uniform random otherwise)
   - Remove the pick from the pool to avoid duplicates within the same week
4. Return the map of assignments

### Phase C: Randomizer UI (T11)
**Goal:** Add a "Randomize" button to the `WeeklyPlanScreen` with a toggle sheet.

**UX Flow:**
1. User taps a new **🎲 Randomize** FAB or button on the Weekly Plan screen
2. A bottom sheet or dialog appears with:
   - **"Fill empty days only"** checkbox (default: on)
   - **"Prefer meals I haven't had recently"** toggle
   - **"Vary by protein source"** toggle
3. User taps **"Generate"**
4. The plan updates with randomized meals
5. `lastUsedDate` is stamped on each newly assigned meal
6. User can still manually swap individual days after randomization

---

## Updated Backlog (Proposed)

| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T9 | Meal Model Enhancements (protein source + lastUsedDate tracking) | pending | xp-developer | T5 |
| T10 | Randomizer Engine | pending | xp-developer | T9 |
| T11 | Randomizer UI + Toggle Sheet | pending | xp-developer | T10 |

---

## Open Questions

1. **Protein source list** — Should this be a fixed set of options (dropdown) or free-text? A fixed set makes the "vary by protein" toggle much more reliable.
2. **Ingredient-level variety** — Should this be a separate toggle from protein, or is protein variety sufficient for v1? Adding full ingredient variety significantly increases complexity (need structured ingredient lists, fuzzy matching, etc.).
3. **Fill scope** — Should "Randomize" always fill all 7 days, or should it default to only filling empty slots?
4. **Re-roll** — Should users be able to re-roll a single day (tap a day → "Randomize this day") in addition to the bulk randomize?
