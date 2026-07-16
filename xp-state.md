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
| T5 | Phase 4: Collaboration | pending | xp-developer | T2, T3 |
| T6 | Bugfix: Guest-to-login perpetual loading screen | done | xp-developer | T4 |
| T7 | Bugfix: Guest login edge cases (smart linking) | done | xp-developer | T6 |

## 5. Sub-Agent Coordination
*Handoff Note:* Bug reported: signing in as guest, then logging in via settings (Google or Email) causes a perpetual loading screen. Root cause identified: `isAuthenticatingProvider` state gets stuck at `true` because the `SettingsScreen` widget is unmounted mid-sign-in when `AuthWrapper` rebuilds on auth state change, preventing the `finally` block from resetting the flag via the now-detached `ref`.

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] PR Review Approved (T6 Bugfix)
- [x] Release Package Generated
