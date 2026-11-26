---
name: git-commit
description: >-
  Use this skill whenever the user instructs to commit changes via custom command (e.g., "コミットして", "commit", "git commit", "コミット作成"). Guides the agent to review git status, inspect the latest entry in ChangLog.md (specifically the "### Suggested Commit Message" section), construct the commit log directly from it, stage the appropriate files, and execute the git commit.
---

# Git Commit Skill (Changelog-Driven Commit Workflow / "コミットして" カスタムコマンド)

This skill defines the standardized workflow for committing changes in this repository. Whenever the user instructs to commit (e.g., "コミットして"), you MUST reference `ChangLog.md` (or `ChangeLog.md`), extract the commit log from its `### Suggested Commit Message` section, and execute the commit.

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
3. If the entry contains a `### Suggested Commit Message` block:
   - Extract the exact text inside the code block (` ```text ... ``` `). It is pre-formatted and ready to use directly.
4. If the block is absent or needs adjustment:
   - Extract Title, Overview, Technical Changes, and Verification manually to formulate the message.

---

### Step 3: Formulate Commit Message

Use the pre-formatted `### Suggested Commit Message` from `ChangLog.md`, or format it adhering to the following structure:

```text
<Title from ChangLog.md or concise summary>

Overview:
- <Summary bullet points from ChangLog.md>

Technical Changes:
- <Key technical modifications by class/function>

Verification:
- <Test results, e.g. All 159 tests passed (run_tests.ps1)>
```

> [!TIP]
> - Keep the first line concise (around 50–72 characters if possible).
> - Directly reusing the `### Suggested Commit Message` guarantees 100% alignment between `ChangLog.md` and Git commit history.
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
