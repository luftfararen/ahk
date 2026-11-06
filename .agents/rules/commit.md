# Git Commit Command Rule ("コミットして" / Commit Rule)

This rule defines the mandatory procedure whenever the user executes the custom command "コミットして" (or "commit", "git commit", "コミット作成").

## Mandatory Requirements

1. **Reference ChangeLog Commit Section (CRITICAL)**:
   - You MUST read the latest entry from `ChangLog.md` (or `ChangeLog.md`) located at the repository root (`C:\src\ahk\ChangLog.md`).
   - Extract the ready-to-use commit log from the `### Suggested Commit Message` section.
   - Use this extracted commit message to construct the Git commit, ensuring 100% consistency between `ChangLog.md` and Git commit history.
   - If the `### Suggested Commit Message` block is missing, first update `ChangLog.md` to include it, or construct the commit message following the exact structure:
     - 1st line: Concise 50-72 character subject title
     - Paragraph 2: `Overview:` bullet points
     - Paragraph 3: `Technical Changes:` bullet points
     - Paragraph 4: `Verification:` test results

2. **Pre-Commit Verification**:
   - Always validate syntax before committing:
     ```powershell
     & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /validate src\PlayGroundsExp.ahk
     ```
   - Always run the master automated regression test suite:
     ```powershell
     powershell -ExecutionPolicy Bypass -File test/run_tests.ps1
     ```
   - **NEVER commit if any tests fail.**

3. **Selective Staging**:
   - Check `git status` and stage only the relevant source files, test files, and documentation/changelog.
   - Never run `git add .` or `git add -A` blindly if untracked notes/scratch files (e.g., `todo.txt`) exist.

4. **Execute & Report**:
   - Execute the commit with the constructed message.
   - Report the commit hash, commit subject, list of committed files, and test results back to the user.
