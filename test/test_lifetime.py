import subprocess
import time

ahk = r"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
target = r"src\PlayGrounds.ahk"

proc = subprocess.Popen([ahk, target])
for i in range(10):
    time.sleep(0.5)
    poll = proc.poll()
    print(f"t={(i+1)*0.5}s: poll={poll}")
    if poll is not None:
        break

if proc.poll() is None:
    print("Process is still running after 5s!")
    proc.kill()
