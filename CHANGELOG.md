# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Migrated codebase architecture to a clean Feature-First structure (`core`, `auth`, `collaboration`, `ingredients`, `meals`, `plans`, `settings`, `home`) adhering to official Flutter/Riverpod guidelines.
- Reorganized test suite into `test/features/` matching feature domain, application, and data layers with full test coverage preserved.

### Fixed
- Standardized Android launcher, app drawer, and recents display name to "Meal Helper" via native `strings.xml` and manifest activity labels.

### Security
- Implemented secure Firestore Security Rules (`firestore.rules`, `firebase.json`) for strict workspace access control to resolve Test Mode expiration.

## [v1.0.0] - 2026-07-29

### Added
- Option to exclude meals from auto-generation.
- Explicit Cancel button on Assign Meal dialog to differentiate from Clear Day.
- Meal list and meal selection sorting (alphabetical).
- Vary Protein Source feature.
- Consecutive days auto-fill support and end-of-week overflow dialog.

## [v0.9.0-beta] - 2026-07-25

### Added
- Final release for the Smart Auto-Populate feature.

## [v0.8.0-beta] - 2026-07-23

### Added
- Flexible meal plan dates, configurable start and end dates, and overlap conflict resolution (Truncate vs Delete).

### Changed
- UI improvements across meal planning views.

## [v0.7.0-beta] - 2026-07-22

### Added
- Database naming configuration.

## [v0.6.0-beta] - 2026-07-22

### Changed
- UI enhancements for subtitles, navigation, UI state handling, sort functionality, and layout fixes.
- Updated unit tests.

## [v0.5.0-beta] - 2026-07-21

### Added
- Approved plans repository support.

## [v0.4.0-alpha] - 2026-07-21

### Added
- Phase 4: Collaboration features, live cursors, and sharing.

## [v0.3.0-alpha] - 2026-07-09

### Added
- Phase 3: Full meal generation workflow.

### Changed
- UX improvements and Account Settings.

## [v0.2.0-alpha] - 2026-07-09

### Added
- Phase 2: Onboarding, User Profile, and Inventory management.

## [v0.1.0-alpha] - 2026-07-09

### Added
- Phase 1: Authentication, Dashboard shell, and core state management.

[Unreleased]: https://github.com/DrewGamer/MealHelper/compare/v1.0.0...HEAD
[v1.0.0]: https://github.com/DrewGamer/MealHelper/compare/v0.9.0-beta...v1.0.0
[v0.9.0-beta]: https://github.com/DrewGamer/MealHelper/compare/v0.8.0-beta...v0.9.0-beta
[v0.8.0-beta]: https://github.com/DrewGamer/MealHelper/compare/v0.7.0-beta...v0.8.0-beta
[v0.7.0-beta]: https://github.com/DrewGamer/MealHelper/compare/v0.6.0-beta...v0.7.0-beta
[v0.6.0-beta]: https://github.com/DrewGamer/MealHelper/compare/v0.5.0-beta...v0.6.0-beta
[v0.5.0-beta]: https://github.com/DrewGamer/MealHelper/compare/v0.4.0-alpha...v0.5.0-beta
[v0.4.0-alpha]: https://github.com/DrewGamer/MealHelper/compare/v0.3.0-alpha...v0.4.0-alpha
[v0.3.0-alpha]: https://github.com/DrewGamer/MealHelper/compare/v0.2.0-alpha...v0.3.0-alpha
[v0.2.0-alpha]: https://github.com/DrewGamer/MealHelper/compare/v0.1.0-alpha...v0.2.0-alpha
[v0.1.0-alpha]: https://github.com/DrewGamer/MealHelper/releases/tag/v0.1.0-alpha
