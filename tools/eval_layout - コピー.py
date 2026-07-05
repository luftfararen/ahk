import sys
import re
import collections
# basic characters
base   = 'qwertyuiopasdfghjkl;zxcvbnm,./'

# 3 rows, 18 columns 
qwerty   = ["tab",   "q","w","e","r","t","y","u","i","o","p","bs",
            "caps",  "a","s","d","f","g","h","j","k","l",";","enter",
            "lshift","z","x","c","v","b","n","m",",",".","/","rshift"] 

# 3 rows, 18 columns
# 0: right hand 1: left hand
left = [1,1,1,1,1,1,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,0,0,0,0]

# 3 rows, 18 columns 
# 0:  pinky finger 1: ring finger  2: middle finger 3: index finger 4: thumb
fingers = [0,0,1,2,3,3,3,3,2,1,0,0,
           0,0,1,2,3,3,3,3,2,1,0,0,
           0,0,1,2,3,3,3,3,2,1,0,0,]


# Moving cost
c = {}
# Typed by Left finger (q, w, e, r, t, a, s, d, f, g, z, x, c, v, b,tab,caps,lshift)
# Typed by Right finger (y, u, i, o, p, h, j, k, l, ;, n, m, ,',' ., /m,bs,enter,rshift )

c['q'] = [40,20,25,15,20,30,
          50,50,40,25,15,30,
          90,70,50,50,30,40] 
c['p'] = [25,30,15,25,20,40,
          35,15,25,40,50,45,
          40,50,50,50,70,90]
c['w'] = [30,50,15,15,10,25,
          40,50,40,25,10,25,
          60,70,60,50,20,40]
c['o'] = [30,25,15,20,50,20,
          25,10,25,40,50,40,
          40,50,50,60,70,85]
c['e'] = [40,30,20,10,20,30,
          40,35,40,20,10,25,
          60,60,40,40,20,40]
c['i'] = [30,25,10,20,40,40,
          20,10,20,40,35,40,
          30,50,40,50,60,85]
c['r'] = [40,35,20,20,10,30,
          40,30,35,20,20,30,
          55,50,40,40,40,60]
c['u'] = [35,20,10,30,40,40,
          30,20,30,40,30,40,
          40,50,50,60,60,80]
c['t'] = [30,35,25,25,25,30,
          40,35,40,30,40,35,
          50,50,60,60,50,50]
c['y'] = [30,20,25,25,25,25,
          50,45,40,40,35,45,
          70,60,60,60,60,90] 
c['a'] = [50,50,50,15,20,40,
          30,10,20,10,10,30,
          50,40,30,30,20,40]
c[';'] = [50,30,15,50,50,60,
          20,10,10,20,10,30,
          25,25,30,40,40,70]
c['s'] = [50,55,40,30,20,40,
          35,20,15,10,10,20,
          35,50,40,35,20,40]
c['l'] = [50,40,30,40,55,50,
          20,10,10,15,20,40,
          15,20,30,40,60,70]
c['d'] = [60,55,35,20,30,45,
          40,25,20,10,10,15,
          35,45,30,20,20,30]
c['k'] = [50,30,20,35,55,60,
          15,10,10,20,25,40,
          20,25,25,40,45,70]
c['f'] = [50,50,30,10,35,45,
          40,20,20,12,10,30,
          35,40,40,25,25,30]
c['j'] = [50,30,10,30,50,50,
          30,10,12,20,20,40,
          25,25,30,40,50,60]
c['g'] = [50,50,40,20,35,30,
          50,25,30,20,30,10,
          60,50,45,40,30,25]
c['h'] = [30,20,15,30,55,50,
          10,30,18,30,25,45,
          25,30,30,40,60,70]
c['z'] = [70,80,50,25,35,50,
          30,20,20,20,10,20]
c['/'] = [60,50,25,60,80,70,
          40,15,15,50,40,50,
          20,10,15,20,20,50]
c['x'] = [60,70,60,45,55,60,
          40,45,40,30,30,25,
          40,20,20,10,10,20]
c['.'] = [60,50,40,50,80,60,
          25,20,30,30,45,60,
          20,10,10,20,30,50]
