import math

# ============================================================
# 1. 指・段コスト定義
# ============================================================

FINGER_COST = {
    "pinky": 1.6,
    "ring": 1.3,
    "middle": 1.0,
    "index": 1.1,
}

ROW_COST = {
    "top": 1.1,
    "home": 1.0,
    "bottom": 1.3,
}

# ============================================================
# 2. ローマ字頻度（Qiita マトリクス）
#    子音: "", k,s,t,n,h,m,r,w,g,z,d,b,p,f,v
#    母音: a,i,u,e,o,ya,yu,yo
# ============================================================

ROMAJI_FREQ = {
    "":  {"a":2.80, "i":2.30, "u":1.70, "e":2.50, "o":2.60, "ya":0.30, "yu":0.25, "yo":0.55},
    "k": {"a":2.60, "i":2.20, "u":1.40, "e":1.80, "o":1.90, "ya":0.25, "yu":0.25, "yo":0.60},
    "s": {"a":2.20, "i":1.80, "u":1.90, "e":1.70, "o":1.70, "ya":0.60, "yu":0.35, "yo":0.85},
    "t": {"a":2.40, "i":1.80, "u":1.70, "e":2.20, "o":3.10, "ya":0.25, "yu":0.20, "yo":0.45},
    "n": {"a":1.70, "i":1.20, "u":1.20, "e":0.90, "o":1.20, "ya":0.15, "yu":0.15, "yo":0.20},
    "h": {"a":1.00, "i":0.70, "u":0.70, "e":0.85, "o":0.70, "ya":0.15, "yu":0.20, "yo":0.15},
    "m": {"a":1.00, "i":0.80, "u":0.70, "e":0.55, "o":0.70, "ya":0.15, "yu":0.15, "yo":0.15},
    "r": {"a":1.90, "i":2.00, "u":1.40, "e":1.80, "o":1.80, "ya":0.20, "yu":0.45, "yo":0.30},
    "w": {"a":0.55, "i":0.00, "u":0.00, "e":0.00, "o":0.15, "ya":0.00, "yu":0.00, "yo":0.00},
    "g": {"a":0.70, "i":0.55, "u":0.55, "e":0.55, "o":0.70, "ya":0.15, "yu":0.15, "yo":0.20},
    "z": {"a":0.40, "i":0.45, "u":0.45, "e":0.35, "o":0.45, "ya":0.15, "yu":0.15, "yo":0.45},
    "d": {"a":0.60, "i":0.55, "u":0.35, "e":0.60, "o":0.90, "ya":0.05, "yu":0.15, "yo":0.05},
    "b": {"a":0.40, "i":0.45, "u":0.35, "e":0.40, "o":0.55, "ya":0.05, "yu":0.10, "yo":0.10},
    "p": {"a":0.40, "i":0.45, "u":0.35, "e":0.40, "o":0.55, "ya":0.05, "yu":0.10, "yo":0.10},
    "f": {"a":0.30, "i":0.15, "u":0.00, "e":0.15, "o":0.10, "ya":0.00, "yu":0.00, "yo":0.00},
    "v": {"a":0.30, "i":0.15, "u":0.05, "e":0.15, "o":0.10, "ya":0.00, "yu":0.00, "yo":0.00},
}

# 追加：ん・っ・長音の頻度（ざっくり）
EXTRA_FREQ = {
    "nn": 2.0,   # ん
    "ltu": 1.0,  # っ
    "-": 0.8,    # 長音
}

# ============================================================
# 3. レイアウト定義（キー → (finger,row)）
#    指: lp,lr,lm,li,li2,ri2,ri,rm,rr,rp を finger にマップ
# ============================================================

def finger_alias(name):
    if name in ["lp","rp"]:
        return "pinky"
    if name in ["lr","rr"]:
        return "ring"
    if name in ["lm","rm"]:
        return "middle"
    if name in ["li","li2","ri","ri2"]:
        return "index"
    raise ValueError(name)

def make_layout_from_table(top, home, bottom):
    layout = {}
    for row_name, row in [("top", top), ("home", home), ("bottom", bottom)]:
        for pos, key in row.items():
            if key is None:
                continue
            layout[key] = (finger_alias(pos), row_name)
    return layout

# ---------- 奏 ver0 ----------
KANADERO_V0 = make_layout_from_table(
    top={
        "lp":"l", "lr":"w", "lm":"r", "li":"p", "li2":"f",
        "ri2":"ya", "ri":"yu", "rm":"u", "rr":"yo", "rp":"v",
    },
    home={
        "lp":"k", "lr":"s", "lm":"t", "li":"n", "li2":"h",
        "ri2":"nn", "ri":"a", "rm":"i", "rr":"e", "rp":"o",
    },
    bottom={
        "lp":"g", "lr":"z", "lm":"d", "li":"m", "li2":"b",
        "ri2":"-", "ri":"ltu", "rm":",", "rr":".", "rp":"/",
    },
)

