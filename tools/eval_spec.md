# キー配列生体力学評価モデル仕様書 (Calculated Mode v0.88)

## 0. 基本方針：評価要素の完全独立分離と15モジュール化

本モデルでは、二重カウントや他指標との混同を排除し、各評価要素を物理的・生理学的に独立して評価するため、タイピングコストを以下の**15の独立した詳細モジュール**に分類して出力する。

なお、統合スコア算出に関し、各モジュールのコストの寄与率は、経験に基づいた配分である。
統合スコアは参考とし、レイアウトごとにコストを比較して、レイアウトの特性を把握するために利用することを薦める。

| #   | モジュール名      | 分類             | 概要・計算対象                                                                   |
| --- | ----------------- | ---------------- | -------------------------------------------------------------------------------- |
| 1   | **Static**        | 静的             | 指単体の筋力（押し下げ抵抗）＋無条件打鍵基本オーバーヘッド（+5.0）               |
| 2   | **Move**          | 移動             | Fitts則拡張モデルに基づく物理空間移動コスト（※Roll割引適用前の純移動値）         |
| 3   | **HandSplit**     | 姿勢             | 各手の動的重心（EMA）からの指の引き裂かれ・離脱ペナルティ                        |
| 4   | **Tendon**        | 姿勢             | 隣接指間（小薬・薬中）のY軸高低差に伴う腱の干渉・ひっぱりペナルティ              |
| 5   | **Flexion**       | 姿勢             | 中指・薬指の下段打鍵時に人差し指が上段に残る無理な巻き込み屈曲ペナルティ（+8.0） |
| 6   | **SFB**           | 文脈(ペナルティ) | 同一指での異なるキーの直後連続打鍵ペナルティ（Bigram SFB）                       |
| 7   | **SFS**           | 文脈(ペナルティ) | 同一指での1〜3文字置きのスキップグラム打鍵ペナルティ（Skipgram SFS）             |
| 8   | **Scissor**       | 文脈(ペナルティ) | 隣接指によるホーム段を経由しない行またぎシザーペナルティ（Bigram Scissor）       |
| 9   | **FSS**           | 文脈(ペナルティ) | 隣接指による1〜3文字置きのスキップグラムシザーペナルティ（Skipgram FSS）         |
| 10  | **Redirect**      | 文脈(ペナルティ) | 同一手での連続3打鍵におけるベクトル角度の急反転（慣性ターン負荷）                |
| 11  | **Roll**          | 文脈(割引)       | 滑らかなアルペジオ打鍵によるMoveコスト軽減量（※マイナス値表示、上限＝Move）      |
| 12  | **RowJump**       | 文脈(ペナルティ) | 同一手での上段-下段の直接ジャンプペナルティ（+15.0）                             |
| 13  | **LSS**           | 文脈(ペナルティ) | 横方向への無理な伸ばしスキップグラムペナルティ（Skipgram LSS）                   |
| 14  | **HandFatigue**   | 疲労             | 同一手での連続連打による非線形な手全体の連続稼働疲労                             |
| 15  | **FingerFatigue** | 疲労             | 直近10ストローク内における同一指の集中的・過多使用（累積酷使）疲労               |

---

## 1. 概要と基本設計思想

本仕様書は、キーボードの物理的形状（ハードウェア特性）と、人間の手の解剖学的・生体力学的な制約（身体特性）をモデリングし、任意の論理配列が持つ「タイピングコスト（非効率性と疲労度）」を算出するための計算ロジックを定義する。

### 1-1. 両手10指トラッキングと動的計画法 (DP)

本モデルは、直前の1打鍵だけではなく、**「10本すべての指の現在座標」**を常に記憶・追跡する。テキスト内の各文字に対し、どの手・どの指で打鍵するかの全分岐をシミュレーションし、動的計画法 (DP) によってテキスト全体でのトータルコストが最小となる最適な運指パスを計算する。

### 1-2. 欠落文字（ハイフン等）のシミュレーション

コーパスに出現する文字（例：`-`）が配列に存在しない場合、親指モディファイア（`lthumb` / `rthumb`）をホールドしながらQWERTYの `f` / `j` 位置を打鍵する特殊動作としてシミュレーションされ、動的にコストが加算される。

---

## 2. 物理形状エミュレーションと座標変換

入力となる論理配列のキー位置を、3行×10列のグリッド座標 $(X_{\text{grid}}, Y_{\text{grid}})$ と定義する。