c['c'] = [65,70,45,50,40,60,
          45,45,30,30,35,25,
          40,15,15,15,15,20]
c[','] = [60,50,45,50,80,60,
          40,25,30,35,45,60,
          20,15,15,20,30,70]
c['v'] = [60,55,40,30,45,50,
          40,25,25,15,20,25,
          40,25,20,15,10,30]
c['m'] = [50,40,40,50,70,60,
          30,20,20,25,30,35,
          30,10,10,30,25,50]
c['b'] = [70,65,50,35,70,60,
          60,30,30,15,35,30,
          50,25,30,25,30,10]
c['n'] = [55,45,20,40,70,70,
          30,30,10,30,30,60,
          10,30,25,30,25,60]


c['lshift'] = [60,50,40,30,35,40,
               50,40,20,15,10,25,
               20,20,30,20,15,25]
c['rshift'] = [70,60,70,80,90,90,
               60,50,60,70,70,70,
               50,40,50,40,50,20]
c['tab'] = [60,50,50,60,60,60,
          40,30,30,50,40,60,
          30,20,20,10,0,30]
c['caps'] = [60,50,50,60,60,60,
          40,30,30,50,40,60,
          30,20,20,10,0,30]
c['bs'] = [60,50,50,60,60,60,
          40,30,30,50,40,60,
          30,20,20,10,0,30]
c['enter'] = [60,50,50,60,60,60,
          40,30,30,50,40,60,
          30,20,20,10,0,30]

