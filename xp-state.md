# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** MealHelper
**Current Stage:** Architecture
**Primary Tech Stack:**

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Design architecture for a mobile app for keeping a database of meals and creating a weekly meal list.
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

## 5. Sub-Agent Coordination
*Handoff Note:* Bug reported for Google login: When starting as a guest and logging in with an existing Google account from Settings, if it says the account already exists and the user proceeds, it kicks them back to the main login screen (unlike email login which works). Additionally, the failed Google login persists the chosen account, so subsequent Google login attempts automatically use the last selected account without asking.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] PR Review Approved (T6 Bugfix)
- [x] PR Review Approved (T5 Collaboration)
- [x] PR Review Approved (T8 Bugfix)
- [x] Release Package Generated
