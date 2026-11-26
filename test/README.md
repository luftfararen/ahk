# Playgrounds Automated Regression Test Suite

This directory contains the automated regression test framework and test suites for the Playgrounds AutoHotkey project.

## Directory Structure

- `run_tests.ps1`: PowerShell test runner script that runs test suites and returns standard exit codes (`0` for success, `1` for failure).
- `test_runner.ahk`: Master test runner in AutoHotkey v2 that loads and runs all test suites.
- `test_framework.ahk`: Reusable assertion library, test counters, and test logging mechanisms.
- `test_hold_mode.ahk`: Regression tests for key hold modes, rollover boundary conditions, timer rescheduling, and layout switching.
- `test_layer_mapping.ahk`: Regression tests for dynamic layer-to-modifier mappings and INI configuration loading/saving.

## Running Tests

### Run All Tests via PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File test/run_tests.ps1
```

### Run a Specific Test Suite
```powershell
powershell -ExecutionPolicy Bypass -File test/run_tests.ps1 -TestScript test_hold_mode.ahk
powershell -ExecutionPolicy Bypass -File test/run_tests.ps1 -TestScript test_layer_mapping.ahk
```

### Direct AHK Execution
```powershell
& 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' test/test_runner.ahk
```

## Adding New Tests
1. Create a new test script (e.g. `test/test_my_feature.ahk`).
2. Include `test_framework.ahk` and `..\src\PlayGroundsExp.ahk`.
3. Implement test functions using `Assert(condition, "test description")`.
4. Register the new test function in `test/test_runner.ahk` to make it part of the master regression suite.
