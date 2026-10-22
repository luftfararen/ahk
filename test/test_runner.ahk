#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Playgrounds Master Regression Test Runner
; ============================================================================
; Runs all test suites and exits with status code:
;   0 = All tests passed
;   1 = One or more tests failed
; ============================================================================

#Include "test_framework.ahk"
#Include "test_hold_mode.ahk"
#Include "test_layer_mapping.ahk"

RunAllTests() {
    InitTestSuite("MASTER REGRESSION TEST SUITE")

    ; --- Test Suite 1: Hold Mode & Core Behavior ---
    Test_Layers_Add_Update()
    Test_Mode_MinusOne_Inheritance()
    Test_BTime_Zero()
    Test_Boundary_Conditions_All_Modes()
    Test_Key_Release_Matrix()
    Test_BTime_Special_Values()
    Test_Timer_Reschedule_And_Race()
    Test_Qwerty_Layout_Switch()
    Test_WaitForHold_Interruption_And_SafetyGuard()

    ; --- Test Suite 2: Layer Mapping & INI Binding ---
    Test_LayerId_To_ModKeyId_Mapping()
    Test_Ini_Layer_Binding()

    FinishTestSuite()
}

RunAllTests()
