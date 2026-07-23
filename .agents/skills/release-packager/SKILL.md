---
name: release-packager
description: Use this skill to compile, bundle, or package the completed mobile application into a releasable artifact.
---

# SKILL: Release Packager

This skill encapsulates the packaging stage of the XP lifecycle pipeline. It uses deterministic tools to bundle the application source code into a release package (e.g., APK, IPA, or zipped bundle). It is invoked for both intermediate builds (Phase 3, feature branch) and final release builds (Phase 5, main branch).

## PROCEDURE

1. **Verify Prerequisites:**
   - Ensure the `xp-state.md` plan indicates that the development stage is complete (all backlog tasks are `done`).
   - For a final release build (Phase 5), also verify that PR review is complete.
   - For an intermediate build (Phase 3), PR review is NOT required — the build runs on the feature branch before review.
   - If the required prerequisites are not met, refuse to run.

2. **Determine Build Type:**
   - If the caller specifies an explicit build type (`release` or `debug`), use it.
   - If no build type is specified, **default to `release`**.
   - Select the corresponding build command variant:
     - Release: `gradlew assembleRelease`, `flutter build apk --release`, or equivalent.
     - Debug: `gradlew assembleDebug`, `flutter build apk --debug`, or equivalent.

3. **Execute Packaging (S7 Deterministic Tool Bridge):**
   - Execute the selected build command using the `run_command` tool.

4. **Verify Output:**
   - Use the `list_dir` or `run_command` (e.g., `ls` / `dir`) tool to verify that the expected output artifact (e.g., `.apk`, `.ipa`, `.zip`) was actually generated in the output directory.
   - If the artifact does not exist, report a build failure and provide the compiler logs.

5. **Report Success:**
   - If the artifact exists, report success to the orchestrator and provide the absolute path to the release package.

## ANTI-PATTERNS
- **Plan-and-Pray**: Do not just run the build command and assume it worked. You MUST verify the output artifact exists on disk.
- **Deployment**: This skill ONLY packages the application. It MUST NOT attempt to deploy the app to an app store, server, or device.
- **Wrong Build Type**: Do not default to debug builds. The default is ALWAYS `release` unless the caller explicitly specifies `debug`.