# ---------- 奏 ver1 ----------
KANADERO_V1 = make_layout_from_table(
    top={
        "lp":"w", "lr":"p", "lm":"r", "li":"g", "li2":"f",
        "ri2":"ya", "ri":"yu", "rm":"u", "rr":"yo", "rp":"v",
    },
    home={
        "lp":"k", "lr":"s", "lm":"t", "li":"n", "li2":"h",
        "ri2":"nn", "ri":"a", "rm":"i", "rr":"e", "rp":"o",
    },
    bottom={
        "lp":"l", "lr":"z", "lm":"d", "li":"m", "li2":"b",
        "ri2":"-", "ri":"ltu", "rm":",", "rr":".", "rp":"/",
    },
)

# ---------- 奏 ver3.6 ----------
KANADERO_V36 = make_layout_from_table(
    top={
        "lp":"w", "lr":"p", "lm":"r", "li":"m", "li2":"f",
        "ri2":"ya", "ri":"yu", "rm":"u", "rr":"yo", "rp":"v",
    },
    home={
        "lp":"n", "lr":"s", "lm":"t", "li":"k", "li2":"h",
        "ri2":"nn", "ri":"a", "rm":"i", "rr":"e", "rp":"o",
    },
    bottom={
        "lp":"l", "lr":"z", "lm":"d", "li":"g", "li2":"b",
        "ri2":"-", "ri":"ltu", "rm":",", "rr":".", "rp":"/",
    },
)

# ---------- 大西配列 ----------
ONISHI = make_layout_from_table(
    top={
        "lp":"q", "lr":"l", "lm":"u", "li":" ,", "li2":".",
        "ri2":"f", "ri":"w", "rm":"r", "rr":"y", "rp":"p",
    },
    home={
        "lp":"e", "lr":"i", "lm":"a", "li":"o", "li2":"-",
        "ri2":"k", "ri":"t", "rm":"s", "rr":"n", "rp":"h",
    },
    bottom={
        "lp":"z", "lr":"x", "lm":"c", "li":"v", "li2":";",
        "ri2":"g", "ri":"d", "rm":"z", "rr":"m", "rp":"b",
    },
)

# ---------- qwerty ----------
QWERTY = make_layout_from_table(
    top={
        "lp":"q", "lr":"w", "lm":"e", "li":"r", "li2":"t",
        "ri2":"y", "ri":"u", "rm":"i", "rr":"o", "rp":"p",
    },
    home={
        "lp":"a", "lr":"s", "lm":"d", "li":"f", "li2":"g",
        "ri2":"h", "ri":"j", "rm":"k", "rr":"l", "rp":";",
    },
    bottom={
        "lp":"z", "lr":"x", "lm":"c", "li":"v", "li2":"b",
        "ri2":"n", "ri":"m", "rm":",", "rr":".", "rp":"/",
    },
)

# ============================================================
# 4. ローマ字 → 論理キー列（配列ごと）
# ============================================================

def logical_keys_kanade(consonant, vowel):
    # 奏：ya/yu/yo は単独キー
    if vowel in ["a","i","u","e","o"]:
        if consonant == "":
            return [vowel]
        else:
            return [consonant, vowel]
    else:  # ya,yu,yo
        if consonant == "":
            return [vowel]
        else:
            return [consonant, vowel]

def logical_keys_qwerty_like(consonant, vowel):
    # qwerty / 大西：ya/yu/yo は y + a/i/o
    if vowel in ["a","i","u","e","o"]:
        if consonant == "":
            return [vowel]
        else:
            return [consonant, vowel]
    else:
        # ya,yu,yo
        last = vowel[-1]  # 'a','u','o'
        if consonant == "":
            return ["y", last]
        else:
            return [consonant, "y", last]

# EXTRA: nn, ltu, - は論理キーそのもの
EXTRA_LOGICAL = {
    "nn": ["nn"],
    "ltu": ["ltu"],
    "-": ["-"],
}

# ============================================================
# 5. 単打コスト
# ============================================================

def key_cost(finger, row, key):
    cost = FINGER_COST[finger] + ROW_COST[row]
    if finger == "pinky" and row == "bottom":
        cost += 0.4
    if finger == "ring" and row == "bottom":
        cost += 0.5
    if key in ["t", "y"]:
        cost += 0.3
    return cost

