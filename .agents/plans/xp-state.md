# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** Database Naming in Collaboration Screen
**Current Stage:** XP Development Loop
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add the ability for users to name their database in the collaboration screen (above "Share Your Database") so that the active workspace shows the name of the database being used instead of "A Shared Database".
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.

## 3. Architecture & Tech Stack
**Approved Architecture:**
1. Data Layer: Add `updateDatabaseName` and `streamDatabaseName` to `DatabaseRepository`.
2. State Management: Add `databaseNameProvider` family stream provider to `providers.dart`.
3. UI Layer: Update `CollaborationScreen` to include "Name Your Database" section and fetch name for "Active Workspace" section.

**Dependencies / Frameworks:**
- Flutter (Material 3)
- flutter_riverpod
- cloud_firestore

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T1 | Database Naming Architecture (XP Check) | done | xp-architect | - |
| T2 | Add Database Name to Collaboration Screen | done | xp-developer | T1 |
| T3 | Update Active Workspace to show Database Name | done | xp-developer | T1 |

## 5. Sub-Agent Coordination
Architecture approved. Moving to Phase 2: XP Development Loop.

## 6. Checkpoints & History
- [x] Architecture Approved
- [ ] PR 1 Reviewed & Approved
- [x] Release Package Generated