- $X_{\text{grid}}$ : 左端 0 ～ 右端 9
- $Y_{\text{grid}}$ : 上段 0、中段（ホーム） 1、下段 2

選択された形状モードに応じて物理座標 $(X_{\text{phys}}, Y_{\text{phys}})$ を算出する。

### 2-1. ロウスタッガード (Row Staggered)

- $Y_{\text{phys}} = Y_{\text{grid}}$
- $X_{\text{phys}} = X_{\text{grid}} + \text{Offset}_{\text{row}}[Y_{\text{grid}}]$ （Offset: $-0.25, 0.00, +0.50$）

### 2-2. オーソリニア (Ortholinear) / カラムスタッガード (Column Staggered)

- Ortholinear: $X_{\text{phys}} = X_{\text{grid}}$, $Y_{\text{phys}} = Y_{\text{grid}}$
- Column Staggered: 各指の長さに合わせた縦列ごとのオフセットを適用（列ごとに $+0.25, +0.10, -0.15, 0.00, 0.00, 0.00, 0.00, -0.15, +0.10, +0.25$）。

### 2-3. 手の接近角度（Angle of Approach）の回転適用

生成された物理座標に対して、角度 $\theta$（デフォルト $15.0^\circ$）の回転座標変換（ハの字姿勢）を適用する。

- 左手（Hand 1）: 時計回り回転（$\theta$）
- 右手（Hand 0）: 反時計回り回転（$-\theta$）

---

## 3. 第1階層: Static (静的コスト)

キー単体を押し下げる際の「純粋な基礎負荷」。物理的な移動距離や段によるペナルティは含まない。

$$C_{\text{static}} = W_{\text{strength}}[Hand][f] \times \text{base\_cost\_multiplier} + \text{BaseOverhead}$$

- $\text{base\_cost\_multiplier} = 10.0$
- $\text{BaseOverhead} = 5.0$ （打鍵1回につき無条件で加算される基本オーバーヘッド）
- $W_{\text{strength}}[Hand][f]$: 各指の筋力抵抗ウェイト。
  - 小指 (Finger 0): **2.20**
  - 薬指 (Finger 1): **1.80**
  - 中指 (Finger 2): **1.20**
  - 人差し指 (Finger 3): **1.00**
  - 親指 (Finger 4): **1.00**

---

## 4. 第2階層: Move (移動コスト)

指の空間的な移動に伴うコスト。各指（10本）が最後に打鍵したキー（座標）を個別に追跡し、今回打鍵する指が前回位置からどれだけ移動したかを計算する。

### 4-1. 物理移動距離 $D_{3D}$ と変位ペナルティ

横方向への開き（1.5倍）、およびZ軸（打鍵深度）の変位を考慮した異方性距離 $D_{3D}$ を算出する。

$$D_{3D} = \sqrt{(1.5 \times \Delta X)^2 + (\Delta Y)^2 + (w_z \times \Delta Z)^2}$$

- $\Delta Z$: 上段 $+0.15$, 中段 $0.00$, 下段 $-0.10$。上方向移動（$\Delta Z > 0$）は重力に逆らうためウェイト $w_z = 2.5$ （下方向移動は $w_z = 1.0$）。
- **解剖学的段ペナルティ ($P_{\text{row}}[Finger][Row]$)**:
  - **人差し指**: 下段 (1.10) < 上段 (1.20) 【曲げ（屈曲）が得意】
  - **中指**: 上段 (1.05) < 下段 (1.20) 【伸ばし（伸展）が得意】
  - **薬指**: 上段 (1.60) < 下段 (1.80) 【伸ばし（伸展）が得意】
  - **小指**: 上段 (2.20) < 下段 (2.60) 【伸ばし（伸展）が得意】
- **ラテラルストレッチペナルティ ($P_{\text{lat}}$)**:
  - 人差し指で中央拡張列（$X_{\text{grid}} \in \{4, 5\}$）を打鍵する場合: 上段 1.50, 中段 1.20, 下段 1.40。
  - 小指で外側拡張列（$X_{\text{grid}} < 0$ または $> 9$）を打鍵する場合: 1.40。それ以外: 1.00。
- 複合段・ラテラルペナルティ: $P_{\text{row\_lat}} = P_{\text{row}}[Finger][Row] \times P_{\text{lat}}$

