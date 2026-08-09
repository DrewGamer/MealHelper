# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Fix Firestore Test Mode Expiration
**Current Stage:** Phase 4: Manual Testing Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore, Firebase CLI

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Implement production-ready Firestore Security Rules to secure the database and fix the "Test Mode" expiration warning.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture & Enhancements:**
1. **Security Model**:
   - `users`: Users read/write their own profile (`request.auth.uid == userId`).
   - `databases`: Authenticated users can create workspaces, list workspaces if they are collaborators, and update them to join.
   - Subcollections: Restricted to collaborators.
2. **Implementation**:
   - Create `firestore.rules` and `firebase.json`.
   - Deploy using Firebase CLI.

**Dependencies / Frameworks:**
- Firebase CLI (`firebase-tools`)
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Ensure Firebase CLI is installed and configured | complete | xp-developer | - |
| T2 | Create `firestore.rules` and `firebase.json` | complete | xp-developer | T1 |
| T3 | Deploy Firestore Rules | complete | xp-developer | T2 |

## 5. Sub-Agent Coordination
Implementing secure Firestore rules to replace Test Mode.

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
