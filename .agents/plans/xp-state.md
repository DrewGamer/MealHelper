# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Retrieve Past or Future Meal Plans in Plan Tab
**Current Stage:** XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add a way to retrieve and navigate between past or future meal plans in the Plan tab of the application.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture:**
1. **Model & Utility (`WeeklyPlan`)**:
   - Add `normalizeToStartOfWeek(DateTime date)`, `endDate` getter, `isSameWeek` comparison helper, date formatting helpers.
2. **State Management (`providers.dart`)**:
   - `selectedWeekDateProvider`: `StateProvider<DateTime>` holding Monday start of selected week.
   - `selectedWeeklyPlanProvider`: `Provider<AsyncValue<WeeklyPlan?>>` deriving active plan for selected week date from `plansStreamProvider`.
3. **UI Layout (`WeeklyPlanScreen`)**:
   - Header navigation bar with previous week (`<`), date range picker button, next week (`>`), and Today reset button.
   - History button / modal sheet listing all past/future plans for rapid jumping.
   - Empty state widget for uncreated weeks with "Create Plan for this Week" action.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Meal Plan Navigation & History Architecture | done | xp-architect | - |
| T2 | Model & Provider Helpers (DEV-1 & DEV-2) | done | xp-developer | T1 |
| T3 | UI Week Navigation & History Sheet (DEV-3 & DEV-4 & DEV-5) | done | xp-developer | T2 |

## 5. Sub-Agent Coordination
Implementation of meal plan navigation and history sheet completed by XP Developer. Code analyzed and tests passing cleanly. Ready for PR review.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] XP Development Loop Completed & Analyzed Clean
- [ ] PR 1 Reviewed & Approved
- [ ] Release Package Generated
