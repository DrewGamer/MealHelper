# Feature Plan: Feature-First Architecture Migration

## Overview
Migrate the **MealHelper** codebase from a layer-first structure to a modern, scalable **Feature-First Architecture** following official Dart, Flutter, and Riverpod best practices.

### Core Goals:
1. **Feature-First Cohesion**: Group files by functional domain (`auth`, `meals`, `plans`, `ingredients`, `collaboration`, `settings`, `home`) so related code lives together.
2. **Provider Modularization**: Decompose the monolithic `lib/providers.dart` into scoped providers located directly alongside their corresponding feature/repository.
3. **Encapsulation**: Eliminate raw Firebase SDK (`FirebaseAuth.instance`, `FirebaseFirestore.instance`) leaks in UI screens (`SettingsScreen`) and services (`MealSyncService`) by funneling calls through repositories.
4. **Widget Decomposition**: Split giant screen files (`plan_screen.dart` [544 lines], `settings_screen.dart` [417 lines]) into focused screens and dialog widgets.
5. **Zero Behavior Change Guarantee**: 100% parity for all UI screens, user flows, database structures, and interactions.
6. **Repository & Test Hygiene**: Remove root scratch files (`test_calendar.dart`) and mirror the `test/` directory to match the feature structure.

---

## Architecture Blueprint

```
lib/
├── core/
│   ├── constants/
│   │   └── firestore_constants.dart           # Collection & field key constants
│   ├── utils/
│   │   └── string_extensions.dart             # Alphabetical sort helpers
│   ├── providers/
│   │   └── shared_preferences_provider.dart   # SharedPreferences provider
│   └── firebase_options.dart                  # Firebase platform configuration
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart           # Auth methods, authStateProvider, isAuthenticatingProvider
│   │   └── presentation/
│   │       ├── auth_wrapper.dart              # Auth router
│   │       ├── welcome_screen.dart            # Welcome/login entry
│   │       └── widgets/
│   │           └── email_password_dialog.dart # Reusable auth dialog
│   │
│   ├── collaboration/
│   │   ├── data/
│   │   │   └── workspace_repository.dart      # Workspaces, sharing, invite codes, streamActiveDatabaseId
│   │   └── presentation/
│   │       ├── collaboration_screen.dart      # Collaboration UI
│   │       └── widgets/
│   │           └── database_name_section.dart # Dedicated database rename widget
│   │
│   ├── ingredients/
│   │   ├── domain/
│   │   │   └── ingredient_options.dart        # IngredientOptions data model
│   │   ├── data/
│   │   │   └── ingredient_options_repository.dart # Protein & ingredient repo + streams
│   │   └── presentation/
│   │       └── ingredient_manager_screen.dart # Manager screen
│   │
│   ├── meals/
│   │   ├── domain/
│   │   │   ├── meal.dart                      # Meal data model
│   │   │   └── meal_sort_option.dart          # Sort enum & extension
│   │   ├── data/
│   │   │   ├── meals_repository.dart          # CRUD & mealsStreamProvider
│   │   │   └── meal_sort_notifier.dart        # Sort state notifier & provider
│   │   └── presentation/
│   │       ├── meals_list_screen.dart         # Main meals list
│   │       ├── meal_detail_screen.dart        # Add/edit meal screen
│   │       └── widgets/
│   │           └── ingredient_picker_dialog.dart # Ingredient checkbox picker
│   │
│   ├── plans/
│   │   ├── domain/
│   │   │   └── meal_plan.dart                 # MealPlan model & date utilities
│   │   ├── data/
│   │   │   └── plan_repository.dart           # Plan CRUD & plansStreamProvider
│   │   ├── application/
│   │   │   ├── meal_selection_engine.dart     # Auto-populate algorithms, Recency/Protein strategies
│   │   │   └── meal_sync_service.dart         # Meal lastUsed/nextUpcoming synchronizer
│   │   └── presentation/
│   │       ├── plan_screen.dart               # Calendar range creation & plan list
│   │       ├── meal_plan_detail_screen.dart   # Day-by-day meal assigner
│   │       └── widgets/
│   │           ├── auto_populate_bottom_sheet.dart # Algorithm options sheet
│   │           └── plan_conflict_dialog.dart  # Overlap resolution dialog
│   │
│   ├── settings/
│   │   └── presentation/
│   │       └── settings_screen.dart           # Account settings & links
│   │
│   └── home/
│       └── presentation/
│           └── home_screen.dart               # Bottom navigation scaffold
│
└── main.dart                                  # App bootstrap
```

---

## Layer Definitions

| Layer | Responsibility | Contents |
|---|---|---|
| **`domain/`** | Pure business models & calculation rules | Entities, models, enums (No Flutter widgets, no database SDKs) |
| **`application/`** | Workflow orchestration & business algorithms | Multi-repository services, selection engine, sync logic |
| **`data/`** | Data sources, repositories, serialization | Firestore CRUD, mappers, stream providers |
| **`presentation/`** | UI rendering & state handling | Screens, widgets, dialogs, UI Notifiers |
| **`core/`** | Shared across multiple features | Constants, global providers, utilities, Firebase config |

---

## Work Backlog (XP Tasks)

| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Core Foundation & Constants Setup | pending | xp-developer | - |
| T2 | Auth Feature Migration & Encapsulation | pending | xp-developer | T1 |
| T3 | Collaboration & Workspace Migration | pending | xp-developer | T1, T2 |
| T4 | Ingredients Feature Migration | pending | xp-developer | T1, T3 |
| T5 | Meals Feature Migration & Sort Notifier | pending | xp-developer | T1, T4 |
| T6 | Plans Feature & Engine Migration | pending | xp-developer | T1, T5 |
| T7 | Settings, Navigation & Main Bootstrap | pending | xp-developer | T2, T3, T4, T5, T6 |
| T8 | Test Suite Mirroring & Legacy Cleanup | pending | xp-developer | T7 |

---

## Task Details

### T1: Core Foundation & Constants Setup
- Create `lib/core/constants/firestore_constants.dart` containing collection and key strings.
- Relocate `lib/utils/string_extensions.dart` to `lib/core/utils/string_extensions.dart`.
- Extract `sharedPreferencesProvider` to `lib/core/providers/shared_preferences_provider.dart`.

### T2: Auth Feature Migration & Encapsulation
- Move `AuthRepository` to `lib/features/auth/data/auth_repository.dart`.
- Add helper methods to `AuthRepository`: `deleteCurrentUser()`, `createUserWithEmailAndPassword()`, `unlinkProvider()`.
- Move `authStateProvider`, `isAuthenticatingProvider`, and `IsAuthenticatingNotifier` into auth data module.
- Create `lib/features/auth/presentation/auth_wrapper.dart` (extracted from `main.dart`).
- Relocate `WelcomeScreen` and extract `EmailPasswordDialog`.

### T3: Collaboration & Workspace Migration
- Create `lib/features/collaboration/data/workspace_repository.dart` taking over database/workspace management from `database_repository.dart`.
- Expose `workspaceRepositoryProvider`, `activeDatabaseIdStreamProvider`, and `databaseNameProvider`.
- Relocate `CollaborationScreen` and extract `DatabaseNameSection` widget.

### T4: Ingredients Feature Migration
- Relocate `IngredientOptions` model to `lib/features/ingredients/domain/`.
- Relocate `IngredientOptionsRepository` to `lib/features/ingredients/data/` with its providers.
- Relocate `IngredientManagerScreen` to `lib/features/ingredients/presentation/`.

### T5: Meals Feature Migration & Sort Notifier
- Relocate `Meal` and `MealSortOption` to `lib/features/meals/domain/`.
- Create `lib/features/meals/data/meals_repository.dart` (CRUD + `mealsStreamProvider`).
- Create `lib/features/meals/data/meal_sort_notifier.dart` (`mealSortProvider`).
- Relocate `MealsListScreen` and `MealDetailScreen` to `lib/features/meals/presentation/`.
- Extract `IngredientPickerDialog` from `MealDetailScreen`.

### T6: Plans Feature & Engine Migration
- Relocate `MealPlan` to `lib/features/plans/domain/`.
- Relocate `PlanRepository` to `lib/features/plans/data/` with `plansStreamProvider`.
- Relocate `MealSelectionEngine`, `RecencyStrategy`, `VaryProteinStrategy`, and `mealSelectionEngineProvider` to `lib/features/plans/application/`.
- Relocate `MealSyncService` and `mealSyncServiceProvider` to `lib/features/plans/application/`.
- Relocate `PlanScreen` to `lib/features/plans/presentation/`.
- Extract `MealPlanDetailScreen` and `AutoPopulateBottomSheet` into separate files.

### T7: Settings, Navigation & Main Bootstrap
- Relocate `SettingsScreen` to `lib/features/settings/presentation/settings_screen.dart`, routing auth operations through `AuthRepository`.
- Relocate `HomeScreen` to `lib/features/home/presentation/home_screen.dart`.
- Update `lib/main.dart` to a clean bootstrap file.

### T8: Test Suite Mirroring & Legacy Cleanup
- Reorganize `test/` folder to mirror `lib/features/`:
  - `test/features/meals/domain/meal_test.dart`
  - `test/features/plans/domain/meal_plan_test.dart`
  - `test/features/plans/application/meal_selection_engine_test.dart`
  - `test/features/ingredients/domain/ingredient_options_test.dart`
- Delete `test_calendar.dart`.
- Delete `lib/providers.dart`.
- Delete legacy directories (`lib/application/`, `lib/data/`, `lib/domain/`, `lib/presentation/`, `lib/utils/`).
- Run `flutter analyze` and `flutter test`.

---

## Verification Criteria

1. **Automated Verification**:
   - `flutter analyze` completes with 0 errors, 0 warnings, and 0 lints.
   - `flutter test` completes with 100% pass rate across all unit and engine tests.
2. **Manual Regression Checks**:
   - Tab switching across Plan, Meals, Ingredients, Settings.
   - Adding, editing, deleting meals and selecting ingredients.
   - Adding, renaming, deleting protein sources and verifying cascade updates.
   - Creating meal plan date ranges, handling overlaps, assigning meals, auto-populating slots.
   - Switching active workspaces and sharing invite codes.