### 4-2. Fitts則の理論的拡張モデル

有効ターゲット縮小モデル（$W_{\text{eff}} = \frac{1}{1 + 0.5 \times D_{3D}}$）を用いた本来のFitts則の形に基づく移動コスト式。

$$C_{\text{move}} = \log_2\left(1 + \frac{D_{3D} \times P_{\text{row\_lat}}}{W_{\text{eff}}}\right) \times W_{\text{strength}}[f] \times 10.0 \times 2.0$$

※親指については極座標系の旋回運動（$30.0 \times \Delta r + 10.0 \times \Delta\theta$）を適用する。

### 4-3. Double Tap (同一キー連続打鍵)

直前と全く同じ物理キーを連続打鍵する場合、移動は発生しないため $C_{\text{move}} = 0$ となる。

---

## 5. 第3階層: Posture (姿勢コスト)

手全体あるいは複数指の相対的な位置関係による緊張や無理な姿勢に対するコスト。動的な器用さを示すウェイト $W_{\text{dynamic}}$ （小指: 2.20, 薬指: 1.80, 中指: 1.20, 人差し・親指: 1.00）を適用する。

### 5-1. Hand Split (動的重心と手の引き裂かれ)

各手の重心（$COM$）を指数移動平均（EMA）で追跡。他の指が重心から大きく離れている場合にペナルティが発生する。

$$P_{\text{hand\_split}} = \max(0, \text{Dist}_{\text{from\_com}} - \text{NeutralDist} - 1.2) \times 7.5 \times W_{\text{dynamic}}$$

- $\text{NeutralDist}$: 人差し指・小指: 2.25, 中指・薬指: 0.75。

### 5-2. 腱の連動 (Tendon Coupling)

隣接する指同士（小薬・薬中）のY座標の差分 $\Delta Y$ が許容値（0.5）を超える場合に非線形ペナルティを加算。

- (小指, 薬指): $\alpha = 15.0, \beta = 2.0$
- (薬指, 中指): $\alpha = 10.0, \beta = 1.0$

$$P_{\text{tendon}} = \alpha \times (\max(0, \Delta Y - 0.5))^\beta$$

### 5-3. 屈曲限界 (Bottom Row Flexion Limit)

中指または薬指が下段を打鍵する際、同一手の人差し指が上段に残っている場合、固定の追加加算値（**+8.0**）を適用する。

---

## 6. 第4階層: Sequence (文脈・配列流れコスト)

### 6-1. ペナルティ項目

- **SFB (Same Finger Bigram)**: 同一指で異なるキーを直後連続打鍵。
  $$C_{\text{sfb}} = (15.0 + 25.0 \times D_{\text{sfb}}^{1.5}) \times W_{\text{dynamic}}$$
- **SFS (Same Finger Skipgram)**: 履歴内の1〜3文字放置同一指連打。減衰係数 $0.5^{\text{diff}-1}$ を適用。
  $$C_{\text{sfs}} = C_{\text{sfb\_equivalent}} \times 0.5^{\text{diff}-1}$$
- **Scissor (シザー Bigram)**: 隣接指による行またぎ。
  $$C_{\text{scissor}} = \Delta Y \times 12.0 \times W_{\text{dynamic}}$$
- **FSS (Full Scissor Skipgram)**: 履歴内の1〜3文字放置シザー。
  $$C_{\text{fss}} = 12.0 \times W_{\text{dynamic}} \times 0.5^{\text{diff}-1}$$
- **RowJump**: 同一手でのホーム段を経由しない直截行またぎ（上段 ↔ 下段）。
  $$C_{\text{rowjump}} = 15.0$$
- **LSS (Lateral Stretch Skipgram)**: 履歴内の横方向引き裂かれストレッチ。
  $$C_{\text{lss}} = \max(0, \text{Dist} - \text{NeutralDist} - 1.2) \times 7.5 \times W_{\text{dynamic}} \times 0.5^{\text{diff}-1}$$
- **Redirect (慣性急ターン)**: 同一手連続3打鍵でのベクトル角度 $\theta$ の急反転（上限15.0）。
  $$C_{\text{redirect}} = \min(15.0, \text{Dist}^2 \times (1 - \cos\theta) \times W_{\text{dynamic}} \times \text{Const})$$

### 6-2. ボーナス・割引項目

