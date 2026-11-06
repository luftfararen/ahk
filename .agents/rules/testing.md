# Automated Regression Testing Rule

## Overview
To prevent regressions and ensure system stability across updates, automated regression testing is mandatory for all code modifications in this project.

## Rules

### 1. Create or Update Tests in `test/` Directory
- Whenever source code (`.ahk`, configuration logic, or related modules) is modified, added, or refactored:
  - Create new unit/regression test cases or add new test assertions to relevant test scripts in the `test/` directory.
  - Test files must follow the pattern `test/test_<feature_or_module>.ahk` or integrate into existing suites (`test/test_hold_mode.ahk`, `test/test_layer_mapping.ahk`, etc.).
  - New test scripts must register their test runner functions into `test/test_runner.ahk`.
  - These tests become permanent assets of the regression test suite.

### 2. Execute Full Regression Test Suite
- Whenever modifying code or test scripts, you MUST run:
  1. The new or updated test script.
  2. The full master regression test suite (`test/test_runner.ahk` or `test/run_tests.ps1`).
- Commands to execute tests:
  ```powershell
  # Run full master test suite
  powershell -ExecutionPolicy Bypass -File test/run_tests.ps1

  # Or run via AutoHotkey64.exe directly
  & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' test/test_runner.ahk
  ```
- **Zero Failure Requirement**: All assertions must pass (100% pass rate, exit code 0) before any task is considered complete.

### 3. Record Test Results in Changelog
- When documenting changes in `ChangLog.md` (via the `update-changelog` skill), record the test execution status, test case names, and pass counts under the **Verification & Impact** section.
