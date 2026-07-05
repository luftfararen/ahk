import sys
import re
import collections
import math
from typing import NamedTuple, Optional, List, Tuple

# --- 定義データ ---
BASE_CHARS = "qwertyuiopasdfghjkl;zxcvbnm,./"

QWERTY_KEYS = [
    "tab",
    "q",
    "w",
    "e",
    "r",
    "t",
    "y",
    "u",
    "i",
    "o",
    "p",
    "bs",
    "caps",
    "a",
    "s",
    "d",
    "f",
    "g",
    "h",
    "j",
    "k",
    "l",
    ";",
    "enter",
    "lshift",
    "z",
    "x",
    "c",
    "v",
    "b",
    "n",
    "m",
    ",",
    ".",
    "/",
    "rshift",
]

# 0: right hand, 1: left hand
LEFT_HAND_MAP = [
    1,
    1,
    1,
    1,
    1,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    1,
    1,
    1,
    1,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    1,
    1,
    1,
    1,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
]

# 0: pinky, 1: ring, 2: middle, 3: index, 4: thumb
FINGERS_MAP = [
    0,
    0,
    1,
    2,
    3,
    3,
    3,
    3,
    2,
    1,
    0,
    0,
    0,
    0,
    1,
    2,
    3,
    3,
    3,
    3,
    2,
    1,
    0,
    0,
    0,
    0,
    1,
    2,
    3,
    3,
    3,
    3,
    2,
    1,
    0,
    0,
]

ROW_MAP = {
    "q": 0,
    "w": 0,
    "e": 0,
    "r": 0,
    "t": 0,
    "y": 0,
    "u": 0,
    "i": 0,
    "o": 0,
    "p": 0,
    "a": 1,
    "s": 1,
    "d": 1,
    "f": 1,
    "g": 1,
    "h": 1,
    "j": 1,
    "k": 1,
    "l": 1,
    ";": 1,
    "z": 2,
    "x": 2,
    "c": 2,
    "v": 2,
    "b": 2,
    "n": 2,
    "m": 2,
    ",": 2,
    ".": 2,
    "/": 2,
}

# 物理キーボードの相対座標 (X, Y) ※計算モード用
# 行のズレ(Stagger)を考慮しています
KEY_COORDS = {
    "q": (0, 0),
    "w": (1, 0),
    "e": (2, 0),
    "r": (3, 0),
    "t": (4, 0),
    "y": (5, 0),
    "u": (6, 0),
    "i": (7, 0),
    "o": (8, 0),
    "p": (9, 0),
    "a": (0.25, 1),
    "s": (1.25, 1),
    "d": (2.25, 1),
    "f": (3.25, 1),
    "g": (4.25, 1),
    "h": (5.25, 1),
    "j": (6.25, 1),
    "k": (7.25, 1),
    "l": (8.25, 1),
    ";": (9.25, 1),
    "z": (0.75, 2),
    "x": (1.75, 2),
    "c": (2.75, 2),
    "v": (3.75, 2),
    "b": (4.75, 2),
    "n": (5.75, 2),
    "m": (6.75, 2),
    ",": (7.75, 2),
    ".": (8.75, 2),
    "/": (9.75, 2),
    # 特殊キーはホームポジションから遠い位置として仮置
    "tab": (-1, 0),
    "caps": (-1, 1),
    "lshift": (-1, 2),
    "bs": (10, 0),
    "enter": (10, 1),
    "rshift": (10, 2),
}

