# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Smart Auto-Populate for Meal Plans
**Current Stage:** Phase 2: XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add a new "Vary Protein Source" toggle for auto-filling meals. Ensure the `MealSelectionEngine` can handle multiple active strategies concurrently (e.g., Recency and Protein Variety) to balance their constraints.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **`Meal` Document Updates**: Denormalize usage data onto the `Meal` document (`lastUsedDate` and `nextUpcomingDate`).
2. **`MealSyncService`**: Intercept modifications to `MealPlan` items. On addition, pessimistically update meal usage timestamps. On removal/deletion, query active plans and recalculate true dates to write back.
3. **`MealSelectionEngine`**: A Strategy Pipeline accepting empty slots, available meals, and active `SelectionStrategy` toggles. Currently supports `RecencyStrategy`. We will add `VaryProteinStrategy` which penalizes meals sharing a protein source with recently assigned meals.
4. **UI Updates**: `AutoPopulateConfigBottomSheet` will include multiple toggles (Recency, Vary Protein).

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
| T7 | Core - Update MealSelectionEngine for chunking & consecutive days | done | xp-developer | - |
| T8 | UI - Add dropdown to AutoPopulateConfigBottomSheet | done | xp-developer | T7 |
| T9 | UI - Overflow Dialog logic in PlanScreen | done | xp-developer | T8 |
| T10 | Core - Create VaryProteinStrategy | done | xp-developer | - |
| T11 | UI - Add Vary Protein toggle to AutoPopulateConfigBottomSheet | done | xp-developer | T10 |
| T12 | State - Update providers to pass multiple active strategies to Engine | done | xp-developer | T11 |

## 5. Sub-Agent Coordination
Implementing Smart Auto-Populate feature with Strategy Pattern for selection and recalculation logic for meal usage dates.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR 1 Reviewed & Approved
- [x] Release Package Generated (Continuous Build APK uploaded to tag continuous-build)
- [x] Architecture Approved for Consecutive Days Feature
- [x] Consecutive Days Feature Developed

## 7. Release Configuration
**Continuous Release Tag:** continuous-build
**Continuous Release Name:** Continuous Build
**Build Type Override:**
