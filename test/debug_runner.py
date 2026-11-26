import subprocess
import os

with open("test/test_caret_indicator.ahk", "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
for idx, l in enumerate(lines):
    new_lines.append(f'FileAppend("LINE {idx+1}`n", A_ScriptDir . "/run_debug.log", "UTF-8")\n')
    new_lines.append(l)

with open("test/test_caret_indicator_traced.ahk", "w", encoding="utf-8") as f:
    f.writelines(new_lines)

log_path = "test/run_debug.log"
if os.path.exists(log_path):
    os.remove(log_path)

try:
    res = subprocess.run(["C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe", "test_caret_indicator_traced.ahk"], cwd="test", timeout=5)
    print("Completed cleanly with returncode", res.returncode)
except subprocess.TimeoutExpired:
    print("Timed out!")

if os.path.exists(log_path):
    with open(log_path, "r", encoding="utf-8") as f:
        print("Last lines of log:")
        print("".join(f.readlines()[-30:]))