- **Roll Move Discount (ロールによる移動軽減)**:
  連続する2打鍵の指番号差がちょうど **`1`** （親指除く）のアルペジオ打鍵時、算出されたロール値を `Move` コストから減算する（上限＝当該ストロークの `Move` コスト）。
  1. **方向判定**:
     - 内向き: 小指(0) $\rightarrow$ 薬指(1) $\rightarrow$ 中指(2) $\rightarrow$ 人差し指(3) $\Rightarrow B_{\text{base}} = \max(0, 15.0 - 2.0 \times \text{Dist})$
     - 外向き: 人差し指(3) $\rightarrow$ 中指(2) $\rightarrow$ 薬指(1) $\rightarrow$ 小指(0) $\Rightarrow B_{\text{base}} = \max(0, 8.0 - 2.0 \times \text{Dist})$
  2. **除外・減衰条件**:
     - 2段またぎロール＝対象外（$0.0$）
     - 人差し指HandSplit発生時＝対象外（$0.0$）
     - 小薬の段違いロール＝対象外（$0.0$）
     - 行跨ぎ / 手切り替え時＝ボーナス値 $\times 0.75$
  3. **コンボ加速**: 3打鍵以上連続ロール時: $B_{\text{final}} = B_{\text{base}} \times 1.2^{\text{Combo}-1} \times 1.5$
  4. **適用方法**: $\text{roll\_discount} = \min(C_{\text{move}}, P_{\text{roll}} + P_{\text{tenodesis}})$。内訳表示には $C_{\text{roll}} = -\text{roll\_discount}$ としてマイナス表記出力する。

- **Shortcut Bonus (合字ボーナス)**: `ligature_penalty_factor = 0.0`。多文字キー（合字）利用による打鍵回数の自動削減を通じ、`BaseOverhead` や移動コストのスキップとして自然な形でスコアに反映される。

---

## 7. 第5階層: Fatigue (疲労蓄積コスト)

疲労蓄積コストは、**同一手の連続稼働疲労（HandFatigue）** および **同一指の集中的・過多使用疲労（FingerFatigue）** の2要素に独立分離して評価・表示する。

1. **同一手の連続打鍵疲労 (HandFatigue)**:
   同一手の連続打鍵回数 $N_{\text{same}}$ ($N_{\text{same}} > 1$) に対するストロークコスト乗数：
   $$\text{Multiplier} = 1.0 + 0.01 \times (N_{\text{same}} - 1)^{1.4}$$
   異手へ遷移した時点で $N_{\text{same}} = 1$ にリセットされる。コスト増分が $C_{\text{hand\_fatigue}}$ に独立計上される。

2. **同一指の集中的使用疲労 (FingerFatigue)**:
   直近の打鍵履歴（**10ストローク以内**）における同指の使用回数 $N_{\text{finger\_burst}}$ に応じた同指酷使ペナルティ：
   $$P_{\text{finger\_fatigue}} = (N_{\text{finger\_burst}})^{1.4} \times 5.0 \times W_{\text{dynamic}}$$
   特定の指（人差し指・中指等）に短期間で負荷が集中的に連用されることを強力にペナルティ化する。$C_{\text{finger\_fatigue}}$ に独立計上される。

---

## 8. 総合スコアおよび15要素の算術関係 (Total Cost & Score Calculation)

タイピングシミュレーション全体で算出される全15項目のコストの算術関係は以下の通り定義される。

$$
\text{Total Cost} = C_{\text{static}} + C_{\text{move}} + C_{\text{hand\_split}} + C_{\text{tendon}} + C_{\text{flexion}} + C_{\text{sfb}} + C_{\text{sfs}} + C_{\text{scissor}} + C_{\text{fss}} + C_{\text{redirect}} + C_{\text{roll}} + C_{\text{rowjump}} + C_{\text{lss}} + C_{\text{hand\_fatigue}} + C_{\text{finger\_fatigue}}
$$

※ $C_{\text{roll}}$ は移動軽減額のため負の値（$-\text{roll\_discount}$）を取り、$C_{\text{move}} + C_{\text{roll}}$ の和が正味の移動負担となる。

最終的な**「総合スコア（Score）」**は、QWERTY配列の総コストを基準値（100.0）として相対的に算出される。

$$
\text{Score} = \left( \frac{\text{QWERTY Total Cost}}{\text{Layout Total Cost}} \right) \times 100
$$
