---
name: xp-orchestrator
description: Use this orchestrator to manage the development lifecycle of a mobile application using extreme programming. It triggers when a new mobile app project is initiated or when new features are added to an existing backlog. It routes tasks to an agentic development team, persists plans in `.agents/plans/`, manages iterative development on a feature branch (with human verification to prevent branch nesting or misalignment), pauses for human architectural approvals, resilient tool acquisition, post-packaging manual testing, and final release packaging from main after PR merge, uploading the artifact to a release tag.
---

# SKILL: Mobile App XP Lifecycle Orchestrator

This is the primary orchestrator module that realizes the STAFFED PLAN and PIPELINE architectural shapes for the Mobile XP workflow. 

## DEPENDENCIES
- Assets: `assets/xp-state.template.md`
- Personas: `xp-architect`, `xp-developer`
- Skills: `human-checkpoint`, `environment-manager`, `release-packager`
- External CLI: `git`, `gh`

## PROCEDURE

**Phase 0: Initialization**
1. Check for the existence of an `.agents/plans/xp-state.md` plan artifact in the workspace.
2. If it does not exist, initialize it using `assets/xp-state.template.md` as the base, ensuring the `.agents/plans` directory is created.
3. RELOAD the `.agents/plans/xp-state.md` artifact into your context. (B4 PLAN MEMENTO)
4. Check the current branch with `git branch --show-current`. If you are already on a feature branch, invoke the `human-checkpoint` skill to confirm if this branch aligns with the current task.
   - If confirmed, stay on it.
   - If not confirmed, or if you are not currently on a feature branch, list all existing branches using `git branch`. Invoke the `human-checkpoint` skill to ask the human if they want to choose one of the existing branches or if a new feature branch should be created.
   - Execute `git checkout <chosen-branch>` or `git checkout -b <new-branch-name>` based on the human's decision.

**Phase 1: Architecture & Design**
1. Read the user's initial request or feature backlog.
2. Invoke the `xp-architect` persona in a new child thread (CHILD-THREAD SPAWN), passing it the user's request.
3. When the `xp-architect` returns an architectural blueprint, invoke the `human-checkpoint` skill to request human approval.
   - If the human requests changes, re-invoke the `xp-architect` with the feedback.
   - If approved, update `.agents/plans/xp-state.md` with the approved tech stack and move to Phase 2.

**Phase 2: XP Development Loop**
1. Invoke the `xp-developer` persona in a new child thread to begin implementation of the first pending task in the `.agents/plans/xp-state.md` backlog.
2. **Tooling Interruption (Resilience Loop):**
   - If the `xp-developer` reports that a required tool or framework is missing, immediately suspend development.
   - Invoke the `environment-manager` skill to handle acquisition.
   - The `environment-manager` will handle human approvals and fallback logic.
   - If the `environment-manager` reports a `FATAL_FAILURE` (tools could not be acquired manually or automatically), you MUST abort development, invoke the `xp-architect` to revise the stack, and return to Phase 1's human approval gate.
   - If the tool is acquired successfully, re-invoke the `xp-developer` to resume.
3. Once the `xp-developer` finishes the feature and prepares the diff/PR, update the `.agents/plans/xp-state.md` status to indicate the task is complete.

**Phase 3: Intermediate Release Packaging**
1. Invoke the `release-packager` skill to bundle the completed code into an artifact for manual testing.
2. The packager builds on the CURRENT FEATURE BRANCH to update the continuous build. It MUST NOT merge to main, create pull requests, or create new build tags.
3. Once the packager reports success, update the `continuous` release tag on GitHub to point to the current feature branch and upload the built artifact:
   - Run `git tag -f continuous` to force update the local tag to the current commit.
   - Run `git push -f origin continuous` to push the updated tag to GitHub.
   - Run `gh release upload continuous <artifact-path> --clobber` to upload the newly built APK/artifact to the continuous release.
4. Present the final output path and the continuous release link to the user and proceed to Phase 4.

**Phase 4: Manual Testing Loop**
1. Invoke the `human-checkpoint` skill to request a human to manually test the packaged application to identify any issues or bugs.
2. If the human finds bugs or issues, route back to Phase 2: invoke the `xp-developer` to address the specific feedback.
3. If the human approves the release, proceed to Phase 5.

**Phase 5: GitHub PR & Release**
1. Use the GitHub CLI (`gh pr create`) to create a pull request for the feature branch.
2. Invoke the `human-checkpoint` skill to ask the human to confirm that the branch merge to main has been completed.
3. Once the branch merge is confirmed, check out the `main` branch and pull the latest changes (`git checkout main && git pull`).
4. Invoke the `release-packager` skill to bundle the completed code into a final release artifact from the main branch.
5. Use the GitHub CLI (`gh release create <tag-name> <artifact-path>`) to create a new release tag and upload the final APK.
6. Once the release is fully completed, halt execution.

## ANTI-PATTERNS
- **Ghost Todos**: Failing to update the `.agents/plans/xp-state.md` status fields as work progresses.
- **Skipping Gates**: Proceeding to Development without Architecture approval, to Release without PR approval, or halting before branch merge confirmation.
- **Unbounded Loops**: Failing to pass the exact failure feedback to the personas when a human checkpoint requests changes.
