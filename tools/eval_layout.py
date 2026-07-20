import sys
import os
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

COL_MAP = {
    "q": 0,
    "w": 1,
    "e": 2,
    "r": 3,
    "t": 4,
    "y": 5,
    "u": 6,
    "i": 7,
    "o": 8,
    "p": 9,
    "a": 0,
    "s": 1,
    "d": 2,
    "f": 3,
    "g": 4,
    "h": 5,
    "j": 6,
    "k": 7,
    "l": 8,
    ";": 9,
    "z": 0,
    "x": 1,
    "c": 2,
    "v": 3,
    "b": 4,
    "n": 5,
    "m": 6,
    ",": 7,
    ".": 8,
    "/": 9,
}


class DpState(NamedTuple):
    finger_pos: Tuple[Optional[str], ...]
    last_hand: Optional[int]
    last_finger: Optional[int]
    last_last_finger: Optional[int]
    last_base_key: Optional[str]
    same_hand_count: int


class PathNode:
    __slots__ = [
        "cost",
        "count",
        "comps",
        "logs",
        "prev",
        "history",
        "coms",
        "hand_history",
    ]

    def __init__(
        self,
        cost: float,
        count: int,
        comps: Tuple[float, ...],
        logs: List[str],
        prev: Optional["PathNode"],
        history: Tuple[Tuple[int, int, str], ...] = (),
        coms: Optional[Dict[int, Tuple[float, float]]] = None,
        hand_history: Optional[Dict[int, List[Tuple[float, float]]]] = None,
    ):
        self.cost = cost
        self.count = count
        self.comps = comps
        self.logs = logs
        self.prev = prev
        self.history = history
        self.coms = coms if coms is not None else {1: (1.5, 1.0), 0: (7.5, 1.0)}
        self.hand_history = hand_history if hand_history is not None else {1: [], 0: []}


