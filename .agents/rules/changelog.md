# Changelog Maintenance Rule

- Whenever any source code, script, or configuration file in the project is modified, added, refactored, or fixed, you MUST record the technical changes in `ChangLog.md` located at the repository root (`C:\src\ahk\ChangLog.md`).
- All entries in `ChangLog.md` MUST be written in **English**.
- The content must be detailed, including:
  1. Affected files
  2. Type of change (Bug Fix, Feature, Performance, Refactoring, Config)
  3. Background & Root cause
  4. Specific technical modifications (functions, methods, logic changes)
  5. Verification & Impact
  6. **Ready-to-use Commit Message**: Each entry MUST include a structured, copy-pasteable Git commit message section (`### Suggested Commit Message`) so that commit commands or subsequent agents can directly use it without reconstruction.
- Refer to the `update-changelog` skill for the standard format and guidelines.
