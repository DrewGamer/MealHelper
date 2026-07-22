# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** UI Improvements (Navigation, Tags, Sorting)
**Current Stage:** Manual Testing
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Address UI and UX issues:
1. Make the bottom navigation bar easier to use.
2. Hide or replace tags in "Meals Database" screen with new ingredients.
3. Sort multi-select ingredients for a meal exactly as they are sorted on the ingredients screen (alphabetically).
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture:**
1. Migrate `BottomNavigationBar` to Material 3 `NavigationBar` in `home_screen.dart`.
2. In `meals_list_screen.dart`, conditionally prepend `proteinSource` to `ingredients` as the subtitle, removing legacy `tags`.
3. Centralize alphabetical sorting into `lib/utils/string_extensions.dart` (`List<String>.sortAlphabetically()`) and apply to `meal_detail_screen.dart` and `ingredient_manager_screen.dart`.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | UI Improvements Architecture (XP Check) | done | xp-architect | - |
| T2 | Fix Bottom Navigation Bar styling | done | xp-developer | T1 |
| T3 | Update Meals Database screen tags/ingredients | done | xp-developer | T1 |
| T4 | Fix sorting of ingredients in multi-select | done | xp-developer | T1 |

## 5. Sub-Agent Coordination
(Use this space to hand off context between the orchestrator, architect, and developer threads without polluting chat history.)
Release package generated. Awaiting manual testing approval.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] PR 1 Reviewed & Approved
- [x] Release Package Generated