class TypingCostCalculator:
    def __init__(
        self,
        layout: str,
        verbose: bool = False,
        cost_mode: str = "default",
        board_mode: str = "row_staggered",
        angle_of_approach: float = 15.0,
    ):
        self.verbose = verbose
        self.cost_mode = cost_mode
        self.board_mode = board_mode
        self.angle_of_approach = angle_of_approach
        self.layout_map = collections.defaultdict(list)
        self.base_keys_left, self.base_keys_right = [], []

        # 指の動的コスト（独立性の低さ）ペナルティ係数
        self.finger_dynamic_weights = {
            0: 1.6,  # 小指
            1: 2.0,  # 薬指
            2: 1.2,  # 中指
            3: 1.0,  # 人差し指
            4: 1.0,  # 親指
        }

        # 親指 CMC関節座標と極座標ウェイト
        self.cmc_coords = {1: (3.5, 4.5), 0: (6.5, 4.5)}  # 1:Left, 0:Right
        self.thumb_polar_weights = {"r": 30.0, "theta": 10.0}

        # 腱の連動ペナルティパラメータ
        self.tendon_threshold = 0.5
        self.tendon_params = {
            (0, 1): {"alpha": 15.0, "beta": 2.0},  # 小指 - 薬指
            (1, 0): {"alpha": 15.0, "beta": 2.0},  # 薬指 - 小指
            (1, 2): {"alpha": 10.0, "beta": 1.0},  # 薬指 - 中指
            (2, 1): {"alpha": 10.0, "beta": 1.0},  # 中指 - 薬指
        }

        # Z軸パラメータ (3D Kinematics)
        self.z_offset = {0: 0.15, 1: 0.00, 2: -0.10}

        # 1. レイアウトパース
        tokens = re.findall(r"\[([^\]]+)\]|(.)", layout)
        parsed_layout = []
        self.shifted_map = {}
        for t in tokens:
            content = t[0] if t[0] else t[1]
            if "," in content:
                base, shifted = content.split(",", 1)
                parsed_layout.append(base)
                self.shifted_map[shifted] = base
            else:
                parsed_layout.append(content)

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

        # 3. 物理座標の生成
        self.key_coords = self._generate_physical_coords(self.board_mode)

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

        self.neutral_distances = {1: {}, 0: {}}
        left_homes = {0: "a", 1: "s", 2: "d", 3: "f"}
        right_homes = {0: ";", 1: "l", 2: "k", 3: "j"}
        for h, homes in [(1, left_homes), (0, right_homes)]:
            for f1 in [0, 1, 2, 3]:
                self.neutral_distances[h][f1] = {}
                for f2 in [0, 1, 2, 3]:
                    c1 = self.key_coords[homes[f1]]
                    c2 = self.key_coords[homes[f2]]
                    dx = (c1[0] - c2[0]) * 1.5
                    dy = c1[1] - c2[1]
                    dist = (dx * dx + dy * dy) ** 0.5
                    self.neutral_distances[h][f1][f2] = dist

    def _generate_physical_coords(self, board_mode: str) -> dict:
        coords = {}
        grid = {
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
            "a": (0, 1),
            "s": (1, 1),
            "d": (2, 1),
            "f": (3, 1),
            "g": (4, 1),
            "h": (5, 1),
            "j": (6, 1),
            "k": (7, 1),
            "l": (8, 1),
            ";": (9, 1),
            "z": (0, 2),
            "x": (1, 2),
            "c": (2, 2),
            "v": (3, 2),
            "b": (4, 2),
            "n": (5, 2),
            "m": (6, 2),
            ",": (7, 2),
            ".": (8, 2),
            "/": (9, 2),
        }
        for key, (x_g, y_g) in grid.items():
            if board_mode == "row_staggered":
                offset = -0.25 if y_g == 0 else (0.00 if y_g == 1 else 0.50)
                coords[key] = (x_g + offset, y_g)
            elif board_mode == "ortholinear":
                coords[key] = (x_g, y_g)
            elif board_mode == "column_staggered":
                offset_col = [
                    +0.25,
                    +0.10,
                    -0.15,
                    0.00,
                    0.00,
                    0.00,
                    0.00,
                    -0.15,
                    +0.10,
                    +0.25,
                ]
                coords[key] = (x_g, y_g + offset_col[x_g])
            else:
                offset = -0.25 if y_g == 0 else (0.00 if y_g == 1 else 0.50)
                coords[key] = (x_g + offset, y_g)
        coords.update(
            {
                "tab": (-1, 0),
                "caps": (-1, 1),
                "lshift": (-1, 2),
                "bs": (10, 0),
                "enter": (10, 1),
                "rshift": (10, 2),
                "lthumb": (3.5, 3),
                "rthumb": (6.5, 3),
            }
        )

        # Angle of Approach 適用 (回転)
        theta = math.radians(self.angle_of_approach)
        cos_t = math.cos(theta)
        sin_t = math.sin(theta)

        rotated_coords = {}
        for key, (x, y) in coords.items():
            if key in self.base_to_hand_map:
                hand = self.base_to_hand_map[key]
            elif key in ["tab", "caps", "lshift", "lthumb"]:
                hand = 1
            elif key in ["bs", "enter", "rshift", "rthumb"]:
                hand = 0
            else:
                hand = 1

            if hand == 1:  # 左手: 時計回り (theta)
                rx = x * cos_t - y * sin_t
                ry = x * sin_t + y * cos_t
            else:  # 右手: 反時計回り (-theta)
                rx = x * cos_t + y * sin_t
                ry = -x * sin_t + y * cos_t
            rotated_coords[key] = (rx, ry)

        return rotated_coords

    def _generate_calculated_matrix(self) -> dict:
        """
        座標(距離)と生体力学ペナルティに基づく動的マトリクス生成
        """
        calculated_matrix = {}

        # 1. 左右独立の指筋力ウェイト (W_strength[Hand][f])
        # Hand (0: 右手, 1: 左手)
        finger_weights = {
            1: {0: 1.80, 1: 1.40, 2: 1.10, 3: 1.00, 4: 1.00},  # 左手
            0: {0: 1.80, 1: 1.40, 2: 1.10, 3: 1.00, 4: 1.00},  # 右手
        }

        # 2. 指×段(Row)ごとのペナルティマトリクス (y=1がホーム段)
        row_penalties_by_finger = {
            3: {0: 1.20, 1: 1.00, 2: 1.10},  # 人差し指
            2: {0: 1.05, 1: 1.00, 2: 1.20},  # 中指
            1: {0: 1.20, 1: 1.00, 2: 1.40},  # 薬指
            0: {0: 1.50, 1: 1.00, 2: 1.50},  # 小指
            4: {0: 1.20, 1: 1.00, 2: 1.50},  # 親指
        }

        base_cost_multiplier = 10.0  # スケール合わせのための係数

        for from_key in self.base_keys_left + self.base_keys_right:
            cost_list = []

            for to_key in self.base_keys_left + self.base_keys_right:
                # 座標が不明な特殊キーなどは固定値
                if from_key not in self.key_coords or to_key not in self.key_coords:
                    cost_list.append(50)
                    continue

                target_hand = self.base_to_hand_map[to_key]
                target_finger = self.base_to_finger_map[to_key]

                x1, y1 = self.key_coords[from_key]
                x2, y2 = self.key_coords[to_key]

                # grid座標の取得
                x_grid = COL_MAP.get(to_key, x2)
                y_grid = ROW_MAP.get(to_key, y2)

                # ==========================================
                # A. 静的コスト (Static Cost)
                # ==========================================
                target_row = int(y_grid) if int(y_grid) in [0, 1, 2] else 1
                row_penalty = row_penalties_by_finger.get(
                    target_finger, row_penalties_by_finger[3]
                ).get(target_row, 1.0)

                # ラテラルストレッチ・ペナルティ
                lat_penalty = 1.0
                if target_finger == 3 and x_grid in [4, 5]:  # 人差し指内側拡張列
                    if target_row == 0:
                        lat_penalty = 1.50
                    elif target_row == 1:
                        lat_penalty = 1.20
                    else:
                        lat_penalty = 1.40
                elif target_finger == 0 and (
                    x_grid < 0 or x_grid > 9
                ):  # 小指外側拡張列
                    lat_penalty = 1.40

                strength_w = finger_weights[target_hand][target_finger]
                static_cost = (
                    strength_w * row_penalty * lat_penalty * base_cost_multiplier
                )

                # ==========================================
                # B. 物理移動コスト (C_move)
                # ==========================================
                if from_key == to_key:
                    # 同一キー連続打鍵は calculate 内で特別に処理するため、ここでは 0
                    dynamic_cost = 0.0
                else:
                    if target_finger == 4:
                        # 親指の円弧運動（極座標）計算
                        cmc_x, cmc_y = self.cmc_coords[target_hand]
                        r1 = math.sqrt((x1 - cmc_x) ** 2 + (y1 - cmc_y) ** 2)
                        th1 = math.atan2(y1 - cmc_y, x1 - cmc_x)
                        r2 = math.sqrt((x2 - cmc_x) ** 2 + (y2 - cmc_y) ** 2)
                        th2 = math.atan2(y2 - cmc_y, x2 - cmc_x)
                        dr = abs(r2 - r1)
                        dth = abs(th2 - th1)
                        dynamic_cost = (
                            self.thumb_polar_weights["r"] * dr
                            + self.thumb_polar_weights["theta"] * dth
                        ) * strength_w
                    else:
                        dx = x2 - x1
                        dy = y2 - y1
                        y_grid_from = ROW_MAP.get(from_key, 1)
                        z1 = self.z_offset.get(y_grid_from, 0.0)
                        z2 = self.z_offset.get(y_grid, 0.0)
                        dz = z2 - z1
                        w_z = 2.5 if dz > 0 else 1.0
                        d = math.sqrt((dx * 1.5) ** 2 + dy**2 + (dz * w_z) ** 2)

                        # 距離依存の有効ターゲット縮小モデル (Fitts変形型)
                        # W_eff = 1 / (1 + k * D)
                        k = 0.5
                        fitts_id = math.log2(1.0 + d * (1.0 + k * d))
                        dynamic_cost = fitts_id * strength_w * base_cost_multiplier

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
        scissor_penalty: int = 10,
        row_jump_penalty: int = 15,
        inward_roll_bonus: int = 10,
        outward_roll_bonus: int = 5,
        alternation_bonus: int = 0,
    ) -> Tuple[float, float, int]:

        initial_finger_pos = ("a", "s", "d", "f", None, ";", "l", "k", "j", None)
        initial_state = DpState(
            initial_finger_pos,
            None,
            None,
            None,
            None,
            0,
        )
        initial_comps = (0.0,) * 17
        dp = collections.defaultdict(dict)
        dp[0] = {initial_state: PathNode(0, 0, initial_comps, [], None, ())}
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
                matches.append(("enter", 1, False, False, False, "enter"))
            elif char == "\t" and "tab" in self.layout_map:
                matches.append(("tab", 1, False, False, False, "tab"))
            elif char == "-" and "-" not in self.layout_map:
                matches.append(("-", 1, False, True, False, "-"))
            else:
                for key_str in layout_keys_str:
                    match_len = len(key_str)
                    if match_len == 0:
                        continue
                    if (
                        i + match_len <= total_len
                        and processed_text[i : i + match_len].lower() == key_str
                    ):
                        matches.append(
                            (
                                key_str,
                                match_len,
                                processed_text[i : i + match_len][0].isupper(),
                                False,
                                False,
                                processed_text[i : i + match_len],
                            )
                        )
                if hasattr(self, "shifted_map"):
                    for shifted_str, base_str in self.shifted_map.items():
                        match_len = len(shifted_str)
                        if match_len == 0:
                            continue
                        if (
                            i + match_len <= total_len
                            and processed_text[i : i + match_len] == shifted_str
                        ):
                            if base_str in self.layout_map:
                                matches.append(
                                    (
                                        base_str,
                                        match_len,
                                        False,
                                        False,
                                        True,
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
                            node.cost,
                            node.count,
                            node.comps,
                            node.logs,
                            node.prev,
                            node.history,
                            node.coms,
                            node.hand_history,
                        )
                del dp[i]
                continue

            for state, node in dp[i].items():
                for (
                    key_str,
                    match_len,
                    is_upper,
                    is_thumb_mod,
                    is_sands,
                    display_char,
                ) in matches:
                    cands = (
                        self.layout_map[key_str]
                        if not is_thumb_mod
                        else [{"base": "f", "hand": 1, "finger": 3}]
                    )
                    for cand in cands:
                        cand_base_key, cand_hand, cand_finger = (
                            cand["base"],
                            cand["hand"],
                            cand["finger"],
                        )
                        step_logs = [] if self.verbose else None
                        step_cost, step_count = 0, 0

                        c_finger_pos = list(state.finger_pos)
                        c_hand, c_finger, c_base = (
                            state.last_hand,
                            state.last_finger,
                            state.last_base_key,
                        )
                        c_last_last_finger = state.last_last_finger

                        c_static = c_move = c_sfb = c_scissor = c_row_jump = c_roll = (
                            c_redirect
                        ) = c_shift = c_doubletap = c_fatigue = c_hand_split = 0.0
                        c_sfs = c_lss = c_fss = c_tenodesis = c_base_stroke = 0.0

                        if is_thumb_mod:
                            c_base_stroke += 10.0
                            t_hand = 0 if cand_hand == 1 else 1
                            t_base = "rthumb" if t_hand == 0 else "lthumb"
                            t_idx = 4 if t_hand == 1 else 9
                            last_t_base = c_finger_pos[t_idx]
                            t_static, t_dynamic = (
                                self._get_cost(last_t_base, t_base, t_hand)
                                if last_t_base
                                else (0.0, 0.0)
                            )
                            t_cost = t_static
                            if c_hand == t_hand:
                                t_cost += t_dynamic
                            step_cost += max(0, t_cost)
                            c_shift += max(0, t_cost)

                            c_last_last_finger = c_finger if t_hand == c_hand else None
                            c_hand, c_finger, c_base = t_hand, 4, t_base
                            c_finger_pos[t_idx] = t_base
                        if is_upper:
                            c_base_stroke += 10.0
                            s_hand = 0 if cand_hand == 1 else 1
                            s_base = "rthumb" if s_hand == 0 else "lthumb"
                            s_idx = 4 if s_hand == 1 else 9
                            last_s_base = c_finger_pos[s_idx]
                            s_static, s_dynamic = (
                                self._get_cost(last_s_base, s_base, s_hand)
                                if last_s_base
                                else (0.0, 0.0)
                            )
                            s_cost = s_static
                            if c_hand == s_hand:
                                s_cost += s_dynamic
                            step_cost += max(0, s_cost)
                            c_shift += max(0, s_cost)

                            c_last_last_finger = c_finger if s_hand == c_hand else None
                            c_hand, c_finger, c_base = s_hand, 4, s_base
                            c_finger_pos[s_idx] = s_base

                        if is_sands:
                            c_base_stroke += 10.0
                            s_hand = 0 if cand_hand == 1 else 1
                            s_base = "rthumb" if s_hand == 0 else "lthumb"
                            s_idx = 4 if s_hand == 1 else 9

                            s_cost = 10.0
                            step_cost += s_cost
                            c_shift += s_cost

                            c_last_last_finger = c_finger if s_hand == c_hand else None
                            c_hand, c_finger, c_base = s_hand, 4, s_base
                            c_finger_pos[s_idx] = s_base

                        cand_idx = cand_finger if cand_hand == 1 else cand_finger + 5

                        c_base_stroke += 10.0

                        main_static, _ = self._get_cost(
                            cand_base_key, cand_base_key, cand_hand
                        )

                        if c_base == cand_base_key:
                            main_cost = main_static * 0.2
                            c_doubletap += main_cost
                            if self.verbose:
                                step_logs.append(
                                    f"  -> Double Tap Discount (stroke cost: {main_cost:.2f})"
                                )
                        else:
                            # 指の屈曲限界 (Bottom Row Flexion Limit)
                            flexion_multiplier = 1.0
                            if (
                                cand_finger in [1, 2]
                                and ROW_MAP.get(cand_base_key, 1) == 2
                            ):
                                idx_finger_idx = 3 if cand_hand == 1 else 8
                                idx_finger_key = c_finger_pos[idx_finger_idx]
                                if (
                                    idx_finger_key
                                    and ROW_MAP.get(idx_finger_key, 1) == 0
                                ):
                                    flexion_multiplier = 1.5
                                    if self.verbose:
                                        step_logs.append(
                                            "  -> Bottom Row Flexion Limit Multiplier (x1.5)"
                                        )

                            c_static += main_static * flexion_multiplier
                            last_same_finger_base = c_finger_pos[cand_idx]
                            _, move_cost = (
                                self._get_cost(
                                    last_same_finger_base, cand_base_key, cand_hand
                                )
                                if last_same_finger_base
                                else (0.0, 0.0)
                            )
                            c_move += move_cost * flexion_multiplier

                            p_sfb = p_scissor = p_row_jump = p_redirect = p_roll = (
                                p_hand_split
                            ) = 0.0
                            p_sfs = p_lss = p_fss = p_tenodesis = p_tendon = 0.0

                            # 1. hand_split (Floating Anchor Model)
                            if cand_finger in [0, 1, 2, 3] and cand_hand in node.coms:
                                com_x, com_y = node.coms[cand_hand]
                                for other_f in [0, 1, 2, 3]:
                                    if other_f != cand_finger:
                                        other_idx = (
                                            other_f if cand_hand == 1 else other_f + 5
                                        )
                                        other_key = c_finger_pos[other_idx]
                                        if other_key and other_key in self.key_coords:
                                            ox, oy = self.key_coords[other_key]
                                            dx = (ox - com_x) * 1.5
                                            dy = oy - com_y
                                            dist_from_com = (dx * dx + dy * dy) ** 0.5
                                            neutral_dist_from_com = (
                                                2.25 if other_f in [0, 3] else 0.75
                                            )
                                            if (
                                                dist_from_com
                                                > neutral_dist_from_com + 1.2
                                            ):
                                                w_dyn = max(
                                                    self.finger_dynamic_weights[
                                                        cand_finger
                                                    ],
                                                    self.finger_dynamic_weights[
                                                        other_f
                                                    ],
                                                )
                                                p_hand_split += (
                                                    (
                                                        dist_from_com
                                                        - neutral_dist_from_com
                                                        - 1.2
                                                    )
                                                    * 15.0
                                                    * w_dyn
                                                )

                                # 腱の連動ペナルティ (Tendon Coupling Penalty)
                                base_offset = 0 if cand_hand == 1 else 5
                                for f1, f2 in [(0, 1), (1, 2), (2, 3)]:
                                    key1 = c_finger_pos[base_offset + f1]
                                    key2 = c_finger_pos[base_offset + f2]
                                    if (
                                        key1
                                        and key2
                                        and key1 in self.key_coords
                                        and key2 in self.key_coords
                                    ):
                                        y1 = self.key_coords[key1][1]
                                        y2 = self.key_coords[key2][1]
                                        dy = abs(y1 - y2)
                                        if dy > self.tendon_threshold:
                                            if (f1, f2) in self.tendon_params:
                                                params = self.tendon_params[(f1, f2)]
                                                p_tendon += params["alpha"] * (
                                                    (dy - self.tendon_threshold)
                                                    ** params["beta"]
                                                )
                                            elif (f2, f1) in self.tendon_params:
                                                params = self.tendon_params[(f2, f1)]
                                                p_tendon += params["alpha"] * (
                                                    (dy - self.tendon_threshold)
                                                    ** params["beta"]
                                                )

                            # 2. Skipgrams (SFS, LSS, FSS) from node.history
                            for h_idx, (prev_hand, prev_finger, prev_key) in enumerate(
                                node.history
                            ):
                                if prev_hand == cand_hand:
                                    diff = h_idx + 2
                                    decay = 0.5 ** (diff - 1)

                                    # SFS (Same Finger Skipgram)
                                    if prev_finger == cand_finger:
                                        dist_sfs = 0.0
                                        if (
                                            prev_key
                                            and prev_key in self.key_coords
                                            and cand_base_key in self.key_coords
                                        ):
                                            c1 = self.key_coords[prev_key]
                                            c2 = self.key_coords[cand_base_key]
                                            dx = (c1[0] - c2[0]) * 1.5
                                            dy = c1[1] - c2[1]
                                            dist_sfs = (dx * dx + dy * dy) ** 0.5
                                        w_dyn = self.finger_dynamic_weights[cand_finger]
                                        p_sfs_base = (
                                            30.0 + 50.0 * (dist_sfs**1.5)
                                        ) * w_dyn
                                        p_sfs += p_sfs_base * decay
                                        if self.verbose:
                                            step_logs.append(
                                                f"  -> SFS Penalty (+{p_sfs_base * decay}, diff={diff})"
                                            )

                                    # LSS (Lateral Stretch Skipgram)
                                    elif (
                                        prev_finger != cand_finger
                                        and prev_finger != 4
                                        and cand_finger != 4
                                    ):
                                        if (
                                            prev_key
                                            and prev_key in self.key_coords
                                            and cand_base_key in self.key_coords
                                        ):
                                            c1 = self.key_coords[prev_key]
                                            c2 = self.key_coords[cand_base_key]
                                            dx = (c2[0] - c1[0]) * 1.5
                                            dy = c2[1] - c1[1]
                                            dist = (dx * dx + dy * dy) ** 0.5
                                            neutral_dist = self.neutral_distances[
                                                cand_hand
                                            ][cand_finger][prev_finger]
                                            if dist > neutral_dist + 1.2:
                                                w_dyn = max(
                                                    self.finger_dynamic_weights[
                                                        cand_finger
                                                    ],
                                                    self.finger_dynamic_weights[
                                                        prev_finger
                                                    ],
                                                )
                                                p_lss_base = (
                                                    (dist - neutral_dist - 1.2)
                                                    * 15.0
                                                    * w_dyn
                                                )
                                                p_lss += p_lss_base * decay
                                                if self.verbose:
                                                    step_logs.append(
                                                        f"  -> LSS Penalty (+{p_lss_base * decay}, diff={diff})"
                                                    )

                                    # FSS (Full Scissor Skipgram)
                                    if (
                                        prev_finger != cand_finger
                                        and abs(prev_finger - cand_finger) == 1
                                        and prev_finger != 4
                                        and cand_finger != 4
                                    ):
                                        if prev_key:
                                            cand_row = ROW_MAP.get(cand_base_key, 1)
                                            prev_row = ROW_MAP.get(prev_key, 1)
                                            if (prev_row == 0 and cand_row == 2) or (
                                                prev_row == 2 and cand_row == 0
                                            ):
                                                w_dyn = max(
                                                    self.finger_dynamic_weights[
                                                        cand_finger
                                                    ],
                                                    self.finger_dynamic_weights[
                                                        prev_finger
                                                    ],
                                                )
                                                p_fss += (
                                                    float(scissor_penalty)
                                                    * w_dyn
                                                    * decay
                                                )
                                                if self.verbose:
                                                    step_logs.append(
                                                        f"  -> FSS Penalty (+{float(scissor_penalty) * w_dyn * decay}, diff={diff})"
                                                    )

                            if c_hand is not None:
                                # 同一手・同一指 (SFB)
                                if c_hand == cand_hand and c_finger == cand_finger:
                                    dist_sfb = 0.0
                                    if (
                                        c_base
                                        and c_base in self.key_coords
                                        and cand_base_key in self.key_coords
                                    ):
                                        c1 = self.key_coords[c_base]
                                        c2 = self.key_coords[cand_base_key]
                                        dx = (c1[0] - c2[0]) * 1.5
                                        dy = c1[1] - c2[1]
                                        z1 = self.z_offset.get(
                                            ROW_MAP.get(c_base, 1), 0.0
                                        )
                                        z2 = self.z_offset.get(
                                            ROW_MAP.get(cand_base_key, 1), 0.0
                                        )
                                        dz = z2 - z1
                                        w_z = 2.5 if dz > 0 else 1.0
                                        dist_sfb = (
                                            dx * dx + dy * dy + (dz * w_z) ** 2
                                        ) ** 0.5

                                    w_dyn = self.finger_dynamic_weights[cand_finger]
                                    p_sfb = (30.0 + 50.0 * (dist_sfb**1.5)) * w_dyn
                                    if self.verbose:
                                        step_logs.append(f"  -> SFB Penalty (+{p_sfb})")

                                # 同一手・異なる指 (Scissor, Row Jump, Roll, Redirect, Tenodesis)
                                if (
                                    c_finger is not None
                                    and cand_finger is not None
                                    and c_finger != cand_finger
                                ):
                                    cand_row = ROW_MAP.get(cand_base_key, 1)
                                    cur_row = ROW_MAP.get(c_base, 1)

                                    if (cur_row == 0 and cand_row == 2) or (
                                        cur_row == 2 and cand_row == 0
                                    ):
                                        p_row_jump = float(row_jump_penalty)
                                        if self.verbose:
                                            step_logs.append(
                                                f"  -> Row Jump Penalty (+{row_jump_penalty})"
                                            )

                                    # Scissors (Bigram)
                                    if (
                                        abs(c_finger - cand_finger) == 1
                                        and c_finger != 4
                                        and cand_finger != 4
                                    ):
                                        if (cur_row == 0 and cand_row == 2) or (
                                            cur_row == 2 and cand_row == 0
                                        ):
                                            w_dyn = max(
                                                self.finger_dynamic_weights[c_finger],
                                                self.finger_dynamic_weights[
                                                    cand_finger
                                                ],
                                            )
                                            p_scissor = float(scissor_penalty) * w_dyn
                                            c_idx = (
                                                c_finger
                                                if c_hand == 1
                                                else c_finger + 5
                                            )
                                            c_finger_pos[c_idx] = initial_finger_pos[
                                                c_idx
                                            ]
                                            if self.verbose:
                                                step_logs.append(
                                                    f"  -> Scissors Penalty (+{p_scissor})"
                                                )

                                    # Rolls
                                    if c_finger != 4 and cand_finger != 4:
                                        f_norm_from = c_finger
                                        f_norm_to = cand_finger

                                        if f_norm_to - f_norm_from == 1:
                                            p_roll = float(inward_roll_bonus)
                                            if self.verbose:
                                                step_logs.append(
                                                    f"  -> Inward Roll Bonus (+{inward_roll_bonus})"
                                                )
                                        elif f_norm_from - f_norm_to == 1:
                                            p_roll = float(outward_roll_bonus)
                                            if self.verbose:
                                                step_logs.append(
                                                    f"  -> Outward Roll Bonus (+{outward_roll_bonus})"
                                                )

                                    # Tenodesis Effect Bonus
                                    if cand_hand == c_hand:
                                        if cur_row in [0, 1] and cand_row in [0, 1]:
                                            p_tenodesis += 3.0
                                            is_roll_in = False
                                            if cand_hand == 1:
                                                if cand_finger > c_finger:
                                                    is_roll_in = True
                                            else:
                                                if cand_finger < c_finger:
                                                    is_roll_in = True
                                            if is_roll_in:
                                                p_tenodesis += 2.0
                                            if self.verbose:
                                                step_logs.append(
                                                    f"  -> Tenodesis Bonus (-{p_tenodesis})"
                                                )

                                # Inertia Penalty (Redirect Replacement)
                                if (
                                    c_hand == cand_hand
                                    and cand_base_key in self.key_coords
                                ):
                                    cx, cy = self.key_coords[cand_base_key]
                                    if len(node.hand_history[cand_hand]) == 2:
                                        p0x, p0y = node.hand_history[cand_hand][0]
                                        p1x, p1y = node.hand_history[cand_hand][1]
                                        v1x, v1y = (p1x - p0x) * 1.5, p1y - p0y
                                        v2x, v2y = (cx - p1x) * 1.5, cy - p1y

                                        mag1 = math.sqrt(v1x**2 + v1y**2)
                                        mag2 = math.sqrt(v2x**2 + v2y**2)
                                        if mag1 > 0.0 and mag2 > 0.0:
                                            cos_theta = (v1x * v2x + v1y * v2y) / (
                                                mag1 * mag2
                                            )
                                            if cos_theta < 0.0:
                                                p_redirect = (
                                                    5.0
                                                    * (mag1 * mag2)
                                                    * ((-cos_theta) ** 2.0)
                                                )
                                                if self.verbose:
                                                    step_logs.append(
                                                        f"  -> Inertia Penalty (+{p_redirect:.2f})"
                                                    )

                                if c_hand != cand_hand:
                                    p_sfb *= 0.75
                                    p_scissor *= 0.75
                                    p_row_jump *= 0.75
                                    p_redirect *= 0.75
                                    p_roll *= 0.75
                                    p_sfs *= 0.75
                                    p_lss *= 0.75
                                    p_fss *= 0.75
                                    p_tendon *= 0.75
                                    if self.verbose:
                                        step_logs.append(
                                            "  -> Cross-Hand Modifier Applied (Penalty/Bonus * 0.75)"
                                        )

                            c_sfb += p_sfb
                            c_scissor += p_scissor
                            c_row_jump += p_row_jump
                            c_redirect += p_redirect
                            c_roll += p_roll
                            c_hand_split += p_hand_split
                            c_sfs = p_sfs
                            c_lss = p_lss
                            c_fss = p_fss
                            c_tenodesis = p_tenodesis
                            c_tendon = p_tendon

                            main_dynamic_final = (
                                move_cost
                                + p_sfb
                                + p_scissor
                                + p_row_jump
                                + p_redirect
                                + p_hand_split
                                + p_sfs
                                + p_lss
                                + p_fss
                                + p_tendon
                                - p_roll
                                - p_tenodesis
                            )
                            main_cost = main_static + main_dynamic_final

                        main_cost = max(0.0, main_cost)
                        step_cost += main_cost

                        c_same_hand_count = state.same_hand_count
                        if c_hand == cand_hand:
                            c_same_hand_count = min(5, c_same_hand_count + 1)
                        else:
                            c_same_hand_count = 1

                        # 反対側の手が2回打鍵された場合のホーム戻り処理
                        c_return = 0.0
                        if c_hand == cand_hand and c_same_hand_count == 2:
                            opp_hand = 1 - cand_hand
                            for f in range(5):
                                opp_idx = f if opp_hand == 1 else f + 5
                                current_key = c_finger_pos[opp_idx]
                                home_key = initial_finger_pos[opp_idx]
                                if current_key and home_key and current_key != home_key:
                                    _, return_move_cost = self._get_cost(
                                        current_key, home_key, opp_hand
                                    )
                                    c_return += return_move_cost
                                c_finger_pos[opp_idx] = home_key

                        c_move += c_return
                        step_cost += c_return

                        step_cost += c_base_stroke

                        fatigue_multiplier = 1.0 + (c_same_hand_count - 1) * 0.03
                        c_fatigue += step_cost * (fatigue_multiplier - 1.0)
                        step_cost *= fatigue_multiplier

                        step_count += match_len

                        (
                            n_c0,
                            n_c1,
                            n_c2,
                            n_c3,
                            n_c4,
                            n_c5,
                            n_c6,
                            n_c7,
                            n_c8,
                            n_c9,
                            n_c10,
                            n_c11,
                            n_c12,
                            n_c13,
                            n_c14,
                            n_c15,
                            n_c16,
                        ) = node.comps

                        new_comps = (
                            n_c0 + c_static,
                            n_c1 + c_move,
                            n_c2 + c_sfb,
                            n_c3 + c_scissor,
                            n_c4 + c_row_jump,
                            n_c5 + c_roll,
                            n_c6 + c_redirect,
                            n_c7 + c_shift,
                            n_c8 + c_doubletap,
                            n_c9 + c_fatigue,
                            n_c10 + c_hand_split,
                            n_c11 + c_sfs,
                            n_c12 + c_lss,
                            n_c13 + c_fss,
                            n_c14 + c_tenodesis,
                            n_c15 + c_tendon,
                            n_c16 + c_base_stroke,
                        )

                        c_finger_pos[cand_idx] = cand_base_key

                        next_last_last_finger = (
                            c_finger if cand_hand == c_hand else None
                        )

                        new_state = DpState(
                            tuple(c_finger_pos),
                            cand_hand,
                            cand_finger,
                            next_last_last_finger,
                            cand_base_key,
                            c_same_hand_count,
                        )
                        target_i = i + match_len
                        new_cost = node.cost + step_cost

                        # history の更新 (直近3文字分)
                        new_history = (
                            (cand_hand, cand_finger, cand_base_key),
                        ) + node.history
                        new_history = new_history[:3]

                        # COM & hand_history 更新
                        new_coms = dict(node.coms)
                        if cand_hand in new_coms and cand_base_key in self.key_coords:
                            old_com_x, old_com_y = new_coms[cand_hand]
                            alpha_com = 0.35
                            cx, cy = self.key_coords[cand_base_key]
                            new_coms[cand_hand] = (
                                alpha_com * cx + (1 - alpha_com) * old_com_x,
                                alpha_com * cy + (1 - alpha_com) * old_com_y,
                            )

                        new_hand_history = {
                            0: list(node.hand_history[0]),
                            1: list(node.hand_history[1]),
                        }
                        if cand_base_key in self.key_coords:
                            cx, cy = self.key_coords[cand_base_key]
                            new_hand_history[cand_hand].append((cx, cy))
                            if len(new_hand_history[cand_hand]) > 2:
                                new_hand_history[cand_hand].pop(0)

                        if c_same_hand_count == 2 and c_hand == cand_hand:
                            inactive_hand = 1 if cand_hand == 0 else 0
                            new_coms[inactive_hand] = (
                                (1.5, 1.0) if inactive_hand == 1 else (7.5, 1.0)
                            )
                            new_hand_history[inactive_hand] = []

                        if (
                            new_state not in dp[target_i]
                            or dp[target_i][new_state].cost > new_cost
                        ):
                            dp[target_i][new_state] = PathNode(
                                new_cost,
                                node.count + step_count,
                                new_comps,
                                step_logs if self.verbose else [],
                                node,
                            )
            del dp[i]

        states = dp[len(processed_text)]
        if not states:
            return 0, -20, 0, ()

        best_node = min(states.values(), key=lambda n: n.cost)
        return (
            best_node.cost,
            (best_node.cost / best_node.count if best_node.count > 0 else 0),
            best_node.count,
            best_node.comps,
        )


def evaluate_layout(
    name: str,
    layout: str,
    text_to_check: str,
    cost_mode: str = "default",
    board_mode: str = "row_staggered",
    norm: float = 1.0,
    silent: bool = False,
    use_c_for_k: bool = False,
) -> float:
    if use_c_for_k:
        text_to_check = text_to_check.replace("k", "c").replace("K", "C")

    # "default" か "calculated" を指定して初期化
    calculator = TypingCostCalculator(
        layout, verbose=False, cost_mode=cost_mode, board_mode=board_mode
    )
    _, normalized_cost, count, comps = calculator.calculate(text_to_check)
    result = (normalized_cost / norm) * 100 if norm != 1.0 else normalized_cost

    if not silent:
        print(f"[{cost_mode.upper():<10}] Layout: {name:<12} : Score: {result:.4f}")

    return result, comps


def calc(japanese):
    # ⚠️ This path needs to be changed depending on the execution environment.
    cost_mode = "default"
    cost_mode = "calculated"

    max_chars = 100000  # 測定するテキストの文字数の最大値

    current_dir = os.path.dirname(os.path.abspath(__file__))
    if japanese:
        file_path = os.path.join(current_dir, "..", "data", "jap-n.txt")
    else:
        file_path = os.path.join(current_dir, "..", "data", "English_sample.txt")

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

        # 評価する形状モードのリスト
        if cost_mode == "calculated":
            # board_modes = ["row_staggered", "ortholinear", "column_staggered"]
            board_modes = ["row_staggered"]
        else:
            board_modes = [
                "row_staggered"
            ]  # default モードでは形状モードは無関係（固定マトリクス）

        for b_mode in board_modes:
            print(f"\n=== Board Mode: {b_mode.upper()} ===")

            # 1. 基準となるQWERTYのスコアを計算
            qwerty_layout = "qwertyuiopasdfghjkl;zxcvbnm,./"
            qwerty_score_orig, _ = evaluate_layout(
                "QWERTY",
                qwerty_layout,
                text_to_check,
                cost_mode,
                board_mode=b_mode,
                norm=1.0,
                silent=True,
            )
            if text_alt:
                qwerty_score_alt, _ = evaluate_layout(
                    "QWERTY",
                    qwerty_layout,
                    text_alt,
                    cost_mode,
                    board_mode=b_mode,
                    norm=1.0,
                    silent=True,
                )
                qwerty_norm = min(qwerty_score_orig, qwerty_score_alt)
            else:
                qwerty_norm = qwerty_score_orig

            # 2. 評価する共通レイアウトのリスト
            layouts_to_test = [
                ("QWERTY", "qwertyuiopasdfghjkl;zxcvbnm,./"),
                ("Arensito", "ql,p/;fudkarenbgsitozw.hjvcymx"),
                # ("FMIX15", "qwldkjfuy;asrtghneiozxcvbpm,./", {"use_c_for_k": True}),
                # ("FMIX16", "qwldkjfuy;arstghneiozxcvbpm,./", {"use_c_for_k": True}),
                # ("FMIX16_2", "qwldjkfuy;arstghneiozxcvbpm,./"),
                ("MTGAP", "ypoujkdlcwinea,mhtsrqz/.:bfgvx", {"use_c_for_k": True}),
                ("FMIX12f", "qwfrkylup;asdtghneiozxcvbjm,./", {"use_c_for_k": True}),
                ("FMIX12x", "qwerfylupjasdtghneiozxcvbkm,.;", {"use_c_for_k": True}),
                # ("FMIX12", "qwlrkyfup;asdtghneiozxcvbjm,./"),
                #            ("FMIX13", 'qwrlkyfup;asdtghneiozxcvbjm,./', {"use_c_for_k": True}),
                # ("Colemak", "qwfpgjluy;arstdhneiozxcvbkm,./", {"use_c_for_k": True}),
                #            ("FMIX14", 'qwldkyfup;asrtghneiozxcvbjm,./'),
                #            ("FMIX14 fuj", 'qwldkyfuj;asrtghneiozxcvbpm,./'),
                #            ("FMIX14 vbk", 'qwldjyfup;asrtghneiozxcvbkm,./'),
                # ("Dvorak", "/,.pyfgcrlaoeuidhtns;qjkxbmwvz", {"use_c_for_k": True}),
                # ("aret", "qcufkzlpy;aretdmnoisjwxgbvh,./"),
                ("Wakasagi", "qprdcbkuyxatnswmheio/,lgjfv;z."),
                ("Wakasagi2", "qprdcbkuyxatnswmheioz;lgjfv,./"),
                ("Stream1", "qwrd;bkuyxatnsgmheiozplcjfv,./"),
                ("Stream-m ", "qwrd;jluyxasntgvheiozpmcbkf,./"),
                ("Stream-mf", "qwrdfjluyxasn[t,-]gnheiozpmcbkv,.;"),
                # ("Stream-m;j", "qwrd;jluyxasntgvheiozpmcbkf,./"),
                # ("Stream-m;jpr", "qprd;jluyxasntgvheiozwmcbkf,./"),
                # ("Stream2", "qwrd;jluyxasntgvheiozpfcbkm,./", {"use_c_for_k": False}),
                # ("StreamXX", "qdrw;jluyxasntgvheiozcbpfkm,./", {"use_c_for_k": False}),
                # ("Stream2x", "qwrd;jluyxasntgvheiozpmcbkf,./", {"use_c_for_k": False}),
                # ("Stream3", "qwrd;jluyxasntgvhieozpfcbkm,./", {"use_c_for_k": False}),
                # ("Stream4", "qwrd;bluyxasntgmheiozpfcjkv,./", {"use_c_for_k": False}),
                # ("Stream5", "qwrd;bluyxasntgvheiozpfcjkm,./", {"use_c_for_k": False}),
                # ("Boo", ",.ucvqfdlyaoesgbntri;x/wzphmkj"),
                #            ("Stronk", 'fdlbvjgou,strnkymaeizqxhpwc/;.'),
                #            ("aptv3", 'wgdfbqluoyrsthkjneaixcmpvz,.;/'),
                # ("kotone", "qwdrfjluyxnstegceaiozpmhbkv,./"),
                # ("kotone2", "qwrdfjluyxnstegceaiozpmhbkv,./"),
                #            ("kotone3", 'qwrdfjluyxsntegceaiozpmhbkv,./'),
                #            ("kotone4", 'qwrdfjluyxstnegceaiozpmhbkv,./'),
                ("kotone5", "qwrdfjluyxnstagcaieozpmhbkv,./"),
                ("kotone6", "qwrdfjluyxnstagcaeiozpmhbkv,./"),
                ("kotone7", "qwrdbjluyxnstagcaeiozpmhfkv,./"),
            ]

            # 3. 日本語モードの場合は、日本語特化配列を追加
            if japanese:
                layouts_to_test.extend(
                    [
                        (
                            "streamj",
                            "qwrd;jluyxasntg[nn]heiozpfcbkm,./",
                            {"use_c_for_k": False},
                        ),
                        (
                            "streamj-c",
                            "qwrd;jluyxasntg[nn]heiozpfcbkm,./",
                            {"use_c_for_k": True},
                        ),
                        (
                            "stream-mj",
                            "qwrd;j[yu]u[yo]xnsktg[nn]aeiozpmhb-[ya],./",
                            {"use_c_for_k": False},
                        ),
                        (
                            "minato-ei",
                            "qwrdf;[yu]u[yo]xnsktg[nn,ann]aeiozpmhb[-,a-][ya],./",
                        ),
                        (
                            "minato",
                            "qwrdf;[yu]u[yo]xnsktg[nn,ann]aieozpmhb[-,a-][ya],./",
                        ),
                        (
                            "stream-mjfks",
                            "qwrdf;[yu]u[yo]xksntg[nn]aeiozpmhb-[ya],./",
                            {"use_c_for_k": False},
                        ),
                        ("FMIX13R", "qwdrfylup;ask[t,-]ghneiozxcvbjm,./"),
                        # ("kotone2j", "qwrdfj[yu]u[yo]xnstkg[nn]eaiozpmhb-[ya],./"),
                        (
                            "kotone5jie",
                            "qwrdfj[yu]u[yo]xnstkg[nn,ann]aieozpmhb[-,a-][ya],./",
                        ),
                        (
                            "kotone6jei",
                            "qwrdfj[yu]u[yo]xnstkg[nn,ann]aeiozpmhb[-,a-][ya],./",
                        ),
                    ]
                )

            # 4. ループで一括スコアリング
            for item in layouts_to_test:
                name = item[0]
                layout = item[1]
                opts = item[2] if len(item) > 2 else {}
                use_c = opts.get("use_c_for_k", False) if japanese else False

                score_orig, comps_orig = evaluate_layout(
                    name,
                    layout,
                    text_to_check,
                    cost_mode,
                    board_mode=b_mode,
                    norm=qwerty_norm,
                    silent=True,
                    use_c_for_k=use_c,
                )
                if text_alt:
                    score_alt, comps_alt = evaluate_layout(
                        name,
                        layout,
                        text_alt,
                        cost_mode,
                        board_mode=b_mode,
                        norm=qwerty_norm,
                        silent=True,
                        use_c_for_k=use_c,
                    )
                    best_score = min(score_orig, score_alt)
                    best_comps = comps_orig if score_orig <= score_alt else comps_alt
                    label = "Orig" if score_orig <= score_alt else "Alt(zya)"
                    if use_c:
                        label += ", k->c"
                else:
                    best_score = score_orig
                    best_comps = comps_orig
                    label = "Orig, k->c" if use_c else "Orig"

                print(
                    f"[{cost_mode.upper():<10}] Layout: {name:<12} : Score: {best_score:.4f} ({label})"
                )

                # Format the components breakdown
                if best_comps:
                    comp_names = [
                        "Static",
                        "Move",
                        "SFB",
                        "Scissor",
                        "RowJump",
                        "Roll(Bonus)",
                        "Redirect",
                        "Shift",
                        "DoubleTap",
                        "Fatigue",
                        "HandSplit",
                        "SFS",
                        "LSS",
                        "FSS",
                        "Tenodesis(Bonus)",
                        "Tendon",
                        "BaseStroke",
                    ]
                    # We negate roll/tenodesis/shortcut bonus for display to show it as a negative cost (bonus)
                    display_comps = list(best_comps)
                    display_comps[5] = -display_comps[5]
                    display_comps[14] = -display_comps[14]

                    if name == "QWERTY" and (not text_alt or label.startswith("Orig")):
                        # Save qwerty_total_comp globally (a bit hacky but it works since QWERTY is first)
                        global qwerty_total_comp
                        qwerty_total_comp = sum(display_comps)

                    if "qwerty_total_comp" in globals() and qwerty_total_comp > 0:
                        comp_strs = []
                        for c_name, c_val in zip(comp_names, display_comps):
                            if c_val != 0.0:
                                pct = (c_val) / qwerty_total_comp * 100
                                comp_strs.append(f"{c_name}:{pct:.1f}pt")
                        print("    Breakdown -> " + " | ".join(comp_strs))

        print("-" * 50)

    except FileNotFoundError:
        print(
            f"\nError: File '{file_path}' not found. Please check the path.",
            file=sys.stderr,
        )
    except Exception as e:
        print(f"\nAn error occurred: {e}", file=sys.stderr)


if __name__ == "__main__":
    calc(False)
    calc(True)