# --- デフォルトのCOST_MATRIX (変更なし) ---
DEFAULT_COST_MATRIX = {
    "q": [40, 20, 25, 15, 20, 30, 50, 50, 40, 25, 15, 30, 90, 70, 50, 50, 30, 40],
    "p": [25, 30, 15, 25, 20, 40, 35, 15, 25, 40, 50, 45, 40, 50, 50, 50, 70, 90],
    "w": [30, 50, 15, 15, 10, 25, 40, 50, 40, 25, 10, 25, 60, 70, 60, 50, 20, 40],
    "o": [30, 25, 15, 20, 50, 20, 25, 10, 25, 40, 50, 40, 40, 50, 50, 60, 70, 85],
    "e": [40, 30, 20, 10, 20, 30, 40, 35, 40, 20, 10, 25, 60, 60, 40, 40, 20, 40],
    "i": [30, 25, 10, 20, 40, 40, 20, 10, 20, 40, 35, 40, 30, 50, 40, 50, 60, 85],
    "r": [40, 35, 20, 20, 10, 30, 40, 30, 35, 20, 20, 30, 55, 50, 40, 40, 40, 60],
    "u": [35, 20, 10, 30, 40, 40, 30, 20, 30, 40, 30, 40, 40, 50, 50, 60, 60, 80],
    "t": [30, 35, 25, 25, 25, 30, 40, 35, 40, 30, 40, 35, 50, 50, 60, 60, 50, 50],
    "y": [30, 20, 25, 25, 25, 25, 50, 45, 40, 40, 35, 45, 70, 60, 60, 60, 60, 90],
    "a": [50, 50, 50, 15, 20, 40, 30, 10, 20, 10, 10, 30, 50, 40, 30, 30, 20, 40],
    ";": [50, 30, 15, 50, 50, 60, 20, 10, 10, 20, 10, 30, 25, 25, 30, 40, 40, 70],
    "s": [50, 55, 40, 30, 20, 40, 35, 20, 15, 10, 10, 20, 35, 50, 40, 35, 20, 40],
    "l": [50, 40, 30, 40, 55, 50, 20, 10, 10, 15, 20, 40, 15, 20, 30, 40, 60, 70],
    "d": [60, 55, 35, 20, 30, 45, 40, 25, 20, 10, 10, 15, 35, 45, 30, 20, 20, 30],
    "k": [50, 30, 20, 35, 55, 60, 15, 10, 10, 20, 25, 40, 20, 25, 25, 40, 45, 70],
    "f": [50, 50, 30, 10, 35, 45, 40, 20, 20, 12, 10, 30, 35, 40, 40, 25, 25, 30],
    "j": [50, 30, 10, 30, 50, 50, 30, 10, 12, 20, 20, 40, 25, 25, 30, 40, 50, 60],
    "g": [50, 50, 40, 20, 35, 30, 50, 25, 30, 20, 30, 10, 60, 50, 45, 40, 30, 25],
    "h": [30, 20, 15, 30, 55, 50, 10, 30, 18, 30, 25, 45, 25, 30, 30, 40, 60, 70],
    "z": [70, 80, 50, 25, 35, 50, 30, 20, 20, 20, 10, 20, 40, 40, 30, 20, 20, 40],
    "/": [60, 50, 25, 60, 80, 70, 40, 15, 15, 50, 40, 50, 20, 10, 15, 20, 20, 50],
    "x": [60, 70, 60, 45, 55, 60, 40, 45, 40, 30, 30, 25, 40, 20, 20, 10, 10, 20],
    ".": [60, 50, 40, 50, 80, 60, 25, 20, 30, 30, 45, 60, 20, 10, 10, 20, 30, 50],
    "c": [65, 70, 45, 50, 40, 60, 45, 45, 30, 30, 35, 25, 40, 15, 15, 15, 15, 20],
    ",": [60, 50, 45, 50, 80, 60, 40, 25, 30, 35, 45, 60, 20, 15, 15, 20, 30, 70],
    "v": [60, 55, 40, 30, 45, 50, 40, 25, 25, 15, 20, 25, 40, 25, 20, 15, 10, 30],
    "m": [50, 40, 40, 50, 70, 60, 30, 20, 20, 25, 30, 35, 30, 10, 10, 30, 25, 50],
    "b": [70, 65, 50, 35, 70, 60, 60, 30, 30, 15, 35, 30, 50, 25, 30, 25, 30, 10],
    "n": [55, 45, 20, 40, 70, 70, 30, 30, 10, 30, 30, 60, 10, 30, 25, 30, 25, 60],
    "lshift": [60, 50, 40, 30, 35, 40, 50, 40, 20, 15, 10, 25, 20, 20, 30, 20, 15, 25],
    "rshift": [70, 60, 70, 80, 90, 90, 60, 50, 60, 70, 70, 70, 50, 40, 50, 40, 50, 20],
    "tab": [60, 50, 50, 60, 60, 60, 40, 30, 30, 50, 40, 60, 30, 20, 20, 10, 0, 30],
    "caps": [60, 50, 50, 60, 60, 60, 40, 30, 30, 50, 40, 60, 30, 20, 20, 10, 0, 30],
    "bs": [60, 50, 50, 60, 60, 60, 40, 30, 30, 50, 40, 60, 30, 20, 20, 10, 0, 30],
    "enter": [60, 50, 50, 60, 60, 60, 40, 30, 30, 50, 40, 60, 30, 20, 20, 10, 0, 30],
}


