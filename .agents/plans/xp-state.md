# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Retrieve Past or Future Meal Plans in Plan Tab
**Current Stage:** XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Refactor meal plan logic to use a flexible start date chosen by the user, remove the global week start day, remove scrolling week widgets, and handle overlap conflicts by pulling overlapping days into the new plan.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **Flexible Meal Plan Model**: Abandon the fixed global "week start day". A `MealPlan` is defined strictly by its `startDate` (chosen at creation) and an `endDate` (or fixed duration like 7 days). Remove `weekStartDayProvider` and related global settings.
2. **UI/UX Paradigm Shift (Plan Tab)**: Remove the `ScrollingWeekWidget`. Replace the main Plan Tab view with a vertically scrolling list of `MealPlan` cards, sorted chronologically. Creating a new plan will prompt the user to select a specific `startDate` via a date picker.
3. **Overlap Detection & Resolution Strategy**: Before saving a new `MealPlan`, the system queries existing plans for date intersections. If an overlap is detected, the UI intercepts the creation with a warning dialog.
4. **Data Migration / Pull Mutation**: If the user agrees to the overlap warning, the system "Pulls" existing meals on overlapping dates to the new `MealPlan`, and truncates/deletes the older `MealPlan`.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore
- shared_preferences

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Data Model & State Cleanup | done | xp-developer | - |
| T2 | Overlap Detection Logic | done | xp-developer | T1 |
| T3 | Conflict Resolution Implementation | done | xp-developer | T2 |
| T4 | UI Refactor - Plan Tab | done | xp-developer | T3 |
| T5 | UI - Plan Creation Flow | done | xp-developer | T4 |
| T6 | Allow End Date Selection | done | xp-developer | - |
| T7 | Allow Overlapping Meal Plans | done | xp-developer | T6 |
| T8 | Indicate Used Days in Date Picker | done | xp-developer | T7 |
| T9 | Fix Overlapped Meals Syncing | done | xp-developer | T8 |
| T10 | Split Overlap Options (Truncate vs Delete) | done | xp-developer | T9 |

## 5. Sub-Agent Coordination
Configurable week-start day logic is being removed in favor of a flexible start-date per meal plan. Overlap detection and conflict resolution logic being implemented.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR 1 Reviewed & Approved
- [x] Release Package Generated (Continuous Build APK uploaded to tag continuous-build)

## 7. Release Configuration
**Continuous Release Tag:** continuous-build
**Continuous Release Name:** Continuous Build
**Build Type Override:**