class TypingCostCalculator:
    

    def __init__(self, layout, base, qwerty_list, left_list, finger_list, cost_matrix):
        """
        [Improved Version] Build mapping based on qwerty_list and left_list (36 keys)
        """
        self.verbose = True
        self.cost_matrix = cost_matrix
        self.layout_map = {} # layout_char -> list of {'base': base_key, 'hand': hand, 'finger': finger}
        self.base_keys_left = []
        self.base_keys_right = []
        
        # 1. Create base (QWERTY) -> layout mapping (30 keys)
        tokens = re.findall(r'\[([^\]]+)\]|(.)', layout)
        parsed_layout = [t[0] if t[0] else t[1] for t in tokens]
        base_to_layout_map = {base[i]: parsed_layout[i] for i in range(min(len(base), len(parsed_layout)))}
        
        # 2. Build layout_map and base_keys (36 keys)
        base_to_hand_map = {} # For creating cost index
        
        for i in range(len(qwerty_list)):
            key = qwerty_list[i] # 'tab', 'q', 'w', ...
            hand = left_list[i]  # 1 or 0
            finger = finger_list[i]
            base_key = key # 'base' name for cost calculation purposes
            
            base_to_hand_map[base_key] = hand
            
            # Determine layout_char (the actual character to be typed)
            if key in base_to_layout_map:
                layout_char = base_to_layout_map[key] # 'q' -> 'q', 'w' -> 'l', ...
            else:
                layout_char = key # 'tab', 'lshift', etc. remain as is

            # self.layout_map uses layout_char as key (lowercase/special key name)
            if layout_char not in self.layout_map:
                self.layout_map[layout_char] = []
            self.layout_map[layout_char].append({'base': base_key, 'hand': hand, 'finger': finger})

        # 3. Build cost indices based on the physical layout order in qwerty_list
        for key in qwerty_list:
            if key in self.cost_matrix:
                hand = base_to_hand_map[key]
                if hand == 1:
                    self.base_keys_left.append(key)
                else:
                    self.base_keys_right.append(key)
        
        self.cost_index_left = {key: i for i, key in enumerate(self.base_keys_left)}
        self.cost_index_right = {key: i for i, key in enumerate(self.base_keys_right)}

        # 4. Define initial position and Shift keys
        self.initial_left_base = 'f'
        self.initial_right_base = 'j'
        
        self.initial_left_char = base_to_layout_map.get('f', 'f')
        self.initial_right_char = base_to_layout_map.get('j', 'j')

        self.left_shift_base = 'lshift'
        self.right_shift_base = 'rshift'


    def _get_cost(self, from_base, to_base, to_hand, cost_offset):
        """
        Helper function to calculate the cost of a single key movement
        [Improvement] Added range check for data inconsistency (e.g., c['c'])
        """
        try:
            if from_base not in self.cost_matrix:
                # print(f"!!! No cost definition (From): {from_base}")
                return 0 # Cost is 0 if source has no cost definition

            cost_list = self.cost_matrix[from_base]
            
            if to_hand == 1: # Left
                if to_base not in self.cost_index_left:
                    # print(f"!!! No cost index (To/Left): {to_base}")
                    return 0 # 0 if destination is outside cost calculation scope
                target_index = self.cost_index_left[to_base]
            else: # Right
                if to_base not in self.cost_index_right:
                    # print(f"!!! No cost index (To/Right): {to_base}")
                    return 0
                target_index = self.cost_index_right[to_base]
                
            # [Robustness] Prevent indexing beyond the cost list length
            if target_index >= len(cost_list):
                 if self.verbose:
                     print(f"!!! Cost list length error: {from_base} (len:{len(cost_list)}) -> {to_base} (idx:{target_index})")
                 return 0
                 
            cost = cost_list[target_index] + cost_offset
            return cost
        
        except (KeyError, IndexError) as e:
            print(f"!!! Cost calculation error: {from_base} -> {to_base} (Hand:{to_hand}), {e}")
            return 0


    def calculate(self, text, cost_offset=0, penalty_rate=1.0, penalty_offset=20, inward_roll_bonus=0, outward_roll_bonus=0):
        """
        [Improved Version] Supports Shift, CR/LF (enter), and Tab, using DP (Viterbi) for optimal multi-candidate resolution.
        """
        class PathNode:
            __slots__ = ['cost', 'count', 'logs', 'prev']
            def __init__(self, cost, count, logs, prev):
                self.cost = cost
                self.count = count
                self.logs = logs
                self.prev = prev

        # state_key = (left_base, right_base, last_hand, last_finger, last_base_key, left_char, right_char)
        initial_state_key = (
            self.initial_left_base, self.initial_right_base, 
            None, None, None, 
            self.initial_left_char, self.initial_right_char
        )
        
        states = {
            initial_state_key: PathNode(0, 0, [], None)
        }

        # [Change 1] Unify newlines to '\n'
        processed_text = text.replace('\r\n', '\n').replace('\r', '\n')

        dp = collections.defaultdict(dict)
        dp[0] = states
        total_len = len(processed_text)

        for i in range(total_len):
            # if i % 50000 == 0:
            #     print(f"Progress: {i}/{total_len} chars...", flush=True)

            if i not in dp or not dp[i]:
                continue
            
            matches = []
            if processed_text[i] == '\n':
                if 'enter' in self.layout_map:
                    matches.append(('enter', 1, False, 'enter'))
            elif processed_text[i] == '\t':
                if 'tab' in self.layout_map:
                    matches.append(('tab', 1, False, 'tab'))
            else:
                for key_str in self.layout_map.keys():
                    if key_str in ['enter', 'tab']: continue
                    match_len = len(key_str)
                    if i + match_len <= len(processed_text):
                        text_slice = processed_text[i:i+match_len]
                        if text_slice.lower() == key_str:
                            is_upper = text_slice[0].isupper()
                            matches.append((key_str, match_len, is_upper, text_slice))

            if not matches:
                # Character unmapped, carry state over
                for state_key, node in dp[i].items():
                    if state_key not in dp[i + 1] or dp[i + 1][state_key].cost > node.cost:
                        dp[i + 1][state_key] = PathNode(node.cost, node.count, node.logs, node.prev)
                del dp[i]
                continue

            for state_key, node in dp[i].items():
                (last_left_base, last_right_base, last_hand, last_finger, last_base_key, last_left_char, last_right_char) = state_key

                for key_str, match_len, is_upper, display_char in matches:
                    candidates = self.layout_map[key_str]
                    
                    for cand in candidates:
                        cand_base_key = cand['base']
                        cand_hand = cand['hand']
                        cand_finger = cand['finger']

                        step_logs = []
                        step_cost = 0
                        step_count = 0

                        cur_left_base = last_left_base
                        cur_right_base = last_right_base
                        cur_left_char = last_left_char
                        cur_right_char = last_right_char
                        cur_hand = last_hand
                        cur_finger = last_finger
                        cur_base_key = last_base_key

                        # 1. Evaluate Shift cost
                        if is_upper:
                            if cand_hand == 1: # Left key uppercase -> Right Shift
                                cand_shift_base_key = self.right_shift_base
                                cand_shift_hand = 0 # Right
                            else: # Right key uppercase -> Left Shift
                                cand_shift_base_key = self.left_shift_base
                                cand_shift_hand = 1 # Left

                            last_shift_base = cur_left_base if cand_shift_hand == 1 else cur_right_base
                            last_shift_char = cur_left_char if cand_shift_hand == 1 else cur_right_char
                            
                            cand_shift_cost = self._get_cost(last_shift_base, cand_shift_base_key, cand_shift_hand, cost_offset)
                            
                            cand_shift_finger = self.layout_map[cand_shift_base_key][0]['finger']
                            if cur_hand == cand_shift_hand:
                                if cur_finger == cand_shift_finger and cur_base_key != cand_shift_base_key:
                                    cand_shift_cost *= penalty_rate
                                    cand_shift_cost += penalty_offset
                                elif cur_finger != cand_shift_finger:
                                    if cur_finger < cand_shift_finger:
                                        cand_shift_cost -= inward_roll_bonus
                                        if self.verbose: step_logs.append(f"  -> Inward Roll Bonus: -{inward_roll_bonus}")
                                    else:
                                        cand_shift_cost -= outward_roll_bonus
                                        if self.verbose: step_logs.append(f"  -> Outward Roll Bonus: -{outward_roll_bonus}")
                            cand_shift_cost = max(0, cand_shift_cost)

                            if self.verbose:
                                hand_label_shift = "Left" if cand_shift_hand == 1 else "Right"
                                step_logs.append(f"[{hand_label_shift} (Shift)] prev:{last_shift_char}({last_shift_base}), curr:(Shift)({cand_shift_base_key}), cost:{cand_shift_cost}")

                            step_cost += cand_shift_cost
                            # No character count added for shift

                            # Update current position after Shift
                            cur_hand = cand_shift_hand
                            cur_finger = cand_shift_finger
                            cur_base_key = cand_shift_base_key
                            if cand_shift_hand == 1:
                                cur_left_base = cand_shift_base_key
                                cur_left_char = cand_shift_base_key
                            else:
                                cur_right_base = cand_shift_base_key
                                cur_right_char = cand_shift_base_key

                        # 2. Evaluate Main key cost
                        last_main_base = cur_left_base if cand_hand == 1 else cur_right_base
                        last_main_char = cur_left_char if cand_hand == 1 else cur_right_char

                        cand_main_cost = self._get_cost(last_main_base, cand_base_key, cand_hand, cost_offset)

                        # Penalty / Roll Bonus check for Main key
                        if cur_hand == cand_hand:
                            if cur_finger == cand_finger and cur_base_key != cand_base_key:
                                cand_main_cost *= penalty_rate
                                cand_main_cost += penalty_offset
                            elif cur_finger != cand_finger:
                                if cur_finger < cand_finger:
                                    cand_main_cost -= inward_roll_bonus
                                    if self.verbose: step_logs.append(f"  -> Inward Roll Bonus: -{inward_roll_bonus}")
                                else:
                                    cand_main_cost -= outward_roll_bonus
                                    if self.verbose: step_logs.append(f"  -> Outward Roll Bonus: -{outward_roll_bonus}")
                        cand_main_cost = max(0, cand_main_cost)

                        if self.verbose:
                            hand_label_main = "Left" if cand_hand == 1 else "Right"
                            step_logs.append(f"[{hand_label_main}] prev:{last_main_char}({last_main_base}), curr:{display_char}({cand_base_key}), cost:{cand_main_cost}")

                        step_cost += cand_main_cost
                        step_count += match_len

                        # Update position after Main key
                        cur_hand = cand_hand
                        cur_finger = cand_finger
                        cur_base_key = cand_base_key
                        if cand_hand == 1:
                            cur_left_base = cand_base_key
                            cur_left_char = key_str
                        else:
                            cur_right_base = cand_base_key
                            cur_right_char = key_str

                        new_state_key = (cur_left_base, cur_right_base, cur_hand, cur_finger, cur_base_key, cur_left_char, cur_right_char)
                        new_total_cost = node.cost + step_cost
                        new_total_count = node.count + step_count

                        # Keep the state with minimum cost
                        target_i = i + match_len
                        if new_state_key not in dp[target_i] or dp[target_i][new_state_key].cost > new_total_cost:
                            new_node = PathNode(new_total_cost, new_total_count, step_logs, node)
                            dp[target_i][new_state_key] = new_node

            del dp[i]

        # After finishing all characters
        states = dp[len(processed_text)]

        # After finishing all characters
        if not states:
            return 0, -20, 0

        best_node = min(states.values(), key=lambda n: n.cost)
        total_cost = best_node.cost
        cost_addition_count = best_node.count

        if self.verbose:
            print("\n--- Calculation Details ---") 
            print(f"--- Initial Position: Left:{self.initial_left_char}({self.initial_left_base}), Right:{self.initial_right_char}({self.initial_right_base}) ---")

            path_logs = []
            cur = best_node
            while cur:
                if cur.logs:
                    path_logs.append(cur.logs)
                cur = cur.prev

            for logs in reversed(path_logs):
                for log in logs:
                    print(log)

            print("--- Complete ---\n") 

        normalized_cost = 0
        if cost_addition_count > 0:
            normalized_cost = total_cost / cost_addition_count
            
        return total_cost, normalized_cost, cost_addition_count


    
