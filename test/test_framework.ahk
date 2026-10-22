#Requires AutoHotkey v2.0

; ============================================================================
; Test Framework for Playgrounds Regression Testing
; ============================================================================

global test_count := 0
global pass_count := 0
global fail_count := 0
global failed_tests := []
global test_log_file := A_ScriptDir . "\test_result.log"

LogMsg(str) {
    global test_log_file
    FileAppend(str, test_log_file, "UTF-8")
}

Assert(condition, test_name, extra_info := "") {
    global test_count, pass_count, fail_count, failed_tests
    test_count++
    if condition {
        pass_count++
        LogMsg(Format("[PASS] {}`n", test_name))
    } else {
        fail_count++
        msg := Format("[FAIL] {} {}", test_name, extra_info)
        LogMsg(msg . "`n")
        failed_tests.Push(msg)
    }
}

InitTestSuite(suite_name := "REGRESSION TEST SUITE") {
    global test_count, pass_count, fail_count, failed_tests, test_log_file
    test_count := 0
    pass_count := 0
    fail_count := 0
    failed_tests := []
    try FileDelete(test_log_file)
    LogMsg(Format("=== RUNNING {} ===`n", suite_name))
}

FinishTestSuite() {
    global test_count, pass_count, fail_count, failed_tests
    LogMsg("`n============================================`n")
    LogMsg(Format("TOTAL: {}, PASSED: {}, FAILED: {}`n", test_count, pass_count, fail_count))
    if (fail_count > 0) {
        LogMsg("Failed tests:`n")
        for f in failed_tests {
            LogMsg("  " . f . "`n")
        }
        ExitApp(1)
    } else {
        LogMsg("ALL TESTS PASSED SUCCESSFULLY!`n")
        ExitApp(0)
    }
}
