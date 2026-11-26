import subprocess
import shutil

ahk = r"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
target = r"src\test_crash_bisect.ahk"

def is_alive():
    try:
        proc = subprocess.Popen([ahk, target])
        try:
            proc.wait(timeout=1.0)
            return False, proc.returncode
        except subprocess.TimeoutExpired:
            proc.kill()
            return True, None
    except Exception as e:
        return False, str(e)

# First test with PlayGrounds.ahk
shutil.copyfile(r"src\PlayGrounds.ahk", target)
alive, code = is_alive()
print(f"PlayGrounds.ahk: alive={alive}, code={code}")

# Second test with PlayGroundsExp.ahk
shutil.copyfile(r"src\PlayGroundsExp.ahk", target)
alive, code = is_alive()
print(f"PlayGroundsExp.ahk: alive={alive}, code={code}")
