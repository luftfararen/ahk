---
name: git-commit
description: >-
  Use this skill whenever the user instructs to commit changes (e.g., "コミットして", "commit", "git commit", "コミット作成"). Guides the agent to review git status, inspect the latest entry in ChangLog.md, construct a structured commit message derived from the changelog, stage the appropriate files, and execute the git commit.
---

# Git Commit Skill (Changelog-Driven Commit Workflow)

This skill defines the standardized workflow for committing changes in this repository. Whenever the user instructs to commit (e.g., "コミットして"), you MUST reference `ChangLog.md` to construct a precise, high-quality commit message and execute the commit.

---

## Workflow Steps

### Step 1: Pre-Commit Inspection & Verification

1. **Verify Code Health**:
   - Before committing any AutoHotkey code, always verify syntax:
     ```powershell
     & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /validate src\PlayGroundsExp.ahk
     ```
   - Run the automated test suite to ensure 100% pass:
     ```powershell
     powershell -ExecutionPolicy Bypass -File test/run_tests.ps1
     ```
   - **CRITICAL**: If any test fails, do NOT commit. Resolve failures first.

2. **Check Git Status**:
   - Inspect modified and untracked files:
     ```powershell
     git status
     ```
   - Review the diff to confirm what changed:
     ```powershell
     git diff --stat
     ```

---

### Step 2: Read Latest Entry from `ChangLog.md`

1. Open and inspect `ChangLog.md` at the repository root (`C:\src\ahk\ChangLog.md`).
2. Read the **latest entry** (the top-most `## [YYYY-MM-DD] - <Title>` section).
3. Extract:
   - **Title**: The headline of the change.
   - **Category**: (e.g., Bug Fix, Feature, Refactoring).
   - **Summary**: Concise explanation of what was achieved.
   - **Root Cause / Motivation**: Why the change was made.
   - **Key Technical Changes**: Bullet points of specific functions, classes, and logic modified.

---

### Step 3: Formulate Commit Message

Construct a clear, informative commit message adhering to the following structure:

```text
<Title from ChangLog.md or concise summary>

Overview:
- <Summary bullet points from ChangLog.md>

Technical Changes:
- <Key technical modifications by class/function>

Verification:
- <Test results, e.g. All 106 tests passed (run_tests.ps1)>
```

> [!TIP]
> - Keep the first line concise (around 50–72 characters if possible).
> - Use standard technical English or Japanese matching user preference, but maintain full alignment with `ChangLog.md`.
> - Do NOT write generic commit messages like "fix bug" or "update code".

---

### Step 4: Selective Staging & Commit

1. **Stage Relevant Files**:
   - Stage modified source files, test files, and `ChangLog.md`:
     ```powershell
     git add src/PlayGroundsExp.ahk test/test_hold_mode.ahk test/test_runner.ahk ChangLog.md
     ```
   - **DO NOT** use `git add .` or `git add -A` blindly if untracked scratch/temporary files (e.g., `todo.txt`, logs, scratch notes) are present unless explicitly intended.
2. **Execute Commit**:
   - Run `git commit` with the prepared multi-line message:
     ```powershell
     git commit -m "Title" -m "Body paragraph 1" -m "Body paragraph 2"
     ```
   - Alternatively, pass the formatted message via temporary file or heredoc if PowerShell supports it cleanly.

---

### Step 5: Verify & Report

1. Check the newly created commit:
   ```powershell
   git log -n 1 --stat
   ```
2. Report the result to the user:
   - Commit hash (short)
   - Commit subject
   - List of committed files
   - Test passing confirmation
