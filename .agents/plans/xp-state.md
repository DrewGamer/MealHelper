# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Smart Auto-Populate for Meal Plans
**Current Stage:** Phase 2: XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Introduce a "Smart Auto-Populate" feature for meal plans allowing users to randomly assign meals to empty days, guided by extensible filter/sort toggles. Initially, prioritize meals not eaten recently and not scheduled for the near future.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **`Meal` Document Updates**: Denormalize usage data onto the `Meal` document (`lastUsedDate` and `nextUpcomingDate`).
2. **`MealSyncService`**: Intercept modifications to `MealPlan` items. On addition, pessimistically update meal usage timestamps. On removal/deletion, query active plans and recalculate true dates to write back.
3. **`MealSelectionEngine`**: A Strategy Pipeline accepting empty slots, available meals, and active `SelectionStrategy` toggles. Initial toggle is `RecencyStrategy` penalizing recent/upcoming meals. Uses a random weighted selector to pick top-scoring meals.
4. **UI Updates**: `AutoPopulateConfigBottomSheet` for toggles and "Auto-Fill" action button in `MealPlanDetailsView`.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore
- shared_preferences

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Data Model Updates (lastUsedDate, nextUpcomingDate) | done | xp-developer | - |
| T2 | MealSyncService - Addition Handling | done | xp-developer | T1 |
| T3 | MealSyncService - Removal/Deletion Recalculation | done | xp-developer | T2 |
| T4 | MealSelectionEngine & RecencyStrategy | done | xp-developer | T1 |
| T5 | UI - AutoPopulateConfigBottomSheet | done | xp-developer | T4 |
| T6 | UI - MealPlanDetailsView Auto-Fill Integration | done | xp-developer | T5 |

## 5. Sub-Agent Coordination
Implementing Smart Auto-Populate feature with Strategy Pattern for selection and recalculation logic for meal usage dates.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR 1 Reviewed & Approved
- [x] Release Package Generated (Continuous Build APK uploaded to tag continuous-build)

## 7. Release Configuration
**Continuous Release Tag:** continuous-build
**Continuous Release Name:** Continuous Build
**Build Type Override:**
