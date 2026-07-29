# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Exclude Meal from Auto-Generation
**Current Stage:** Phase 2: XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add a toggle to exclude a meal from auto-generation in the meal edit/add screen and apply it during auto-fill.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **Model / Database Updates**: Add `excludeFromAuto` (bool, default false) to `Meal` model, serialization, and `copyWith`. Update `meal_test.dart`.
2. **UI Updates**: Add `SwitchListTile` to `_MealDetailScreenState` for "Exclude from auto-generation".
3. **Logic Updates**: Update `meal_selection_engine.dart` `populateSlots` to filter out `m.excludeFromAuto`.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Update `Meal` model and tests | complete | xp-developer | - |
| T2 | Update `_MealDetailScreenState` UI and save logic | complete | xp-developer | T1 |
| T3 | Update `meal_selection_engine.dart` to filter meals | complete | xp-developer | T1 |

## 5. Sub-Agent Coordination
Implementing "Exclude from auto-generation" toggle in Meal Edit screen and applying in auto-generation engine.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR Reviewed & Approved
- [x] Release Package Generated (Continuous Build APK uploaded to tag continuous-build)
- [ ] Release Gate Passed

## 7. Release Configuration
**Continuous Release Tag:** continuous-build
**Continuous Release Name:** Continuous Build
**Build Type Override:**
