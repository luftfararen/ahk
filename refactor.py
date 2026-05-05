import re

def refactor():
    with open('sands.ahk', 'r', encoding='utf-8-sig') as f:
        content = f.read()

    # 1. Rename functions
    renames = {
        r'\baddBraces\b': 'AddBraces',
        r'\bremoveBraces\b': 'RemoveBraces',
        r'\bsc_from_char\b': 'ScFromChar',
        r'\bchar_from_sc\b': 'CharFromSc',
        r'\bchar_from_str\b': 'CharFromStr',
        r'\bstr_from_char\b': 'StrFromChar',
        r'\bval_str\b': 'ValStr',
        r'\bkey_str\b': 'KeyStr',
        r'\bdisp_str\b': 'DispStr',
    }
    for old, new in renames.items():
        content = re.sub(old, new, content)

    # 2. Delete MKey class
    mkey_pattern = r'/\*=*[\s\S]*?\[Class\] MKey \(モディファイアキー\).*?class MKey \{[\s\S]*?\} ;class MKey\n+'
    content = re.sub(mkey_pattern, '', content)

    # 3. Delete I_* definitions
    i_pattern = r'I_1 := 0\n(?:I_[a-zA-Z0-9_]+ := \d+\n)+'
    content = re.sub(i_pattern, '', content)

    # 4. Remove commented MKey instantiations
    mkey_inst_pattern = r'; --- モディファイアキー \(MKey\) ---\n(?:; [a-z0-9]+ := MKey\(.*?\)\n)+; colon := LKey\(C_COLON, 2\)\n+'
    content = re.sub(mkey_inst_pattern, '; --- モディファイアキー (LKey Mode 3) ---\n', content)

    # 5. Fix comment mentioning MKey
    content = content.replace('; 1. センターモディファイア (MKey)', '; 1. センターモディファイア (LKey)')
    content = content.replace('; グローバルホットキー (MKey バインド)', '; グローバルホットキー (モディファイア バインド)')
    content = content.replace('; MKey（モディファイア）オブジェクトにバインドします。', '; モディファイアオブジェクトにバインドします。')

    # 6. Delete shift_lambda stuff
    content = content.replace(';shift_lambda := () => GetKeyState("Shift", "P")\n\n', '')
    content = content.replace('    ;global shift_lambda\n    ;return shift_lambda()\n', '')

    # 7. Delete R_* commented variables
    commented_vars = [
        r';R_YEN := "sc07D"\n',
        r';R_BACKSLASH := "sc073"\n',
        r';R_HAT := "sc00D"\n',
        r';R_SEMICOLON := "sc027"\n',
        r';R_COLON := "sc028"\n',
        r';R_COMMA := "sc033"\n',
        r';R_SLASH := "sc035"\n'
    ]
    for var in commented_vars:
        content = re.sub(var, '', content)

    # 8. Delete LKey.SetLongKey commented out block
    set_long_key_pattern = r'    ; /\*\*\n    ;  \* 長押し時に送信するキー文字列を設定する[\s\S]*?;     \}\n\n'
    content = re.sub(set_long_key_pattern, '', content)

    # 9. Delete mode 5 commented block
    mode_5_pattern = r'        ; ; 5\. モード 5 \(KeyWait ベースの即時入力 \+ 長押し置換\)[\s\S]*?        ; \}\n\n'
    content = re.sub(mode_5_pattern, '', content)

    with open('sands.ahk', 'w', encoding='utf-8-sig') as f:
        f.write(content)

if __name__ == "__main__":
    refactor()