class DpState(NamedTuple):
    left_base: str
    right_base: str
    last_hand: Optional[int]
    last_finger: Optional[int]
    last_base_key: Optional[str]
    left_char: str
    right_char: str


class PathNode:
    __slots__ = ["cost", "count", "logs", "prev"]

    def __init__(
        self, cost: float, count: int, logs: List[str], prev: Optional["PathNode"]
    ):
        self.cost = cost
        self.count = count
        self.logs = logs
        self.prev = prev


class TypingCostCalculator:
    def __init__(self, layout: str, verbose: bool = False, cost_mode: str = "default"):
        self.verbose = verbose
        self.cost_mode = cost_mode
        self.layout_map = collections.defaultdict(list)
        self.base_keys_left, self.base_keys_right = [], []

        # 1. レイアウトパース
        tokens = re.findall(r"\[([^\]]+)\]|(.)", layout)
        parsed_layout = [t[0] if t[0] else t[1] for t in tokens]
        base_to_layout_map = {
            BASE_CHARS[i]: parsed_layout[i]
            for i in range(min(len(BASE_CHARS), len(parsed_layout)))
        }

        # 2. 指と手のマッピング構築
        self.base_to_hand_map = {}
        self.base_to_finger_map = {}
        for key, hand, finger in zip(QWERTY_KEYS, LEFT_HAND_MAP, FINGERS_MAP):
            self.base_to_hand_map[key] = hand
            self.base_to_finger_map[key] = finger
            layout_char = base_to_layout_map.get(key, key)
            self.layout_map[layout_char].append(
                {"base": key, "hand": hand, "finger": finger}
            )

        # 3. 左右キーのリスト構築
        for key in QWERTY_KEYS:
            if key in DEFAULT_COST_MATRIX:
                if self.base_to_hand_map[key] == 1:
                    self.base_keys_left.append(key)
                else:
                    self.base_keys_right.append(key)

        self.cost_index_left = {key: i for i, key in enumerate(self.base_keys_left)}
        self.cost_index_right = {key: i for i, key in enumerate(self.base_keys_right)}

        # 4. モードに応じてマトリクスを設定
        if self.cost_mode == "calculated":
            self.cost_matrix = self._generate_calculated_matrix()
            if self.verbose:
                print("[Info] Using Dynamically Calculated Cost Matrix.")
        else:
            self.cost_matrix = DEFAULT_COST_MATRIX
            if self.verbose:
                print("[Info] Using Default Hardcoded Cost Matrix.")

        self.initial_left_base, self.initial_right_base = "f", "j"
        self.initial_left_char = base_to_layout_map.get("f", "f")
        self.initial_right_char = base_to_layout_map.get("j", "j")
        self.left_shift_base, self.right_shift_base = "lshift", "rshift"

    def _generate_calculated_matrix(self) -> dict:
        """
        座標(距離)と生体力学ペナルティに基づく動的マトリクス生成
        """
        calculated_matrix = {}

        # 1. 指ごとの基本重み (小さいほど打ちやすい)
        # 薬指は他の指との独立性が低く、小指は筋力が弱いためペナルティを重く設定
        finger_weights = {
            0: 1.3,  # 小指 (Pinky)
            1: 1.4,  # 薬指 (Ring)
            2: 1.1,  # 中指 (Middle)
            3: 1.0,  # 人差し指 (Index)
            4: 1.0,  # 親指 (Thumb)
        }

        # 2. 指×段(Row)ごとのペナルティマトリクス (y=1がホーム段)
        # 指の長さや構造によって、上段(伸ばす)と下段(曲げる)の得意・不得意が異なる
        # 0: 上段(Top), 1: 中段(Home), 2: 下段(Bottom)
        row_penalties_by_finger = {
            3: {
                0: 1.2,
                1: 1.0,
                2: 1.1,
            },  # 人差し指 (Index)
            2: {
                0: 1.05,
                1: 1.0,
                2: 1.3,
            },  # 中指 (Middle)
            1: {
                0: 1.2,
                1: 1.0,
                2: 1.4,
            },  # 薬指 (Ring)
            0: {
                0: 1.5,
                1: 1.0,
                2: 1.3,
            },  # 小指 (Pinky)
            4: {0: 1.2, 1: 1.0, 2: 1.5},  # 親指 (Thumb)
        }

        base_cost_multiplier = 10.0  # スケール合わせのための係数

        for from_key in self.base_keys_left + self.base_keys_right:
            cost_list = []

            for to_key in self.base_keys_left + self.base_keys_right:
                # 座標が不明な特殊キーなどは固定値
                if from_key not in KEY_COORDS or to_key not in KEY_COORDS:
                    cost_list.append(50)
                    continue

                target_finger = self.base_to_finger_map[to_key]
                from_finger = self.base_to_finger_map.get(from_key, target_finger)

                x1, y1 = KEY_COORDS[from_key]
                x2, y2 = KEY_COORDS[to_key]

                # ==========================================
                # A. 静的コスト (Static Cost)
                # そのキー自体を押すための基本的な負荷
                # ==========================================
                target_row = int(y2) if int(y2) in [0, 1, 2] else 1
                row_penalty = row_penalties_by_finger.get(
                    target_finger, row_penalties_by_finger[3]
                )[target_row]
                base_effort = finger_weights.get(target_finger, 1.0) * row_penalty

                # 人差し指の中心列への横方向ストレッチ(Lateral Stretch)に対するペナルティを行別に加算
                is_center_column = target_finger == 3 and (
                    x2 in [4.0, 4.25, 4.75, 5.0, 5.25, 5.75]
                )
                if is_center_column:
                    if target_row == 0:
                        base_effort *= 1.4  # T, Y
                    elif target_row == 1:
                        base_effort *= 1.2  # G, H
                    else:
                        base_effort *= 1.1  # B, N

                # 小指の外側ストレッチ(Outer Pinky Stretch)に対するペナルティを加算
                is_outer_pinky = target_finger == 0 and x2 in [
                    0.0,
                    0.75,
                    9.0,
                    9.75,
                    10.0,
                ]
                if is_outer_pinky:
                    base_effort *= 1.2

                static_cost = base_effort * base_cost_multiplier

                # ==========================================
                # B. 動的コスト (Dynamic Cost / Travel Cost)
                # 直前のキーからの移動に伴う負荷
                # ==========================================
                dynamic_cost = 0.0

                if from_key == to_key:
                    # 全く同じキーの連続打鍵
                    # total cost = static_cost * 0.2
                    # dynamic_cost as diff: static_cost * 0.2 - static_cost
                    dynamic_cost = -static_cost * 0.8
                elif from_finger == target_finger:
                    # 同じ指が連続して違うキーに移動する場合 (SFBの物理的移動成分)
                    dx = abs(x2 - x1)
                    dy = abs(y2 - y1)
                    travel_distance = math.sqrt((dx * 1.5) ** 2 + dy**2)

                    dynamic_cost = (
                        (travel_distance**1.2)
                        * 4.0
                        * finger_weights.get(target_finger, 1.0)
                        * base_cost_multiplier
                    )
                else:
                    dynamic_cost = 0.0

                # 最終コストは 静的コスト + 動的コスト (tupleで返す)
                cost_list.append((int(static_cost), int(dynamic_cost)))

            calculated_matrix[from_key] = cost_list

        return calculated_matrix

    def _get_cost(self, from_base: str, to_base: str, to_hand: int) -> Tuple[int, int]:
        try:
            if from_base not in self.cost_matrix:
                return 0, 0
            cost_list = self.cost_matrix[from_base]

            if to_hand == 1:
                target_index = self.cost_index_left[to_base]
            else:
                target_index = self.cost_index_right[to_base]
                # calculatedモードでは左右の全キーが連結されたリストが生成されるためオフセットが必要
                if self.cost_mode == "calculated":
                    target_index += len(self.base_keys_left)

            val = cost_list[target_index]
            if isinstance(val, tuple):
                return val[0], val[1]
            return val, 0
        except (KeyError, IndexError):
            return 0, 0

    def calculate(
        self,
        text: str,
        sfb_base_penalty: int = 80,
        scissor_penalty: int = 50,
        row_jump_penalty: int = 30,
        inward_roll_bonus: int = 5,
        outward_roll_bonus: int = 2,
        alternation_bonus: int = 3,
    ) -> Tuple[float, float, int]:

        initial_state = DpState(
            self.initial_left_base,
            self.initial_right_base,
            None,
            None,
            None,
            self.initial_left_char,
            self.initial_right_char,
        )
        dp = collections.defaultdict(dict)
        dp[0] = {initial_state: PathNode(0, 0, [], None)}
        processed_text = text.replace("\r\n", "\n").replace("\r", "\n")
        total_len = len(processed_text)
        layout_keys_str = [
            k for k in self.layout_map.keys() if k not in ["enter", "tab"]
        ]

        for i in range(total_len):
            if not dp[i]:
                continue

            matches = []
            char = processed_text[i]
            if char == "\n" and "enter" in self.layout_map:
                matches.append(("enter", 1, False, "enter"))
            elif char == "\t" and "tab" in self.layout_map:
                matches.append(("tab", 1, False, "tab"))
            else:
                for key_str in layout_keys_str:
                    match_len = len(key_str)
                    if (
                        i + match_len <= total_len
                        and processed_text[i : i + match_len].lower() == key_str
                    ):
                        matches.append(
                            (
                                key_str,
                                match_len,
                                processed_text[i : i + match_len][0].isupper(),
                                processed_text[i : i + match_len],
                            )
                        )

            if not matches:
                for state_key, node in dp[i].items():
                    if (
                        state_key not in dp[i + 1]
                        or dp[i + 1][state_key].cost > node.cost
                    ):
                        dp[i + 1][state_key] = PathNode(
                            node.cost, node.count, node.logs, node.prev
                        )
                del dp[i]
                continue

            for state, node in dp[i].items():
                for key_str, match_len, is_upper, display_char in matches:
                    for cand in self.layout_map[key_str]:
                        cand_base_key, cand_hand, cand_finger = (
                            cand["base"],
                            cand["hand"],
                            cand["finger"],
                        )
                        step_logs = [] if self.verbose else None
                        step_cost, step_count = 0, 0

                        c_l_base, c_r_base = state.left_base, state.right_base
                        c_l_char, c_r_char = state.left_char, state.right_char
                        c_hand, c_finger, c_base = (
                            state.last_hand,
                            state.last_finger,
                            state.last_base_key,
                        )

                        if is_upper:
                            s_hand = 0 if cand_hand == 1 else 1
                            s_base = (
                                self.right_shift_base
                                if s_hand == 0
                                else self.left_shift_base
                            )
                            last_s_base = c_l_base if s_hand == 1 else c_r_base
                            s_static, s_dynamic = self._get_cost(
                                last_s_base, s_base, s_hand
                            )
                            s_cost = s_static
                            if c_hand == s_hand:
                                s_cost += s_dynamic
                            step_cost += max(0, s_cost)

                            c_hand, c_finger, c_base = s_hand, 0, s_base
                            if s_hand == 1:
                                c_l_base = c_l_char = s_base
                            else:
                                c_r_base = c_r_char = s_base

                        last_m_base = c_l_base if cand_hand == 1 else c_r_base
                        main_static, main_dynamic = self._get_cost(
                            last_m_base, cand_base_key, cand_hand
                        )
                        main_cost = main_static

                        if c_hand == cand_hand:
                            main_cost += main_dynamic
                            if self.verbose and main_dynamic != 0:
                                if main_dynamic < 0:
                                    step_logs.append(
                                        f"  -> Double Tap Discount ({main_dynamic})"
                                    )
                                else:
                                    step_logs.append(
                                        f"  -> Dynamic Cost (+{main_dynamic})"
                                    )

                            # 1. SFB (Same Finger Bigram)
                            if c_finger == cand_finger and c_base != cand_base_key:
                                cand_row = ROW_MAP.get(cand_base_key, 1)
                                cur_row = ROW_MAP.get(c_base, 1)

                                # 薬指と小指は独立性ペナルティを重くする
                                weakness_multiplier = (
                                    1.5 if cand_finger in [0, 1] else 1.0
                                )
                                distance_penalty = abs(cur_row - cand_row) * 10

                                sfb_total = (
                                    sfb_base_penalty + distance_penalty
                                ) * weakness_multiplier
                                main_cost += sfb_total
                                if self.verbose:
                                    step_logs.append(f"  -> SFB Penalty (+{sfb_total})")

                            elif c_finger != cand_finger:
                                cand_row = ROW_MAP.get(cand_base_key, 1)
                                cur_row = ROW_MAP.get(c_base, 1)

                                # 2. Row Jump
                                if abs(cur_row - cand_row) == 2:
                                    main_cost += row_jump_penalty
                                    if self.verbose:
                                        step_logs.append(
                                            f"  -> Row Jump Penalty (+{row_jump_penalty})"
                                        )

                                # 3. Scissors
                                if (
                                    c_finger is not None
                                    and abs(c_finger - cand_finger) == 1
                                    and cur_row != cand_row
                                ):
                                    main_cost += scissor_penalty
                                    if self.verbose:
                                        step_logs.append(
                                            f"  -> Scissors Penalty (+{scissor_penalty})"
                                        )

                                # 4. Rolls (隣り合う指のみ)
                                if (
                                    c_finger is not None
                                    and abs(c_finger - cand_finger) == 1
                                ):
                                    if c_finger < cand_finger:
                                        main_cost -= inward_roll_bonus
                                        if self.verbose:
                                            step_logs.append(
                                                f"  -> Inward Roll (-{inward_roll_bonus})"
                                            )
                                    else:
                                        main_cost -= outward_roll_bonus
                                        if self.verbose:
                                            step_logs.append(
                                                f"  -> Outward Roll (-{outward_roll_bonus})"
                                            )
                        else:
                            if c_hand is not None:
                                main_cost -= alternation_bonus
                                if self.verbose:
                                    step_logs.append(
                                        f"  -> Alternation Bonus (-{alternation_bonus})"
                                    )

                        main_cost = max(0, main_cost)
                        step_cost += main_cost
                        step_count += match_len

                        if cand_hand == 1:
                            c_l_base, c_l_char = cand_base_key, key_str
                        else:
                            c_r_base, c_r_char = cand_base_key, key_str

                        new_state = DpState(
                            c_l_base,
                            c_r_base,
                            cand_hand,
                            cand_finger,
                            cand_base_key,
                            c_l_char,
                            c_r_char,
                        )
                        target_i = i + match_len
                        new_cost = node.cost + step_cost

                        if (
                            new_state not in dp[target_i]
                            or dp[target_i][new_state].cost > new_cost
                        ):
                            dp[target_i][new_state] = PathNode(
                                new_cost,
                                node.count + step_count,
                                step_logs if self.verbose else [],
                                node,
                            )
            del dp[i]

        states = dp[len(processed_text)]
        if not states:
            return 0, -20, 0

        best_node = min(states.values(), key=lambda n: n.cost)
        return (
            best_node.cost,
            (best_node.cost / best_node.count if best_node.count > 0 else 0),
            best_node.count,
        )


