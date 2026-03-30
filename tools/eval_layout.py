import sys

# basic characters
base   = 'qwertyuiopasdfghjkl;zxcvbnm,./'

# 3 rows, 18 columns 
qwerty   = ["tab",   "q","w","e","r","t","y","u","i","o","p","bs"
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
          50,40,40,25,15,30,
          70,70,50,50,30,40] 
c['p'] = [25,30,15,25,20,40,
          35,15,25,40,40,45,
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
          30,30,40,30,40,35,
          50,50,60,60,50,50]
c['y'] = [30,20,25,25,25,25,
          50,45,40,40,35,40,
          70,60,60,60,60,90] 
c['a'] = [50,50,50,15,20,35,
          30,10,20,10,10,30,
          50,40,30,30,20,40]
c[';'] = [45,30,15,50,50,60,
          20,10,10,20,10,30,
          25,25,30,40,40,70]
c['s'] = [50,55,35,30,20,30,
          35,25,10,10,10,20,
          35,50,35,35,20,40]
c['l'] = [50,40,30,35,55,50,
          20,10,10,15,25,40,
          15,20,30,35,50,70]
c['d'] = [60,55,35,20,30,35,
          40,15,15,10,10,15,
          35,40,30,20,20,30]
c['k'] = [40,30,20,35,55,60,
          15,10,10,15,15,40,
          20,25,25,40,40,70]
c['f'] = [50,50,30,10,35,40,
          40,10,15,12,10,30,
          35,40,40,25,25,30]
c['j'] = [40,30,10,30,50,50,
          30,10,12,15,10,40,
          25,25,30,40,50,60]
c['g'] = [50,50,40,20,35,30,
          50,15,30,20,30,10,
          60,50,45,40,30,25]
c['h'] = [30,20,15,30,50,50,
          10,30,20,30,15,45,
          25,30,30,40,50,70]
c['z'] = [70,80,50,25,35,50,
          45,40,40,15,15,25,
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
          40,20,25,15,20,25,
          40,25,20,15,10,30]
c['m'] = [50,40,40,50,70,60,
          30,20,20,25,30,35,
          30,10,10,30,25,50]
c['b'] = [70,65,50,35,70,60,
          60,25,30,15,35,30,
          50,25,30,25,30,10]
