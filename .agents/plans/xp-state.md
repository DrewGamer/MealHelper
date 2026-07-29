# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Flexible Meal Sorting
**Current Stage:** Phase 3: Intermediate Release Packaging
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add client-side alphabetical sorting for Meals on the Meals Screen and Assign Meal dialog, with a foundation for future sorting methods using an extensible enum and SharedPreferences.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **Sort Option Enum**: `MealSortOption` enum with `alphabetical` as the default.
2. **State Management**: `MealSortNotifier` exposed via `mealSortProvider` using `shared_preferences` to persist the preference.
3. **Sorting Extension**: `applySort(MealSortOption)` extension on `Iterable<Meal>` that delegates to standard Dart list sorting.
4. **UI Integration - Meals Screen**: Watch `mealSortProvider`, apply sorting to `mealsStreamProvider` before passing to `ListView.builder`. Add a sorting toggle in the AppBar.
5. **UI Integration - Assign Meal Dialog**: Watch `mealSortProvider` in `MealPlanDetailScreen._assignMeal()`, apply sorting to `allMeals` before populating `AlertDialog`.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore
- shared_preferences

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Create MealSortOption enum | done | xp-developer | - |
| T2 | Create applySort extension on Iterable<Meal> | done | xp-developer | T1 |
| T3 | Create MealSortNotifier and mealSortProvider with SharedPreferences | done | xp-developer | T2 |
| T4 | Update MealsListScreen to apply sorting | done | xp-developer | T3 |
| T5 | Update MealPlanDetailScreen._assignMeal to apply sorting | done | xp-developer | T3 |

## 5. Sub-Agent Coordination
Implementing Flexible Meal Sorting using an extensible enum and Riverpod state management.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR 1 Reviewed & Approved
- [x] Release Package Generated (Continuous Build APK uploaded to tag continuous-build)
- [x] Consecutive Days Feature Developed
- [x] Vary Protein Source Feature Developed
- [x] Final Release Created: v0.11.0-beta

## 7. Release Configuration
**Continuous Release Tag:** continuous-build
**Continuous Release Name:** Continuous Build
**Build Type Override:**
