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

with open(r"src\PlayGroundsExp.ahk", "r", encoding="utf-8") as f:
    exp = f.read()

idx_orig_layers = orig.find("class Layers {")
idx_orig_after = orig.find("class HoldMode {")

idx_exp_layers = exp.find("class Layers {")
idx_exp_after = exp.find("class HoldMode {")

exp_layers = exp[idx_exp_layers:idx_exp_after]
orig_layers = orig[idx_orig_layers:idx_orig_after]

idx_exp_parse = exp_layers.find("static ParseModSpec")
idx_exp_eval = exp_layers.find("static EvalModSpec")
idx_exp_state = exp_layers.find("static State(")

parse_only = exp_layers[idx_exp_parse:idx_exp_eval]
eval_only = exp_layers[idx_exp_eval:idx_exp_state]

idx_orig_arr = orig_layers.find("arr := []") + len("arr := []\n")

print("Subtest ParseModSpec ONLY:")
code_parse = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + parse_only + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("Result Parse:", test_code(code_parse))

print("Subtest EvalModSpec ONLY:")
code_eval = orig[:idx_orig_layers] + orig_layers[:idx_orig_arr] + "\n" + eval_only + orig_layers[idx_orig_arr:] + orig[idx_orig_after:]
print("Result Eval:", test_code(code_eval))
