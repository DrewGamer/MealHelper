# Mobile App XP State (B4 Plan Memento)

## 1. Project Context
**Project Name:** User-Managed Ingredient Lists
**Current Stage:** Architecture
**Primary Tech Stack:** Flutter, Dart, Riverpod, Firebase Firestore

## 2. Active Goal & Constraints (B8 Attention Anchor)
**Current Objective:** Add user-managed ingredient lists with two categories (Protein Sources and Ingredients) to populate dropdown/picker controls when creating or editing meals.
**Hard Constraints:** 
- MUST pass human checkpoint for architecture approval.
- MUST pass human checkpoint for PR reviews.
- MUST use environment-manager for new dependencies.
- MUST use a single Firestore document (`ingredient_options`) per workspace for storage.
- MUST cascade-update all meals when an ingredient is renamed or deleted.

## 3. Architecture & Tech Stack
**Approved Architecture:**
See `ingredient_lists_plan.md` for architecture details. Data layer uses `IngredientOptionsRepository` with `arrayUnion`/`arrayRemove`. UI uses Riverpod `streamIngredientOptions()`.
**Dependencies / Frameworks:**
- Flutter
- firebase_core
- cloud_firestore
- flutter_riverpod

## 4. Work Backlog (B7 Todo Commands)
| ID | Title | Status | Assigned Persona | Dependencies |
|---|---|---|---|---|
| T8 | Initial Architecture (XP Check) | done | xp-architect | - |
| T9 | Data Layer: Ingredient Options & Meal Model Enhancements | done | xp-developer | T8 |
| T10 | Ingredient Manager UI (4th bottom tab) | done | xp-developer | T9 |
| T11 | Meal Form Integration (protein dropdown + ingredient chips) | done | xp-developer | T9, T10 |

## 5. Sub-Agent Coordination
(Use this space to hand off context between the orchestrator, architect, and developer threads without polluting chat history.)

## 6. Checkpoints & History
- [x] Architecture Approved
- [x] PR 1 Reviewed & Approved
- [x] Release Package Generated
