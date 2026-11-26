with open(r"src\PlayGroundsExp.ahk", "r", encoding="utf-8") as f:
    exp = f.read()

s = exp.find("static ParseModSpec")
e = exp.find("static EvalModSpec")
lines = exp[s:e].splitlines()
for i, l in enumerate(lines):
    print(f"{i}: {l}")
