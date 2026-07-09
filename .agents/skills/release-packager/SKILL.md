---
name: release-packager
description: Use this skill to compile, bundle, or package the completed mobile application into a releasable artifact.
---

# SKILL: Release Packager

This skill encapsulates the final stage of the XP lifecycle pipeline. It uses deterministic tools to bundle the application source code into a release package (e.g., APK, IPA, or zipped bundle).

## PROCEDURE

1. **Verify Prerequisites:**
   - Ensure the `xp-state.md` plan indicates that the development and PR review stages are complete.
   - If they are not complete, refuse to run.

2. **Execute Packaging (S7 Deterministic Tool Bridge):**
   - Identify the correct build command based on the project tech stack (e.g., `gradlew assembleRelease`, `npm run build`, `flutter build apk`).
   - Execute the build command using the `run_command` tool.

3. **Verify Output:**
   - Use the `list_dir` or `run_command` (e.g., `ls` / `dir`) tool to verify that the expected output artifact (e.g., `.apk`, `.ipa`, `.zip`) was actually generated in the output directory.
   - If the artifact does not exist, report a build failure and provide the compiler logs.

4. **Report Success:**
   - If the artifact exists, report success to the orchestrator and provide the relative path to the release package.

## ANTI-PATTERNS
- **Plan-and-Pray**: Do not just run the build command and assume it worked. You MUST verify the output artifact exists on disk.
- **Deployment**: This skill ONLY packages the application. It MUST NOT attempt to deploy the app to an app store, server, or device.
