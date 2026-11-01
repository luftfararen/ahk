# Project Glossary / 用語集 (Domain Terminology & Concepts)

> **Note for AI Agents**:
> This document defines domain terminology, architectural concepts, timing parameters, and naming conventions used across the **Playgrounds** codebase.
> It serves as a dictionary and context reference for code analysis and specification mapping.
> For code implementation and architecture details, refer to [CODE_ANALYSIS.md](CODE_ANALYSIS.md) and [CODE_ANALYSIS_UI.md](CODE_ANALYSIS_UI.md).

---

## 1. Core Architecture & Objects / コア設計とオブジェクト

| Term / Symbol | Japanese (日本語) | Description & Invariants |
| :--- | :--- | :--- |
| `RKey` | リマップキー | すべての物理キーの基底クラス。スキャンコード/文字解決、IME ON/OFF差分出力、CAWパススルーを担当。 |
| `LKey` | 長押し・レイヤーキー | `RKey` を継承し、長押し (Hold)、SandS、同時押し評価、状態機械 (`state`)、世代管理 (`session_id`) を実装。 |
| `st_init` (0) | アイドル / 離鍵状態 | キーが物理的に離され、次の押下待機状態。 |
| `st_pressing` (1) | 押下判定中 | キーが押下され、ホールド判定・同時押し・タップ完了の評価待ち状態。 |
| `st_processed` (2) | 送信・処理済み | すでにアクションや修飾キーが出力され、`Up()` での余分な通常文字送信を抑止する状態。 |
| `InterruptOthers` | 他キーへの割り込み | あるキーが押された際、現在 `st_pressing` にある他のキーを `interrupted := true`, `st_processed` に遷移させる機構。 |
| `CAW Bypass` | 修飾キーパススルー | Ctrl, Alt, Win 押下時にスクリプトのリマップを無効化し、`{Blind}<key>` でOS本来のショートカットを通す機構。 |
| `Physical Shift` | リアルShift | 物理的なキーボードの左右Shiftキー (`LShift` / `RShift`)。 |
| `Space Shift` | スペースシフト (SandS) | Spaceキーを短押しで空白、他キーと併用・長押しでShift修飾として機能させる機構。 |

---

## 2. Hold Modes & Tap-Hold Mechanics / ホールドモード仕様

| Mode | Japanese (日本語) | Behavior Summary |
| :---: | :--- | :--- |
| **0** | 通常キー送信 | 押下時に即座に通常文字を送信（リピート有効）。 |
| **1** | 即時送信・長押し置換 | 押下時に通常文字を送信し、`hold_th` 到達時に Backspace で消去して Shift 文字等に置換。 |
| **2** | 純粋修飾キー | 単体打鍵の出力を抑制し、レイヤー切り替え専用キーとして機能。 |
| **3** | 後判定（離鍵送信）修飾キー | 押下中は修飾キーとして機能。`hold_th` 未満で単打離鍵（かつ割り込みなし）された時のみ通常文字を送信。 |
| **4** | 即時送信・長押し修飾キー化 | 押下時に即時通常文字を送信し、長押し中は後続キーのレイヤー修飾としても機能。 |
| **5** | 離鍵順序判定 (B先行) | 先に離されたキーのアクション、後に離されたキーのアクションを判定。 |
| **6** | 即時判定 | 遊び時間を設けずに即時判定する同時押しモード。 |
| **7** | ロールオーバー防止バッファ付き | `b_time` による猶予時間（Gray Zone）を設けて高速打鍵時の誤判定を防止する同時押しモード。 |
| **8** | 先行Up対応Tap-Hold | `b_time2` を使用し、相殺キーが先に離鍵された場合でも同時押しアクションを成立させるモード。 |
| **9** | プレ送信・長押し置換 | 短押し範囲で相殺キー文字を先行出力し、長押し確定時に Backspace で消去してコードを送信。 |
| **13** | 先行打鍵バッファ付き Mode 3 | `pre_stroke_buf` により、モディファイアよりわずかに早い先行打鍵を救済するセンターモディファイア。 |

---

## 3. Timing Parameters & Layers / タイミングとレイヤー

| Parameter / Index | Japanese (日本語) | Target & Default Value | Description |
| :--- | :--- | :--- | :--- |
| `hold_th` / `HoldTh` | ホールド判定閾値 | `300ms` (通常) / `150ms` (レイヤー) | 短押し（タップ）と長押し（ホールド）を分かつ基準時間。 |
| `b_time` | バッファ時間 | `50ms` | Mode 7 等で同時押し待機判定に設ける遊び時間（ロールオーバー誤判定防止）。 |
| `b_time2` | 第2バッファ時間 | `50ms` | Mode 8 専用の離鍵順序制御バッファ時間。 |
| `pre_stroke_buf` | 先行打鍵バッファ | `30ms` | モディファイア直前の高速打鍵を救済する猶予時間（`0` で無効）。 |
| `layer_id` | レイヤーID | `1`〜`8` (定義済), `9`+ (動的) | 仮想キーレイヤーの識別番号 (`L_NAVI_CTRL`, `L_SYMBOL_NUM`, `L_SELECT` 等)。 |
| `mod_key_id` | 修飾キーID | `M1`〜`M8`, `none` | レイヤーを発動させる修飾キースロット (M1:F13, M2:無変換, M3:変換, M4:F14, M5:F13+Alt/無変換, M6:Tab, M7:Space, M8:変換+F14)。 |

---

## 4. Key Prefixes & String Conventions / 表記規約

| Prefix | Usage / Example | Description |
| :--- | :--- | :--- |
| `R_...` | `R_SPACE := "space"`, `R_CONV := "sc079"` | AHK の `Hotkey()` 関数に渡す生のホットキー名文字列。 |
| `C_...` | `C_SPACE := "{space}"`, `C_BS := "{Backspace}"` | `Send()` 関数に渡す標準的な波括弧付きキー文字列。 |
| `B_...` | `B_ESC := "{Blind}{Esc}"`, `B_BS := "{Blind}{BS}"` | 修飾キー状態を保持したまま送信する `{Blind}` プレフィックス付き文字列。 |
| `P` | `m_s_Pf` | INI設定内の同時押し定義で、論理文字ではなく物理ハードウェアキー位置に束縛する指定。 |

---

## 5. Coding Rules & Invariants / コーディング規約と不変条件

1. **状態機械の遷移契約**:
   - 押下開始は必ず `st_init` $\rightarrow$ `st_pressing`。
   - アクション送信時または他キー割り込み時は `st_processed` へ遷移。
   - 物理離鍵 (`Up`) で必ず `st_init` へ復帰し、`st_processed` の時は単打出力を抑止する。
2. **非同期タイマーと世代管理**:
   - `session_id` を押下ごとに単調増加させ、古いタイマーイベント (`timer_session_id != session_id`) の遅延発火を排除する。
3. **メッセージループ維持**:
   - 長押しやキー状態のポーリング待機ループ内では必ず `Sleep(1)` を呼び出し、AHK のフック処理およびメッセージポンプを滞留させない。
4. **変数初期化と警告抑止**:
   - AutoHotkey v2 の `#Warn` に適合させるため、ループ内や関数内の変数は初期値を明示し、未代入変数を参照しない。