def calcn(name,layout,text_to_check,verbose=False, norm = 1.0):
    calculator = TypingCostCalculator(layout, base, qwerty, left, fingers, c)
    
#    print("Keyboard Layout Cost Calculator (Supports Shift, Enter, Tab)")
#    print("--------------------------------------------------")
#    print(f"Layout: {layout}")
    
    calculator.verbose = verbose # Disable detailed output
    
    # Execute calculation (cost_offset=10)
    total_cost, normalized_cost, count = calculator.calculate(text_to_check, 0)
    if norm != 1.0:
        normalized_cost = normalized_cost / norm * 100

    # Display final result
    #print(f"Total Cost: {total_cost}")
    print(f"Layout: {layout} : {normalized_cost:.4f} : {name}")
    #print(f"Type Count (Including Shift, Enter, Tab): {count}")
    #print("-" * 30)
    return normalized_cost

def calc(layout,text_to_check,verbose=False):
    calcn("",layout,text_to_check,verbose)
             

if __name__ == "__main__":
    # ⚠️ This path needs to be changed depending on the execution environment.
    japanese = True
    if japanese:
        file_path = "../data/jap-n.txt"
    else:
        file_path = "../data/English_sample.txt"
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            text_to_check = f.read()
            
        print("-" * 30)
        print(f"file: '{file_path}'")

        #layout = 'qwubkjfly;aretgmnoiszcxdvph,./' #QWERTY
        layout = 'qwertyuiopasdfghjkl;zxcvbnm,./' #QWERTY
        qwerty_norm = calcn("QWERTY",layout,text_to_check,False,1)

        if not japanese:
            #layout = 'qwldkjfuy;asrtgmneiozxcvbph,./' #FMIX X
            layout = 'ql,p/;fudkarenbgsitozw.hjvcymx' #arensito
            calcn("Arensito",layout,text_to_check,False, qwerty_norm)
        #layout = 'qwlbkjfuy;asrtghneiozxcdvpm,./' 
        #layout = 'qwertyuiopasdfghjkl;zxcvbnm,./' #QWERTY
    
        # Test case (including tab and newlines)
        # test_text = "..;;p" 
        # print(f"test_text: '{test_text}'")
            layout = 'qwldkjfuy;asrtghneiozxcvbpm,./' #FMIX15
            calcn("FMIX15",layout,text_to_check,False, qwerty_norm)

            layout = 'qwldkjfuy;arstghneiozxcvbpm,./' #FMIX16
            calcn("FMIX16",layout,text_to_check,False, qwerty_norm)

            layout = 'qwldjkfuy;arstghneiozxcvbpm,./' #FMIX16
            calcn("FMIX16_2",layout,text_to_check,False, qwerty_norm)

            layout = 'ypoujkdlcwinea,mhtsrqz/.:bfgvx'
            calcn("MTGAP",layout,text_to_check,False, qwerty_norm)

            layout = 'qwfrkylup;asdtghneiozxcvbjm,./' #FMIX12f
            calcn("FMIX12f",layout,text_to_check,False, qwerty_norm)

            layout = 'qwlrkyfup;asdtghneiozxcvbjm,./' #FMIX12
            calcn("FMIX12",layout,text_to_check,False, qwerty_norm)
        
            layout = 'qwrlkyfup;asdtghneiozxcvbjm,./' #FMIX13
            calcn("FMIX13",layout,text_to_check,False, qwerty_norm)
            #layout = 'qwfrkylup;asdtghneiozxcvbjm,./' #FMIX12f
            layout = 'qwfpgjluy;arstdhneiozxcvbkm,./' #colemak
            calcn("Colemak",layout,text_to_check,False, qwerty_norm)
    
            layout = 'qwldkyfup;asrtghneiozxcvbjm,./' #FMIX14
            calcn("FMIX14",layout,text_to_check,False, qwerty_norm)

            layout = 'qwldkyfuj;asrtghneiozxcvbpm,./' #FMIX14
            calcn("FMIX14 fuj",layout,text_to_check,False, qwerty_norm)

            layout = 'qwldjyfup;asrtghneiozxcvbkm,./' 
            calcn("FMIX14 vbk",layout,text_to_check,False, qwerty_norm)

            layout = '/,.pyfgcrlaoeuidhtns;qjkxbmwvz' #Dvorak
            calcn("Dvorak",layout,text_to_check,False, qwerty_norm)

            layout = 'qcufkzlpy;aretdmnoisjwxgbvh,./' #
            calcn("aret",layout,text_to_check,False, qwerty_norm)

        

            layout = 'qprdcbkuyxatnswmheio/,lgjfv;z.' #Wakasagi
            calcn("Wakasagi",layout,text_to_check,False, qwerty_norm)

            layout = 'ypoujkdlcwinea,mhtsrqz/.:bfgvx' #MTGAP
            calcn("MTGAP",layout,text_to_check,False, qwerty_norm)

            layout = ",.ucvqfdlyaoesgbntri;x/wzphmkj" #Boo
            calcn("Boo",layout,text_to_check,False, qwerty_norm)
        
            layout = "fdlbvjgou,strnkymaeizqxhpwc/;." #Stronk
            calcn("Stronk",layout,text_to_check,False, qwerty_norm)

            layout = "wgdfbqluoyrsthkjneaixcmpvz,.;/"
            calcn("aptv3",layout,text_to_check,False, qwerty_norm)

            layout = "qwdrfjluyxnstegceaiozpmhbkv,./"
            calcn("kotone",layout,text_to_check,False, qwerty_norm)

            layout = "qwrdfjluyxnstegceaiozpmhbkv,./"
            calcn("kotone2",layout,text_to_check,False, qwerty_norm)


            layout = "qwrdfjluyxsntegceaiozpmhbkv,./"
            calcn("kotone3",layout,text_to_check,False, qwerty_norm)

            layout = "qwrdfjluyxstnegceaiozpmhbkv,./"
            calcn("kotone4",layout,text_to_check,False, qwerty_norm)

            layout = "qwrdfjluyxnstagcaieozpmhbkv,./"
            calcn("kotone5",layout,text_to_check,False, qwerty_norm)
        else:
            layout = "qwrdfj[yu]u[yo]xnstkgceaiozpmhb-[ya],./"
            calcn("kotone2j",layout,text_to_check,False, qwerty_norm)

            layout = 'qwdrfylup-asktghneiozxcvbjm,./' #FMIX12f
            calcn("FMIX13R",layout,text_to_check,False, qwerty_norm)


    except FileNotFoundError:
        print(f"\nError: File '{file_path}' not found. Please check the path.", file=sys.stderr)
    except Exception as e:
        print(f"\nAn error occurred: {e}", file=sys.stderr)