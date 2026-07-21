# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** MealHelper
**Current Stage:** Development
**Primary Tech Stack:**

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Implement user-managed ingredient lists (protein sources + ingredients) with a new Ingredient Manager tab, cascade rename/delete, and Meal form integration. See approved plan: `ingredient_lists_plan.md`.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.
- Shareable/collaborative database or private single-user.
- No extra setup outside the app (in-app signups for third parties).
- Major account integrations (Google/Apple) optional.
- Anonymous authentication for the app itself.

## 3. Architecture & Tech Stack
**Approved Architecture:**
Flutter cross-platform mobile app with a Firebase backend. Follows Clean Architecture/MVVM with Presentation, Business Logic, Data Access, and Data Source layers. See `architecture_blueprint.md` for details.
**Dependencies / Frameworks:**
- Flutter SDK (Dart)
- Firebase Auth & Cloud Firestore
- Riverpod (State Management)
- Hive or SharedPreferences (Local Storage)

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Initial Architecture | done | xp-architect | - |
| T2 | Phase 1: Core Setup & Single-User Flow | done | xp-developer | T1 |
| T3 | Phase 2: Weekly Plan Engine | done | xp-developer | T2 |
| T4 | Phase 3: Auth Enhancements | done | xp-developer | T2 |
| T5 | Phase 4: Collaboration | done | xp-developer | T2, T3 |
| T6 | Bugfix: Guest-to-login perpetual loading screen | done | xp-developer | T4 |
| T7 | Bugfix: Guest login edge cases (smart linking) | done | xp-developer | T6 |
| T8 | Bugfix: Guest to Google login flow & account persistence | done | xp-developer | T7 |
| T9 | Data Layer: Ingredient Options & Meal Model Enhancements | pending | xp-developer | T5 |
| T10 | Ingredient Manager UI (4th bottom tab) | pending | xp-developer | T9 |
| T11 | Meal Form Integration (protein dropdown + ingredient chips) | pending | xp-developer | T9, T10 |

## 5. Sub-Agent Coordination
*Handoff Note:* Approved plans on file:
- `ingredient_lists_plan.md` — User-managed ingredient lists feature (T9–T11). **Start here next session.**
- `smart_meal_randomizer_plan.md` — Shelved until ingredient lists are complete. Depends on T9–T11 being done first.

Key design decisions for T9–T11: Remove `tags` field from Meal model. No starter data. Cascade-rename and cascade-delete ingredients across meals (with confirmation dialog listing affected meals). Alphabetical sort. Food-inclusive icon for the 4th bottom tab.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] PR Review Approved (T6 Bugfix)
- [x] PR Review Approved (T5 Collaboration)
- [x] PR Review Approved (T8 Bugfix)
- [x] Release Package Generated
- [x] Ingredient Lists Plan Approved
- [x] Smart Meal Randomizer Plan Approved (shelved, pending T9–T11)