def evaluate_layout(
    name: str,
    layout: str,
    text_to_check: str,
    cost_mode: str = "default",
    norm: float = 1.0,
    silent: bool = False,
) -> float:
    # "default" か "calculated" を指定して初期化
    calculator = TypingCostCalculator(layout, verbose=False, cost_mode=cost_mode)
    _, normalized_cost, _ = calculator.calculate(text_to_check)
    result = (normalized_cost / norm) * 100 if norm != 1.0 else normalized_cost
    if not silent:
        print(f"[{cost_mode.upper():<10}] Layout: {name:<12} : Score: {result:.4f}")
    return result


if __name__ == "__main__":
    # ⚠️ This path needs to be changed depending on the execution environment.
    japanese = False
    japanese = True
    cost_mode = "default"
    # cost_mode = "calculated"

    max_chars = 100000  # 測定するテキストの文字数の最大値

    if japanese:
        file_path = "../data/jap-n.txt"
    else:
        file_path = "../data/English_sample.txt"

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            text_to_check = f.read()

        if len(text_to_check) > max_chars:
            text_to_check = text_to_check[:max_chars]

        text_alt = None
        if japanese:
            text_alt = (
                text_to_check.replace("ja", "zya")
                .replace("ji", "zi")
                .replace("ju", "zyu")
                .replace("je", "zhe")
                .replace("jo", "zyo")
                .replace("Ja", "Zya")
                .replace("Ji", "Zi")
                .replace("Ju", "Zyu")
                .replace("Je", "Zhe")
                .replace("Jo", "Zyo")
            )

        print("-" * 50)
        print(f"File: '{file_path}' (Japanese Mode: {japanese})")
        print(f"Max Chars: {max_chars}")
        print("-" * 50)

        # 1. 基準となるQWERTYのスコアを計算
        qwerty_layout = "qwertyuiopasdfghjkl;zxcvbnm,./"
        qwerty_score_orig = evaluate_layout(
            "QWERTY", qwerty_layout, text_to_check, cost_mode, norm=1.0, silent=True
        )
        if text_alt:
            qwerty_score_alt = evaluate_layout(
                "QWERTY", qwerty_layout, text_alt, cost_mode, norm=1.0, silent=True
            )
            qwerty_norm = min(qwerty_score_orig, qwerty_score_alt)
        else:
            qwerty_norm = qwerty_score_orig

        # 2. 評価する共通レイアウトのリスト
        layouts_to_test = [
            ("QWERTY", "qwertyuiopasdfghjkl;zxcvbnm,./"),
            # ("Arensito", "ql,p/;fudkarenbgsitozw.hjvcymx"),
            ("FMIX15", "qwldkjfuy;asrtghneiozxcvbpm,./"),
            ("FMIX16", "qwldkjfuy;arstghneiozxcvbpm,./"),
            # ("FMIX16_2", "qwldjkfuy;arstghneiozxcvbpm,./"),
            ("MTGAP", "ypoujkdlcwinea,mhtsrqz/.:bfgvx"),
            ("FMIX12f", "qwfrkylup;asdtghneiozxcvbjm,./"),
            # ("FMIX12", "qwlrkyfup;asdtghneiozxcvbjm,./"),
            #            ("FMIX13", 'qwrlkyfup;asdtghneiozxcvbjm,./'),
            ("Colemak", "qwfpgjluy;arstdhneiozxcvbkm,./"),
            #            ("FMIX14", 'qwldkyfup;asrtghneiozxcvbjm,./'),
            #            ("FMIX14 fuj", 'qwldkyfuj;asrtghneiozxcvbpm,./'),
            #            ("FMIX14 vbk", 'qwldjyfup;asrtghneiozxcvbkm,./'),
            ("Dvorak", "/,.pyfgcrlaoeuidhtns;qjkxbmwvz"),
            # ("aret", "qcufkzlpy;aretdmnoisjwxgbvh,./"),
            ("Wakasagi", "qprdcbkuyxatnswmheio/,lgjfv;z."),
            # ("Boo", ",.ucvqfdlyaoesgbntri;x/wzphmkj"),
            #            ("Stronk", 'fdlbvjgou,strnkymaeizqxhpwc/;.'),
            #            ("aptv3", 'wgdfbqluoyrsthkjneaixcmpvz,.;/'),
            ("kotone", "qwdrfjluyxnstegceaiozpmhbkv,./"),
            ("kotone2", "qwrdfjluyxnstegceaiozpmhbkv,./"),
            #            ("kotone3", 'qwrdfjluyxsntegceaiozpmhbkv,./'),
            #            ("kotone4", 'qwrdfjluyxstnegceaiozpmhbkv,./'),
            ("kotone5", "qwrdfjluyxnstagcaieozpmhbkv,./"),
            ("kotone6", "qwrdfjluyxnstagcaeiozpmhbkv,./"),
        ]

        # 3. 日本語モードの場合は、日本語特化配列を追加
        if japanese:
            layouts_to_test.extend(
                [
                    ("kotone2j", "qwrdfj[yu]u[yo]xnstkgceaiozpmhb-[ya],./"),
                    ("FMIX13R", "qwdrfylup-asktghneiozxcvbjm,./"),
                    ("kotone5j", "qwrdfj[yu]u[yo]xnstkgcaieozpmhb-[ya],./"),
                    ("minato", "qwrdfj[yu]u[yo]xnsktgcaieozpmhb-[ya],./"),
                    ("kotone6j", "qwrdfj[yu]u[yo]xnstkgcaeiozpmhb-[ya],./"),
                ]
            )

        # 4. ループで一括スコアリング
        for name, layout in layouts_to_test:
            score_orig = evaluate_layout(
                name, layout, text_to_check, cost_mode, norm=qwerty_norm, silent=True
            )
            if text_alt:
                score_alt = evaluate_layout(
                    name, layout, text_alt, cost_mode, norm=qwerty_norm, silent=True
                )
                best_score = min(score_orig, score_alt)
                label = "Orig" if score_orig <= score_alt else "Alt(zya)"
                print(
                    f"[{cost_mode.upper():<10}] Layout: {name:<12} : Score: {best_score:.4f} ({label})"
                )
            else:
                print(
                    f"[{cost_mode.upper():<10}] Layout: {name:<12} : Score: {score_orig:.4f}"
                )

        print("-" * 50)

    except FileNotFoundError:
        print(
            f"\nError: File '{file_path}' not found. Please check the path.",
            file=sys.stderr,
        )
    except Exception as e:
        print(f"\nAn error occurred: {e}", file=sys.stderr)