c['n'] = [55,45,20,40,70,70,
          30,30,10,30,25,60,
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
    

    def __init__(self, layout, base, qwerty_list, left_list, cost_matrix):
        """
        [Improved Version] Build mapping based on qwerty_list and left_list (36 keys)
        """
        self.verbose = True
        self.cost_matrix = cost_matrix
        self.layout_map = {} # layout_char -> {'base': base_key, 'hand': hand}
        self.base_keys_left = []
        self.base_keys_right = []
        
        # 1. Create base (QWERTY) -> layout mapping (30 keys)
        base_to_layout_map = {base[i]: layout[i] for i in range(len(base))}
        
        # 2. Build layout_map and base_keys (36 keys)
        base_to_hand_map = {} # For creating cost index
        
        for i in range(len(qwerty_list)):
            key = qwerty_list[i] # 'tab', 'q', 'w', ...
            hand = left_list[i]  # 1 or 0
            base_key = key # 'base' name for cost calculation purposes
            
            base_to_hand_map[base_key] = hand
            
            # Determine layout_char (the actual character to be typed)
            if key in base_to_layout_map:
                layout_char = base_to_layout_map[key] # 'q' -> 'q', 'w' -> 'l', ...
            else:
                layout_char = key # 'tab', 'lshift', etc. remain as is

            # self.layout_map uses layout_char as key (lowercase/special key name)
            self.layout_map[layout_char] = {'base': base_key, 'hand': hand}

        # 3. Build cost indices (only for keys present in c.keys())
        for base_key in self.cost_matrix.keys():
            if base_key in base_to_hand_map:
                hand = base_to_hand_map[base_key]
                if hand == 1:
                    self.base_keys_left.append(base_key)
                else:
                    self.base_keys_right.append(base_key)
        
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


    def calculate(self, text, cost_offset=0):
        """
        [Improved Version] Supports Shift, CR/LF (enter), and Tab
        """
        total_cost = 0
        cost_addition_count = 0 
        
        last_left = {
            'base': self.initial_left_base,
            'char': self.initial_left_char,
            'hand': 1 
        }
        last_right = {
            'base': self.initial_right_base,
            'char': self.initial_right_char,
            'hand': 0
        }

        if self.verbose:
            print("\n--- Calculation Details ---") 
            print(f"--- Initial Position: Left:{last_left['char']}({last_left['base']}), Right:{last_right['char']}({last_right['base']}) ---")

        # [Change 1] Unify newlines to '\n'
        processed_text = text.replace('\r\n', '\n').replace('\r', '\n')

        # [Change 2] Loop through processed_text
        for char in processed_text: 
            
            is_upper = False # Default

            # [Change 3] Map special characters to 'layout_map' keys
            if char == '\n':
                char_to_check = 'enter'
                # is_upper remains False
            elif char == '\t':
                char_to_check = 'tab'
                # is_upper remains False
            else:
                # Normal characters
                char_to_check = char.lower()
                is_upper = char.isupper() # Check for uppercase

            if char_to_check not in self.layout_map:
                # Ignore spaces, numbers, and unmapped symbols
                continue

            # --- Original logic starts here ---
            current_key_info = self.layout_map[char_to_check]
            current_base_key = current_key_info['base']
            current_hand = current_key_info['hand']

            shift_cost = 0
            shift_base_key = None
            shift_hand = None

            # --- 1. Determine Shift necessity (is_upper is used here) ---
            if is_upper:
                if current_hand == 1: # Left key uppercase -> Right Shift
                    shift_base_key = self.right_shift_base
                    shift_hand = 0 # Right
                elif current_hand == 0: # Right key uppercase -> Left Shift
                    shift_base_key = self.left_shift_base
                    shift_hand = 1 # Left

            # --- 2. Calculate Shift cost (if needed) ---
            if shift_base_key:
                last_shift_info = last_left if shift_hand == 1 else last_right
                last_shift_base = last_shift_info['base']
                last_shift_char = last_shift_info['char']

                shift_cost = self._get_cost(last_shift_base, shift_base_key, shift_hand, cost_offset)
                
                if self.verbose:
                    hand_label_shift = "Left" if shift_hand == 1 else "Right"
                    print(f"[{hand_label_shift} (Shift)] prev:{last_shift_char}({last_shift_base}), curr:(Shift)({shift_base_key}), cost:{shift_cost}")
                
                total_cost += shift_cost
                cost_addition_count += 1
                
                # Update position after pressing Shift
                shift_info = {'base': shift_base_key, 'char': shift_base_key, 'hand': shift_hand}
                if shift_hand == 1:
                    last_left = shift_info
                else:
                    last_right = shift_info

            # --- 3. Calculate Main key cost ---
            last_main_info = last_left if current_hand == 1 else last_right
            last_main_base = last_main_info['base']
            last_main_char = last_main_info['char']

            # [Fix] If char_to_check is 'enter' or 'tab', 'char' is not the original character
            # Determine character for debug display
            display_char = char_to_check if char_to_check in ['enter', 'tab'] else char

            current_cost = self._get_cost(last_main_base, current_base_key, current_hand, cost_offset)

            if self.verbose:
                hand_label_main = "Left" if current_hand == 1 else "Right"
                print(f"[{hand_label_main}] prev:{last_main_char}({last_main_base}), curr:{display_char}({current_base_key}), cost:{current_cost}")
            
            total_cost += current_cost
            cost_addition_count += 1
            
            # --- 4. Update position after pressing Main key ---
            current_info = {
                'base': current_base_key,
                'char': char_to_check, # Position memory based on layout_map keys like 'q', 'enter', 'tab'
                'hand': current_hand
            }
            if current_hand == 1:
                last_left = current_info
            else:
                last_right = current_info

        if self.verbose:
            print("--- Complete ---\n") 

        normalized_cost = 0
        if cost_addition_count > 0:
            normalized_cost = total_cost / cost_addition_count
            
        return total_cost, normalized_cost-30, cost_addition_count


    
def calcn(name,layout,text_to_check,verbose=False):
    calculator = TypingCostCalculator(layout, base, qwerty, left, c)
    
#    print("Keyboard Layout Cost Calculator (Supports Shift, Enter, Tab)")
#    print("--------------------------------------------------")
#    print(f"Layout: {layout}")
    
    calculator.verbose = verbose # Disable detailed output
    
    # Execute calculation (cost_offset=10)
    total_cost, normalized_cost, count = calculator.calculate(text_to_check, 10)
    
    # Display final result
    #print(f"Total Cost: {total_cost}")
    print(f"Layout: {layout} : {normalized_cost:.4f} : {name}")
    #print(f"Type Count (Including Shift, Enter, Tab): {count}")
    #print("-" * 30)
        
def calc(layout,text_to_check,verbose=False):
    calcn("",layout,text_to_check,verbose)
             

if __name__ == "__main__":
    # ⚠️ This path needs to be changed depending on the execution environment.
    file_path = "../data/English_sample.txt"
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            text_to_check = f.read()
            
        print("-" * 30)
        print(f"file: '{file_path}'")

        #layout = 'qwldkjfuy;asrtgmneiozxcvbph,./' #FMIX X
        layout = 'ql,p/;fudkarenbgsitozw.hjvcymx' #arensito
        calcn("Arensito",layout,text_to_check,False)
    #layout = 'qwlbkjfuy;asrtghneiozxcdvpm,./' 
    #layout = 'qwertyuiopasdfghjkl;zxcvbnm,./' #QWERTY
 
    # Test case (including tab and newlines)
    # test_text = "..;;p" 
    # print(f"test_text: '{test_text}'")
        layout = 'qwldkjfuy;asrtghneiozxcvbpm,./' #FMIX15
        calcn("FMIX15",layout,text_to_check,False)

        layout = 'ypoujkdlcwinea,mhtsrqz/.:bfgvx'
        calcn("MTGAP",layout,text_to_check,False)

        layout = 'qwfrkylup;asdtghneiozxcvbjm,./' #FMIX12f
        calcn("FMIX12f",layout,text_to_check,False)

        layout = 'qwlrkyfup;asdtghneiozxcvbjm,./' #FMIX12
        calcn("FMIX12",layout,text_to_check,False)
    
        layout = 'qwrlkyfup;asdtghneiozxcvbjm,./' #FMIX13
        calcn("FMIX13",layout,text_to_check,False)
        #layout = 'qwfrkylup;asdtghneiozxcvbjm,./' #FMIX12f
        layout = 'qwfpgjluy;arstdhneiozxcvbkm,./' #colemak
        calcn("Colemak",layout,text_to_check,False)
 
        layout = 'qwldkyfup;asrtghneiozxcvbjm,./' #FMIX14
        calcn("FMIX14",layout,text_to_check,False)

        layout = 'qwldkyfuj;asrtghneiozxcvbpm,./' #FMIX14
        calcn("FMIX14 fuj",layout,text_to_check,False)

        layout = 'qwldjyfup;asrtghneiozxcvbkm,./' 
        calcn("FMIX14 vbk",layout,text_to_check,False)

        layout = '/,.pyfgcrlaoeuidhtns;qjkxbmwvz' #Dvorak
        calcn("Dvorak",layout,text_to_check,False)

        layout = 'qcufkzlpy;aretdmnoisjwxgbvh,./' #
        calcn("aret",layout,text_to_check,False)

        #layout = 'qwubkjfly;aretgmnoiszcxdvph,./' #QWERTY
        layout = 'qwertyuiopasdfghjkl;zxcvbnm,./' #QWERTY
        calcn("QWERTY",layout,text_to_check,False)

        layout = 'qprdcbkuyxatnswmheio/,lgjfv;z.' #Wakasagi
        calcn("Wakasagi",layout,text_to_check,False)

        layout = 'ypoujkdlcwinea,mhtsrqz/.:bfgvx' #MTGAP
        calcn("MTGAP",layout,text_to_check,False)

        layout = ",.ucvqfdlyaoesgbntri;x/wzphmkj" #Boo
        calcn("Boo",layout,text_to_check,False)
    
        layout = "fdlbvjgou,strnkymaeizqxhpwc/;." #Stronk
        calcn("Stronk",layout,text_to_check,False)

        layout = "wgdfbqluoyrsthkjneaixcmpvz,.;/"
        calcn("aptv3",layout,text_to_check,False)

    except FileNotFoundError:
        print(f"\nError: File '{file_path}' not found. Please check the path.", file=sys.stderr)
    except Exception as e:
        print(f"\nAn error occurred: {e}", file=sys.stderr)