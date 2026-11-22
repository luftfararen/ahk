import subprocess
import time

ahk = r"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
target = r"src\test_crash_bisect.ahk"

def test_code(code_str):
    with open(target, "w", encoding="utf-8") as f:
        f.write(code_str)
    proc = subprocess.Popen([ahk, target])
    crashed = False
    for _ in range(9):
        time.sleep(0.5)
        if proc.poll() is not None:
            crashed = True
            break
    if not crashed:
        proc.kill()
        return True # Alive
    else:
        return False # Crashed

with open(r"src\PlayGrounds.ahk", "r", encoding="utf-8") as f:
    orig = f.read()

idx_orig_layers = orig.find("class Layers {")
idx_orig_after = orig.find("class HoldMode {")
orig_layers = orig[idx_orig_layers:idx_orig_after]
idx_orig_arr = orig_layers.find("arr := []") + len("arr := []\n")

# Test 1: Empty ParseModSpec
code_empty = """
    static ParseModSpec(spec) {
        return { mod_key_id: 1, alt: false, ctrl: false, shift: false, win: false }
    }
"""
c = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + code_empty + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("Empty ParseModSpec:", test_code(c))

# Test 2: ParseModSpec up to line 49 (prefix symbols)
code_lines = """
    static ParseModSpec(spec) {
        if (spec is Object && !(spec is String) && !(spec is Array) && spec.HasProp("mod_key_id"))
            return spec

        if IsInteger(spec) {
            val := Integer(spec)
            if val == 5
                return { mod_key_id: 1, alt: true, ctrl: false, shift: false, win: false }
            if val == 12
                return { mod_key_id: 7, alt: true, ctrl: false, shift: false, win: false }
            return { mod_key_id: val, alt: false, ctrl: false, shift: false, win: false }
        }

        s := Trim(String(spec))
        if (s == "" || s == "0" || StrLower(s) == "none")
            return { mod_key_id: 0, alt: false, ctrl: false, shift: false, win: false }

        s_lower := StrLower(s)
        if (s_lower == "m5")
            return { mod_key_id: 1, alt: true, ctrl: false, shift: false, win: false }
        if (s_lower == "m12")
            return { mod_key_id: 7, alt: true, ctrl: false, shift: false, win: false }

        has_alt := false
        has_ctrl := false
        has_shift := false
        has_win := false

        while (StrLen(s) > 0) {
            first_char := SubStr(s, 1, 1)
            if (first_char == "!") {
                has_alt := true
                s := SubStr(s, 2)
            } else if (first_char == "^") {
                has_ctrl := true
                s := SubStr(s, 2)
            } else if (first_char == "+") {
                has_shift := true
                s := SubStr(s, 2)
            } else if (first_char == "#") {
                has_win := true
                s := SubStr(s, 2)
            } else {
                break
            }
        }
        return { mod_key_id: 1, alt: has_alt, ctrl: has_ctrl, shift: has_shift, win: has_win }
    }
"""
c2 = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + code_lines + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("Up to while loop:", test_code(c2))

# Test 3: Adding parts splitting
code_parts = code_lines.replace("return { mod_key_id: 1, alt: has_alt, ctrl: has_ctrl, shift: has_shift, win: has_win }", """
        parts := StrSplit(s, "+")
        clean_parts := []
        for part in parts {
            p := Trim(part)
            p_lower := StrLower(p)
            if (p_lower == "alt" || p_lower == "lalt" || p_lower == "ralt") {
                has_alt := true
            } else if (p_lower == "ctrl" || p_lower == "control" || p_lower == "lctrl" || p_lower == "rctrl") {
                has_ctrl := true
            } else if (p_lower == "shift" || p_lower == "lshift" || p_lower == "rshift") {
                has_shift := true
            } else if (p_lower == "win" || p_lower == "lwin" || p_lower == "rwin") {
                has_win := true
            } else if (p != "") {
                clean_parts.Push(p)
            }
        }
        return { mod_key_id: 1, alt: has_alt, ctrl: has_ctrl, shift: has_shift, win: has_win }
""")
c3 = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + code_parts + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("With parts splitting:", test_code(c3))

# Test 4: Adding regex match
code_regex = code_parts.replace("return { mod_key_id: 1, alt: has_alt, ctrl: has_ctrl, shift: has_shift, win: has_win }", """
        base_str := clean_parts.Length > 0 ? clean_parts[clean_parts.Length] : ""
        mid := 0
        if (base_str != "") {
            if RegExMatch(base_str, "i)^m(\d+)$", &m) {
                mid := Integer(m[1])
            }
        }
        return { mod_key_id: mid, alt: has_alt, ctrl: has_ctrl, shift: has_shift, win: has_win }
""")
c4 = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + code_regex + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("With regex match:", test_code(c4))
