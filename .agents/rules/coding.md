# Coding & Development Rules

- **Consult Project Glossary**:
  Whenever you design, write, modify, debug, or refactor code in this project, you MUST reference the [Project Glossary (`.agents/references/GLOSSARY.md`)](../../references/GLOSSARY.md).
- **Domain Consistency**:
  Adhere strictly to the defined concepts and contracts:
  1. Key state transitions (`st_init` -> `st_pressing` -> `st_processed`).
  2. Hold mode behavior specifications (especially HoldMode 7, 8, 9 rollover resolution).
  3. Layer bounds handling (ensuring dynamic layers `layer_id > 8` up to `mod_key_list.Length` are supported).
  4. Proper AHK message pump execution (`Sleep(1)` in wait loops).
- **Automated Regression Testing**:
  Follow the [Automated Regression Testing Rule (`.agents/rules/testing.md`)](testing.md).
  - After modifying files, create or update test cases in the `test/` directory for regression prevention.
  - When modifying code, always execute both newly created and existing regression test suites (`test/run_tests.ps1` or `test/test_runner.ahk`), confirming 100% pass rate.
- **Skills Reference**:
  Follow the `ahk-coding` skill for coding procedures and `update-changelog` skill for logging changes into `ChangLog.md`.