# ============================================================
# 6. 連続打鍵コスト
# ============================================================

def pair_cost(f1, r1, f2, r2):
    cost = 0.0

    # 同一指
    if f1 == f2:
        if r1 != r2:
            cost += 0.8
        else:
            cost += 0.5

    # 小指↔薬指
    if (f1, f2) in [("pinky","ring"),("ring","pinky")]:
        cost += 0.7

    # 中→薬
    if (f1, f2) == ("middle","ring"):
        cost += 0.6

    # 終わりが薬指・小指
    if f2 == "ring":
        cost += 0.4
    if f2 == "pinky":
        cost += 0.3

    # 小指上下
    if f1 == "pinky" and r1 != r2:
        cost += 0.8

    # 薬指下段
    if f1 == "ring" and r1 == "bottom":
        cost += 0.6

    return cost

# ============================================================
# 7. 指負荷バランス（固定：3:3:2:2）
# ============================================================

def balance_cost(finger_count):
    total = sum(finger_count.values())
    if total == 0:
        return 0.0
    p = {f: finger_count[f] / total for f in finger_count}
    target = {"index":0.30,"middle":0.30,"ring":0.20,"pinky":0.20}
    return sum((p[f] - target[f])**2 for f in p)

# ============================================================
# 8. 評価関数（戦略非依存）
# ============================================================

def evaluate_layout(layout, mode="kanade"):
    """
    layout: dict key -> (finger,row)
    mode: "kanade" or "qwerty_like"
    戻り値: dict
      - total_single_cost
      - total_pair_cost
      - balance_cost
      - total_cost
      - finger_share
    """
    if mode == "kanade":
        logical_fn = logical_keys_kanade
    else:
        logical_fn = logical_keys_qwerty_like

    total_single = 0.0
    total_pair = 0.0
    finger_count = {"index":0.0,"middle":0.0,"ring":0.0,"pinky":0.0}

    # CV 系
    for c, row in ROMAJI_FREQ.items():
        for v, freq in row.items():
            if freq == 0:
                continue
            logical_keys = logical_fn(c, v)
            mapped = []
            for lk in logical_keys:
                if lk not in layout:
                    # その配列に存在しない論理キーは無視
                    continue
                finger, rowname = layout[lk]
                mapped.append((finger, rowname, lk))
                finger_count[finger] += freq
                total_single += freq * key_cost(finger, rowname, lk)
            for (f1,r1,_),(f2,r2,_) in zip(mapped, mapped[1:]):
                total_pair += freq * pair_cost(f1,r1,f2,r2)

    # ん・っ・長音
    for sym, freq in EXTRA_FREQ.items():
        logical_keys = EXTRA_LOGICAL[sym]
        mapped = []
        for lk in logical_keys:
            if lk not in layout:
                continue
            finger, rowname = layout[lk]
            mapped.append((finger, rowname, lk))
            finger_count[finger] += freq
            total_single += freq * key_cost(finger, rowname, lk)
        for (f1,r1,_),(f2,r2,_) in zip(mapped, mapped[1:]):
            total_pair += freq * pair_cost(f1,r1,f2,r2)

    bal = balance_cost(finger_count)

    # 重み（固定）
    w1, w2, w3 = 1.0, 1.5, 1.0
    total_cost = w1*total_single + w2*total_pair + w3*bal

    total_f = sum(finger_count.values())
    finger_share = {f: (finger_count[f]/total_f if total_f>0 else 0.0)
                    for f in finger_count}

    return {
        "total_single_cost": total_single,
        "total_pair_cost": total_pair,
        "balance_cost": bal,
        "total_cost": total_cost,
        "finger_share": finger_share,
    }

# ============================================================
# 9. 実行例
# ============================================================

if __name__ == "__main__":
    layouts = {
        "Kanade_v0": (KANADERO_V0, "kanade"),
        "Kanade_v1": (KANADERO_V1, "kanade"),
        "Kanade_v36": (KANADERO_V36, "kanade"),
        "Onishi": (ONISHI, "qwerty_like"),
        "Qwerty": (QWERTY, "qwerty_like"),
    }

    for name, (layout, mode) in layouts.items():
        res = evaluate_layout(layout, mode=mode)
        print(f"=== {name} ===")
        print(f" total_cost        : {res['total_cost']:.2f}")
        print(f"  single_cost      : {res['total_single_cost']:.2f}")
        print(f"  pair_cost        : {res['total_pair_cost']:.2f}")
        print(f"  balance_cost     : {res['balance_cost']:.6f}")
        print(f"  finger_share     : {res['finger_share']}")
        print()
