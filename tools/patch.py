import sys
import re

def main():
    with open('c:/src/ahk/tools/eval_layout.py', 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update initial_comps and unpacking
    content = content.replace(
        'initial_comps = (0.0,) * 17',
        'initial_comps = (0.0,) * 5'
    )
    content = content.replace(
        '''                        (
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
                        )''',
        '''                        (n_c_static, n_c_move, n_c_posture, n_c_sequence, n_c_fatigue) = node.comps
                        new_comps = (
                            n_c_static + c_static,
                            n_c_move + c_move,
                            n_c_posture + c_posture,
                            n_c_sequence + c_sequence,
                            n_c_fatigue + c_fatigue,
                        )'''
    )

    # 2. Update logging in calc()
    content = content.replace(
        '''                    comp_names = [
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
                    display_comps[14] = -display_comps[14]''',
        '''                    comp_names = [
                        "Static",
                        "Move",
                        "Posture",
                        "Sequence",
                        "Fatigue"
                    ]
                    display_comps = list(best_comps)'''
    )

    # 3. Modify generate_calculated_matrix
    old_generate = '''                # ==========================================
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
                        dynamic_cost = fitts_id * strength_w * base_cost_multiplier'''

    new_generate = '''                # ==========================================
                # A. 静的コスト (Static Cost)
                # ==========================================
                target_row = int(y_grid) if int(y_grid) in [0, 1, 2] else 1
                strength_w = finger_weights[target_hand][target_finger]
                static_cost = strength_w * base_cost_multiplier

                # ==========================================
                # B. 物理移動コスト (C_move)
                # ==========================================
                if from_key == to_key:
                    dynamic_cost = 0.0
                else:
                    if target_finger == 4:
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

                        row_penalty = row_penalties_by_finger.get(
                            target_finger, row_penalties_by_finger[3]
                        ).get(target_row, 1.0)
                        
                        lat_penalty = 1.0
                        if target_finger == 3 and x_grid in [4, 5]:
                            lat_penalty = 1.50 if target_row == 0 else (1.20 if target_row == 1 else 1.40)
                        elif target_finger == 0 and (x_grid < 0 or x_grid > 9):
                            lat_penalty = 1.40
                            
                        p_row_lat = row_penalty * lat_penalty
                        k = 0.5
                        w_eff = 1.0 / (1.0 + k * d)
                        fitts_id = math.log2(1.0 + (d * p_row_lat) / w_eff)
                        dynamic_cost = fitts_id * strength_w * base_cost_multiplier'''
    
    content = content.replace(old_generate, new_generate)

    # 4. Modify calculate initialization variables
    content = content.replace(
        '''                        c_static = c_move = c_sfb = c_scissor = c_row_jump = c_roll = (
                            c_redirect
                        ) = c_shift = c_doubletap = c_fatigue = c_hand_split = 0.0
                        c_sfs = c_lss = c_fss = c_tenodesis = c_base_stroke = 0.0''',
        '''                        c_static = c_move = c_posture = c_sequence = c_fatigue = 0.0
                        c_base_stroke = 0.0'''
    )

    # We need to do regex replacement for the big block of logic. Since the big block is complex, I will write a new script just to replace it using a Python function.

    with open('c:/src/ahk/tools/eval_layout.py', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    main()
