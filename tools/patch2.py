import sys
import re

def main():
    with open('c:/src/ahk/tools/eval_layout.py', 'r', encoding='utf-8') as f:
        content = f.read()

    # Flexion Limit Replace
    old_flexion = '''                            # 指の屈曲限界 (Bottom Row Flexion Limit)
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
                            c_move += move_cost * flexion_multiplier'''

    new_flexion = '''                            # 指の屈曲限界 (Bottom Row Flexion Limit)
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
                                    c_posture += 8.0
                                    if self.verbose:
                                        step_logs.append(
                                            "  -> Bottom Row Flexion Limit Penalty (+8.0)"
                                        )

                            c_static += main_static
                            last_same_finger_base = c_finger_pos[cand_idx]
                            _, move_cost = (
                                self._get_cost(
                                    last_same_finger_base, cand_base_key, cand_hand
                                )
                                if last_same_finger_base
                                else (0.0, 0.0)
                            )
                            c_move += move_cost'''
    
    content = content.replace(old_flexion, new_flexion)

    # Double Tap
    old_doubletap = '''                        if c_base == cand_base_key:
                            main_cost = main_static * 0.2
                            c_doubletap += main_cost
                            if self.verbose:
                                step_logs.append(
                                    f"  -> Double Tap Discount (stroke cost: {main_cost:.2f})"
                                )
                        else:'''
    new_doubletap = '''                        if c_base == cand_base_key:
                            main_cost = main_static
                            c_static += main_static
                            if self.verbose:
                                step_logs.append(f"  -> Double Tap (Move=0)")
                        else:'''
    content = content.replace(old_doubletap, new_doubletap)

    # EMA Speed
    old_ema = '''                        if cand_hand in new_coms and cand_base_key in self.key_coords:
                            old_com_x, old_com_y = new_coms[cand_hand]
                            alpha_com = 0.35
                            cx, cy = self.key_coords[cand_base_key]'''
    new_ema = '''                        if cand_hand in new_coms and cand_base_key in self.key_coords:
                            old_com_x, old_com_y = new_coms[cand_hand]
                            alpha_com = 0.35
                            if c_hand == cand_hand and c_base and c_base in self.key_coords:
                                c1 = self.key_coords[c_base]
                                c2 = self.key_coords[cand_base_key]
                                dist = math.sqrt(((c1[0]-c2[0])*1.5)**2 + (c1[1]-c2[1])**2)
                                if dist < 1.5:
                                    alpha_com = 0.55
                                else:
                                    alpha_com = 0.25
                            cx, cy = self.key_coords[cand_base_key]'''
    content = content.replace(old_ema, new_ema)
    
    # Roll Bonus
    old_roll = '''                                    # Rolls
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
                                                )'''
    new_roll = '''                                    # Rolls
                                    if c_finger != 4 and cand_finger != 4:
                                        f_norm_from = c_finger
                                        f_norm_to = cand_finger
                                        
                                        roll_dist = 0.0
                                        if c_base and c_base in self.key_coords and cand_base_key in self.key_coords:
                                            c1 = self.key_coords[c_base]
                                            c2 = self.key_coords[cand_base_key]
                                            roll_dist = math.sqrt(((c1[0]-c2[0])*1.5)**2 + (c1[1]-c2[1])**2)

                                        if f_norm_to - f_norm_from == 1:
                                            p_roll = max(0.0, 10.0 - 2.0 * roll_dist)
                                            if self.verbose:
                                                step_logs.append(f"  -> Inward Roll Bonus (-{p_roll:.2f})")
                                        elif f_norm_from - f_norm_to == 1:
                                            p_roll = max(0.0, 5.0 - 2.0 * roll_dist)
                                            if self.verbose:
                                                step_logs.append(f"  -> Outward Roll Bonus (-{p_roll:.2f})")'''
    content = content.replace(old_roll, new_roll)

    # Fatigue
    old_fatigue = '''                        fatigue_multiplier = 1.0 + (c_same_hand_count - 1) * 0.03
                        c_fatigue += step_cost * (fatigue_multiplier - 1.0)
                        step_cost *= fatigue_multiplier'''
    new_fatigue = '''                        fatigue_arr = [1.0, 1.02, 1.05, 1.10, 1.18]
                        idx = min(4, c_same_hand_count - 1)
                        fatigue_multiplier = fatigue_arr[idx]
                        c_fatigue += step_cost * (fatigue_multiplier - 1.0)
                        step_cost *= fatigue_multiplier'''
    content = content.replace(old_fatigue, new_fatigue)

    # Redirect
    old_redirect = '''                                            if cos_theta < 0.0:
                                                p_redirect = (
                                                    5.0
                                                    * (mag1 * mag2)
                                                    * ((-cos_theta) ** 2.0)
                                                )'''
    new_redirect = '''                                            w_dyn = self.finger_dynamic_weights.get(cand_finger, 1.0)
                                            dist_redirect = mag1 + mag2
                                            p_redirect = (dist_redirect**2) * (1.0 - cos_theta) * w_dyn * 5.0'''
    content = content.replace(old_redirect, new_redirect)

    # Return Cost Probabilistic
    old_return = '''                        # 反対側の手が2回打鍵された場合のホーム戻り処理
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
                                c_finger_pos[opp_idx] = home_key'''
    new_return = '''                        # 反対側の手が打鍵された場合のホーム戻り処理（確率的）
                        c_return = 0.0
                        if c_hand == cand_hand and c_same_hand_count > 1:
                            prob = min(1.0, 0.3 * (c_same_hand_count - 1))
                            opp_hand = 1 - cand_hand
                            for f in range(5):
                                opp_idx = f if opp_hand == 1 else f + 5
                                current_key = c_finger_pos[opp_idx]
                                home_key = initial_finger_pos[opp_idx]
                                if current_key and home_key and current_key != home_key:
                                    _, return_move_cost = self._get_cost(
                                        current_key, home_key, opp_hand
                                    )
                                    c_return += return_move_cost * prob
                                # We don't forcefully reset the pos to keep probabilistic nature, or we can just reset if prob == 1.0
                                if prob >= 1.0:
                                    c_finger_pos[opp_idx] = home_key'''
    content = content.replace(old_return, new_return)
    
    # 5 layer accumulations
    old_acc = '''                            c_sfb += p_sfb
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
                            )'''
    new_acc = '''                            c_posture += p_hand_split + p_tendon
                            c_sequence += p_sfb + p_scissor + p_row_jump + p_redirect + p_sfs + p_lss + p_fss - p_roll - p_tenodesis
                            main_dynamic_final = move_cost + p_hand_split + p_tendon + p_sfb + p_scissor + p_row_jump + p_redirect + p_sfs + p_lss + p_fss - p_roll - p_tenodesis'''
    content = content.replace(old_acc, new_acc)
    
    # Shift updates
    content = content.replace('''                            c_shift += max(0, t_cost)''', '''                            c_sequence += max(0, t_cost)''')
    content = content.replace('''                            c_shift += max(0, s_cost)''', '''                            c_sequence += max(0, s_cost)''')
    content = content.replace('''                            c_shift += s_cost''', '''                            c_sequence += s_cost''')

    with open('c:/src/ahk/tools/eval_layout.py', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    main()
