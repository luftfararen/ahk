import sys
import re

def main():
    with open('c:/src/ahk/tools/eval_layout.py', 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add dataclass and get_profile before TypingCostCalculator
    insert_str = '''from dataclasses import dataclass, field
from typing import Dict, List, Tuple

@dataclass
class CalibrationProfile:
    finger_dynamic_weights: Dict[int, float] = field(default_factory=lambda: {0: 1.6, 1: 2.0, 2: 1.2, 3: 1.0, 4: 1.0})
    tendon_threshold: float = 0.5
    flexion_penalty: float = 8.0
    hand_split_multiplier: float = 15.0
    sfb_base_penalty: float = 30.0
    sfb_dist_multiplier: float = 50.0
    scissor_penalty: float = 10.0
    row_jump_penalty: float = 15.0
    redirect_multiplier: float = 5.0
    roll_inward_base: float = 10.0
    roll_outward_base: float = 5.0
    roll_dist_decay: float = 2.0
    fatigue_curve: List[float] = field(default_factory=lambda: [1.0, 1.02, 1.05, 1.10, 1.18])
    ema_alpha_fast: float = 0.55
    ema_alpha_slow: float = 0.25
    ema_dist_threshold: float = 1.5

def get_profile(name: str) -> CalibrationProfile:
    name = name.lower()
    profile = CalibrationProfile()
    if name == "gaming":
        pass # Add overrides in future
    return profile

'''
    content = content.replace('class TypingCostCalculator:', insert_str + 'class TypingCostCalculator:')

    # 2. Update __init__
    old_init = '''    def __init__(
        self,
        layout: str,
        verbose: bool = False,
        cost_mode: str = "default",
        board_mode: str = "row_staggered",
        angle_of_approach: float = 15.0,
    ):'''
    new_init = '''    def __init__(
        self,
        layout: str,
        verbose: bool = False,
        cost_mode: str = "default",
        board_mode: str = "row_staggered",
        angle_of_approach: float = 15.0,
        profile_name: str = "biomechanical",
    ):
        self.profile = get_profile(profile_name)'''
    content = content.replace(old_init, new_init)

    # 3. Remove hardcoded finger_dynamic_weights etc from __init__
    remove_block = '''        # 指の動的コスト（独立性の低さ）ペナルティ係数
        self.finger_dynamic_weights = {
            0: 1.6,  # 小指
            1: 2.0,  # 薬指
            2: 1.2,  # 中指
            3: 1.0,  # 人差し指
            4: 1.0,  # 親指
        }'''
    content = content.replace(remove_block, '')
    content = content.replace('self.tendon_threshold = 0.5\n', '')

    # 4. Replace usages
    content = content.replace('self.finger_dynamic_weights', 'self.profile.finger_dynamic_weights')
    content = content.replace('self.tendon_threshold', 'self.profile.tendon_threshold')

    # 5. Update calculate signature
    old_calc_sig = '''    def calculate(
        self,
        text: str,
        sfb_base_penalty: int = 80,
        scissor_penalty: int = 10,
        row_jump_penalty: int = 15,
        inward_roll_bonus: int = 10,
        outward_roll_bonus: int = 5,
        alternation_bonus: int = 0,
    ) -> Tuple[float, float, int]:'''
    new_calc_sig = '''    def calculate(
        self,
        text: str,
    ) -> Tuple[float, float, int]:'''
    content = content.replace(old_calc_sig, new_calc_sig)

    # 6. Replace usages of hardcoded values inside calculate
    content = content.replace('c_posture += 8.0', 'c_posture += self.profile.flexion_penalty')
    content = content.replace('Bottom Row Flexion Limit Penalty (+8.0)', 'Bottom Row Flexion Limit Penalty (+{self.profile.flexion_penalty})')

    content = content.replace('15.0 * w_dyn', 'self.profile.hand_split_multiplier * w_dyn')
    content = content.replace('* 15.0\n                                                    * w_dyn', '* self.profile.hand_split_multiplier\n                                                    * w_dyn')
    
    content = content.replace('30.0 + 50.0 * (dist_sfs**1.5)', 'self.profile.sfb_base_penalty + self.profile.sfb_dist_multiplier * (dist_sfs**1.5)')
    content = content.replace('30.0 + 50.0 * (dist_sfb**1.5)', 'self.profile.sfb_base_penalty + self.profile.sfb_dist_multiplier * (dist_sfb**1.5)')
    
    content = content.replace('float(scissor_penalty)', 'self.profile.scissor_penalty')
    content = content.replace('float(row_jump_penalty)', 'self.profile.row_jump_penalty')

    # 7. Roll
    old_roll_p1 = '''p_roll = max(0.0, 10.0 - 2.0 * roll_dist)'''
    new_roll_p1 = '''p_roll = max(0.0, self.profile.roll_inward_base - self.profile.roll_dist_decay * roll_dist)'''
    content = content.replace(old_roll_p1, new_roll_p1)
    
    old_roll_p2 = '''p_roll = max(0.0, 5.0 - 2.0 * roll_dist)'''
    new_roll_p2 = '''p_roll = max(0.0, self.profile.roll_outward_base - self.profile.roll_dist_decay * roll_dist)'''
    content = content.replace(old_roll_p2, new_roll_p2)

    content = content.replace('float(inward_roll_bonus)', 'self.profile.roll_inward_base')
    content = content.replace('float(outward_roll_bonus)', 'self.profile.roll_outward_base')
    
    content = content.replace('{inward_roll_bonus}', '{self.profile.roll_inward_base}')
    content = content.replace('{outward_roll_bonus}', '{self.profile.roll_outward_base}')
    content = content.replace('{row_jump_penalty}', '{self.profile.row_jump_penalty}')

    # 8. Redirect
    content = content.replace('* 5.0', '* self.profile.redirect_multiplier')

    # 9. EMA Alpha
    old_ema_logic = '''                            alpha_com = 0.35
                            if c_hand == cand_hand and c_base and c_base in self.key_coords:
                                c1 = self.key_coords[c_base]
                                c2 = self.key_coords[cand_base_key]
                                dist = math.sqrt(((c1[0]-c2[0])*1.5)**2 + (c1[1]-c2[1])**2)
                                if dist < 1.5:
                                    alpha_com = 0.55
                                else:
                                    alpha_com = 0.25'''
    new_ema_logic = '''                            alpha_com = 0.35
                            if c_hand == cand_hand and c_base and c_base in self.key_coords:
                                c1 = self.key_coords[c_base]
                                c2 = self.key_coords[cand_base_key]
                                dist = math.sqrt(((c1[0]-c2[0])*1.5)**2 + (c1[1]-c2[1])**2)
                                if dist < self.profile.ema_dist_threshold:
                                    alpha_com = self.profile.ema_alpha_fast
                                else:
                                    alpha_com = self.profile.ema_alpha_slow'''
    content = content.replace(old_ema_logic, new_ema_logic)

    # 10. Fatigue
    content = content.replace('fatigue_arr = [1.0, 1.02, 1.05, 1.10, 1.18]', 'fatigue_arr = self.profile.fatigue_curve')

    with open('c:/src/ahk/tools/eval_layout.py', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    main()
