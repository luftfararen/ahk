import os

def create_score_map(keylayout):
    """
    キーレイアウト文字列とスコアのリストから、
    文字とスコアのマッピング辞書、および全スコアの平均値を生成します。

    Returns:
        tuple: (文字とスコアがマッピングされた辞書, 全スコアの平均値)
    """
    
    # 各キーに対応するスコアをリストとして定義
    scores = [50, 30, 20, 25, 50, 40, 25, 20, 30, 50,
              12, 15, 11, 10, 20, 20, 10, 11, 15, 12,
              40, 35, 25, 20, 35, 25, 20, 30, 40, 50]
    
    # keylayoutの各文字とscoresの値を対応付けた辞書を作
    score_map = {char: score for char, score in zip(keylayout, scores)}
    
    # 全スコアの平均値を計算
    average_score = sum(scores) / len(scores) if scores else 0
    
    return score_map, average_score

def analyze_text_score(filepath, score_map, base_average_score):
    """
    テキストファイルを読み込み、キーレイアウトのスコアを分析します。
    計算された1文字あたりのスコアを、全キーの平均スコアでさらに正規化します。

    Args:
        filepath (str): 分析対象のテキストファイルのパス。
        score_map (dict): 文字とスコアのマッピング辞書。
        base_average_score (float): 全キーのスコアの平均値。

    Returns:
        float: 最終的に正規化されたスコア。
    """
    total_score = 0
    char_count = 0
    
    try:
        # 'utf-8'エンコーディングでファイルを開く
        with open(filepath, 'r', encoding='utf-8') as f:
            # ファイルの内容を全て小文字に変換して読み込む
            text = f.read().lower()
            
            for char in text:
                # スコアマップに存在する文字の場合のみスコアを加算
                if char in score_map:
                    total_score += score_map[char]
                    char_count += 1
                    
    except FileNotFoundError:
        print(f"エラー: ファイル '{filepath}' が見つかりません。")
        return 0.0
    
    # 分析対象の文字がなければ0を返す
    if char_count == 0:
        print("警告: ファイル内にスコア分析対象の文字が見つかりませんでした。")
        return 0.0
    
    # テキストの1文字あたりの平均スコアを計算
    text_average_score = total_score / char_count
    
    # ゼロ除算を避ける
    if base_average_score == 0:
        print("警告: 基準となる平均スコアが0です。")
        return 0.0
        
    # 全キーの平均スコアでさらに正規化
    final_normalized_score = text_average_score / base_average_score
    return 1.0-final_normalized_score


def calculate_layout_score(key_layout,sample_filename):
    # 1. スコアマップと全キーの平均スコアを作成
    score_mapping, avg_score = create_score_map(key_layout)
    
    
    # 3. テキストファイルを分析してスコアを計算
    layout_score = analyze_text_score(sample_filename, score_mapping, avg_score)
    
    # 4. 結果を表示
    print(f"スコア({sample_filename}): {layout_score:.3f}")

def calculate_layout_scores(key_layout):
    sample_filename = "english_sample.txt"
    calculate_layout_score(key_layout,sample_filename)
    sample_filename = "jap-n.txt"
    calculate_layout_score(key_layout,sample_filename)
    calculate_layout_score(key_layout,"jap-n-kc.txt")
    calculate_layout_score(key_layout,"jap-n-vbj.txt")
    print("\n")
   
   
# --- メインの処理 ---
if __name__ == "__main__":
 
    # 2. 分析用のサンプルテキストファイルを作成
    sample_filename = "english_sample.txt"
  
    # キーボードのレイアウトを一行の文字列として定義
    qwerty_layout =("qwertyuiop"
                  "asdfghjkl;"
                  "zxcvbnm,./")
    print(f"qwerty: {qwerty_layout}")
    calculate_layout_scores(qwerty_layout)
 
    fmix_layout = ("qwldkyfup;"
                  "asrtghneio"
                  "zxcvbjm,./")
    print(f"FMIX14: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmixr_layout = ("qwrdlyfup;"
                  "asktghneio"
                  "zxcvbjm,./")
    print(f"FMIX14R: {fmixr_layout}")
    calculate_layout_scores(fmixr_layout)

    fmix2_layout = ("qwlpkyfuj;"
                  "asrtghneio"
                  "zxcvbdm,./")
    print(f"キーレイアウト: {fmix2_layout}")
    calculate_layout_scores(fmix2_layout)

    fmix3_layout = ("qwldkyfuj;"
                  "asrtghneio"
                  "zxcvbpm,./")
    print(f"FMIX14-vbp: {fmix3_layout}")
    calculate_layout_scores(fmix3_layout)


    layout = ("qwrdlyfuj;"
                  "asktghneio"
                  "zxcvbpm,./")
    print(f"FMIX14R - vbp: {layout}")
    calculate_layout_scores(layout)

    colmak_layout = ("qwfpgjluy;"
                  "arstdhneio"
                  "zxcvkm,./")
    print(f"Colmak: {colmak_layout}")
    calculate_layout_scores(colmak_layout)

    wakasagi_layout = ("qprdcbkuyx"
                    "atnswmheio"
                    "/,lgjfv;z.")
    print(f"ワカサギ: {wakasagi_layout}")
    calculate_layout_scores(wakasagi_layout)

    layout = ("ypoujkdlcw"
            "inea,mhtsr"
            "qz/.:bfgvx")
    print(f"mtgap: {layout}")
    calculate_layout_scores(layout)
    
    layout = ("qlu,.fwryp"
             "eiao-ktnsh"
             "zxcv;gdmjb")
    print(f"大西: {layout}")
    calculate_layout_scores(layout)

    fmix_layout = ("qwlrkyfup;"
                  "asdtghneio"
                  "zxcvbjm,./")
    print(f"FMIX12: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmix_layout = ("qwdlkyfup;"
                  "asrtghneio"
                  "zxcvbjm,./")
    print(f"FMIX14s: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmix_layout = ("qwdrlyfup;"
                  "asktghneio"
                  "zxcvbjm,./")
    print(f"FMIX13R: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmix_layout = ("qwrlkyfup;"
                  "asdtghneio"
                  "zxcvbjm,./")
    print(f"FMIX13: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmix_layout = ("qwlrkyfup;"
                  "asdtghneio"
                  "zxcvbjm,./")
    print(f"FMIX12: {fmix_layout}")
    calculate_layout_scores(fmix_layout)

    fmix_layout = ("qwlrkjfuy;"
                  "asdtghneio"
                  "zxcvbpm,./")
    print(f"FMIX15: {fmix_layout}")
    calculate_layout_scores(fmix_layout)
