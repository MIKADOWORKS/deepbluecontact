# Deep Blue Contact - Art Bible

> **Version**: 1.0
> **Date**: 2026-03-28
> **Author**: Art Director
> **Status**: Initial Draft

---

## 1. Visual Concept

### 1.1 Theme Statement

Deep Blue Contact のビジュアルは **National Geographic / BBC ドキュメンタリー** のトーンを基準とする。
知的で静謐、大人の鑑賞に耐える品格。派手なゲーム的演出を排し、深海の暗闇と生命の神秘を「伝える」映像言語を用いる。

### 1.2 Hybrid Approach: Real Photo x Game Graphics

本作のビジュアルの核は **実写写真とゲームグラフィックの共存** にある。

| 要素 | 表現手法 | 備考 |
|------|---------|------|
| 深海生物 | **実写写真のみ** | NOAA / JAMSTEC 素材。聖域ルール -- 絶対にゲームグラフィック化しない |
| 探査艇・母船 | PixelLab 生成グラフィック | lineless / detailed shading / side view |
| 装備アイコン | PixelLab 生成グラフィック | lineless / detailed shading / side view |
| 海底オブジェクト | PixelLab 生成グラフィック | lineless / detailed shading / side view |
| UI | Godot テーマシステム | コードベース定義、NatGeo 風シャープデザイン |
| 背景タイル | PixelLab 生成テクスチャ | 深度帯別グラデーション |

### 1.3 Tone Guide

- **DO**: 静謐、知的、ドキュメンタリー的、余白を活かす、暗色基調
- **DON'T**: カラフル、ポップ、ファンシー、派手なエフェクト、過剰なパーティクル

---

## 2. Color Palette

### 2.1 Core Colors

| 名称 | Hex | 用途 |
|------|-----|------|
| **Primary (Deep Navy)** | `#0a1628` | 背景の基本色、Panel の bg_color |
| **Secondary (Dark Navy)** | `#1a2a3f` | ボタン背景、ProgressBar 背景、補助パネル |
| **Accent (Gold)** | `#c8a84e` | 強調要素、ボーダー、ProgressBar fill、重要テキスト |
| **Text Primary (Off-White)** | `#e8e4dc` | 本文テキスト、ボタンラベル |
| **Text Disabled** | `#606060` | 無効化テキスト |
| **Border Subtle** | `#404040` | ロック状態のボーダー |

### 2.2 UI State Colors (Button)

| 状態 | bg_color | border_color | font_color |
|------|----------|-------------|------------|
| Normal | `#1a2a3f80` | `#c8a84e40` | `#e8e4dc` |
| Hover | `#2a3a5080` | `#c8a84e80` | `#c8a84e` |
| Pressed | `#c8a84e30` | `#c8a84e` | `#c8a84e` |
| Disabled | `#0a0a0a40` | `#40404040` | `#606060` |

### 2.3 DIVE Button (Primary Action)

アクション性の高い DIVE ボタンは特別なスタイルを持つ。

| 状態 | bg_color | border_color | font_color |
|------|----------|-------------|------------|
| Normal | `#c8a84e20` | `#c8a84e` | `#c8a84e` |
| Hover | `#c8a84e40` | `#c8a84e` | `#e8e4dc` |
| Pressed | `#c8a84e60` | `#c8a84e` | -- |

Font size: 20px (通常ボタンより大きい)

### 2.4 Panel Style

| プロパティ | 値 |
|-----------|-----|
| bg_color | `#0a162880` (半透明) |
| border_color | `#c8a84e20` (極薄ゴールド) |
| border_width | 1px (全辺) |
| corner_radius | 2px (全角) |

### 2.5 Depth Zone Colors

深度が深まるにつれ、色は暗く沈んでいく。DataRegistry で定義された正式値。

| 海層 | ID | Hex | 深度 |
|------|-----|-----|------|
| 中深層 (Mesopelagic) | `mesopelagic` | `#1a3a5c` | 200-1,000m |
| 漸深層 (Bathypelagic) | `bathypelagic` | `#0f2847` | 1,000-3,000m |
| 深海層 (Abyssopelagic) | `abyssopelagic` | `#081a33` | 3,000-6,000m |
| 超深海層 (Hadal) | `hadal` | `#040d1a` | 6,000m+ |

メイン画面の OceanPanel では、各ゾーンパネルにこの色をアルファ 0.6 で適用し、ゴールドボーダー `#c8a84e30` を付与する（アンロック時）。ロック状態は `rgba(0.1, 0.1, 0.12, 0.5)` + ボーダー `#40404030`。

### 2.6 Observation Mode Gradient

観察モードの背景は進行度（0.0 ~ 1.0）に応じて線形補間する。

| ポイント | RGB | 近似 Hex | 備考 |
|----------|-----|----------|------|
| Surface (progress=0.0) | `(0.055, 0.11, 0.22)` | `#0e1c38` | 暗い紺 |
| Deep (progress=1.0) | `(0.015, 0.025, 0.055)` | `#04070e` | ほぼ漆黒 |

---

## 3. Asset Style Guide

### 3.1 PixelLab Generation Parameters (Unified)

全ての PixelLab 生成アセットに適用する統一設定。

| Parameter | Value | 備考 |
|-----------|-------|------|
| **outline** | `lineless` | 輪郭線なし -- NatGeo 風のクリーンな見た目 |
| **shading** | `detailed shading` | リッチな陰影で大人向けの質感 |
| **detail** | `high detail` | 精細なディテール |
| **view** | `side` | 探査艇、母船、海底オブジェクト全て横視点 |

**旧スタイルからの変更点**:
- ~~single color black outline~~ → `lineless`
- ~~basic shading~~ → `detailed shading`
- ~~medium detail~~ → `high detail`

### 3.2 Submersibles (探査艇)

**現在のアセット**: Nereid-1 (4方向 + breathing-idle animation), Nereid-2 (4方向)

| 項目 | 仕様 |
|------|------|
| Canvas size | 48px (PixelLab 基本) |
| Directions | 4方向 (south, west, north, east) |
| Display scale | 観察モードで texture_filter: NEAREST |
| View | side |
| Character type | humanoid (PixelLab template) |

**現状の観察**:
- Nereid-1: 白/グレー基調の潜水艇シルエット。上面から見た縦長フォルム。breathing-idle アニメーション (4 frames x 4方向) 実装済み
- Nereid-2: 暗色（紺/黒）のより重厚なデザイン。ヘルメット型の丸みがある

**方針**: 探査艇は深海の暗い背景に対してシルエットが識別できる明度差を確保する。Nereid-1 のような明色系と Nereid-2 のような暗色系の両方をラインナップに含め、プレイヤーの視認性に配慮する。

### 3.3 Mothership (母船)

**現在のアセット**: `mothership/mothership.png`

| 項目 | 仕様 |
|------|------|
| View | side |
| Style | 横から見た調査船。白い船体、クレーン、アンテナなど科学調査船のディテール |
| 用途 | タイトル画面のシルエット、メイン画面の上部表示 |

**方針**: 実在の海洋調査船（しんかい6500の母船「よこすか」等）を参考にしたリアリスティックなプロポーション。ドキュメンタリー的な説得力を重視。

### 3.4 Equipment Icons (装備アイコン)

**現在のアセット**: 4カテゴリ x 2段階 = 8種

| カテゴリ | Tier 1 | Tier 2 | 見た目の特徴 |
|---------|--------|--------|-------------|
| Searchlight | `searchlight_1.png` | `searchlight_2.png` | 黄色い発光リング。Tier 2 は装飾が増加 |
| Camera | `camera_1.png` | `camera_2.png` | 暗色の箱型カメラ。Tier 2 はディスプレイ追加 |
| Sensor | `sensor_1.png` | `sensor_2.png` | 暗い球体/集合体。Tier 2 は複合センサー |
| Propulsion | `propulsion_1.png` | `propulsion_2.png` | オレンジ/赤の推進装置。Tier 2 はツイン化 |

| 項目 | 仕様 |
|------|------|
| Canvas size | 32px |
| View | side |
| 背景 | 透明 |
| ティア表現 | Tier が上がるとディテールが増え、複合的な構造になる |

**方針**: 各ティアで明確なビジュアル差をつける。色味はカテゴリごとに固定し、一目でカテゴリが判別できるようにする（Searchlight=黄, Camera=暗灰, Sensor=青系, Propulsion=赤/橙系）。

### 3.5 Background Objects (海底オブジェクト)

**現在のアセット**: 6種

| オブジェクト | ファイル | 出現深度帯 | 見た目 |
|------------|---------|-----------|--------|
| Jellyfish | `jellyfish.png` | 中深層, 漸深層 | 青い透明なクラゲ群。発光感のあるブルー |
| Shipwreck | `shipwreck.png` | 漸深層 | 暗いティール色の沈没船。木造帆船風 |
| Hydrothermal Vent | `hydrothermal_vent.png` | 深海層, 超深海層 | オレンジ〜赤の噴出。黒煙柱 |
| Rocky Cliff | `rocky_cliff.png` | 深海層 | 暗い紺色の岩山。シンプルな丸みのあるシルエット |
| Tubeworms | `tubeworms.png` | 深海層, 超深海層 | ピンク〜赤のチューブワーム群。生命感のある暖色 |
| Whale Skeleton | `whale_skeleton.png` | 超深海層 | 灰色〜青灰のクジラ骨格。骨のディテール |

**表示仕様** (observation_screen.gd より):
- 表示スケール: テクスチャサイズ x 2.5
- テクスチャフィルタ: `TEXTURE_FILTER_NEAREST`
- 透過度: `modulate.a = 0.5 ~ 0.7` (ランダム)
- Z-index: -1 (探査艇の背後)
- 移動: 右端 (x=1300) から左端 (x=-300) へ 12〜25秒かけてスクロール
- 出現間隔: 8〜20秒のランダム間隔

**方針**: 背景オブジェクトは「観察モードの深海の雰囲気を構成する環境要素」であり、主役ではない。半透明で奥行き感を出し、探査艇やイベントの邪魔をしない。深度帯が深くなるほど、生物由来のオブジェクト（骨格、チューブワーム）や地質学的オブジェクト（熱水噴出孔）が増える。

### 3.6 Depth Tiles (深度帯タイル)

**現在のアセット**: 4種 (各深度帯 1 枚)

| 深度帯 | ファイル | 見た目 |
|--------|---------|--------|
| Mesopelagic | `mesopelagic.png` | やや明るい紺。海水のうねりテクスチャ |
| Bathypelagic | `bathypelagic.png` | 暗い紺。テクスチャはより抑制的 |
| Abyssopelagic | `abyssopelagic.png` | 非常に暗い紺〜黒。微かなテクスチャ |
| Hadal | `hadal.png` | ほぼ漆黒。テクスチャはほとんど見えない |

**方針**: メイン画面の海の断面図（OceanPanel）で使用。深度が深くなるほど暗く、光が届かない海の現実を表現する。

### 3.7 Texture Filter Rule

全てのピクセルアートアセットは Godot 上で **`TEXTURE_FILTER_NEAREST`** を適用する。バイリニア補間によるボケを防ぎ、ピクセルのシャープさを維持する。

---

## 4. Typography

### 4.1 Font Size Hierarchy

| レベル | サイズ | 用途 |
|--------|-------|------|
| Display | 28-32px | タイトル画面のゲームタイトル |
| Action | 20px | DIVE ボタンなど主要アクション |
| Body | 16px | 一般テキスト、Label、Button (デフォルト) |
| Caption | 12-14px | 補助情報、深度表示、タイマー |

### 4.2 Font Color Usage

| 色 | Hex | 用途 |
|----|-----|------|
| Gold | `#c8a84e` | 重要情報、アクション誘導、hover 状態、DIVE ボタン |
| Off-White | `#e8e4dc` | 通常テキスト（Label, Button のデフォルト） |
| Dim White | `#a0a0a0` | 補助テキスト、セカンダリ情報 |
| Disabled | `#606060` | 無効化状態のテキスト |

### 4.3 Font Style

- **推奨**: クリーンなサンセリフ体（ドキュメンタリー的品格）
- Godot デフォルトフォントを暫定使用。将来的に Noto Sans 等の多言語対応フォントに差し替え予定
- ピクセルフォントは **使用しない**（旧スタイルからの変更）

---

## 5. UI Design Principles

### 5.1 Panel Design

```
bg_color:     #0a162880  (Primary + 50% alpha)
border_color: #c8a84e20  (Gold + 12.5% alpha)
border_width: 1px
corner_radius: 2px
```

パネルは「暗い半透明 + 極薄ゴールド枠」で統一する。背景の深海が透けて見えることで没入感を維持しつつ、情報領域を区切る。

### 5.2 Button Design

- **角丸**: 2px（シャープ。丸すぎるとカジュアルになる）
- **内部マージン**: left/right 20px, top/bottom 10px
- **Hover**: ゴールドボーダーが濃くなり、テキストがゴールドに変化
- **Pressed**: 背景にゴールドが滲む
- **Primary Action (DIVE)**: 独自スタイル -- ゴールド枠線を常時表示、テキストもゴールド

### 5.3 ProgressBar Design

```
Background: #1a2a3f (Secondary)
Fill:       #c8a84e (Gold)
corner_radius: 1px
```

### 5.4 Layout Principles

- **情報密度**: 低めに保つ。余白は「深海の静けさ」を表現する要素
- **左右分割**: メイン画面は 海の断面図（左）+ 情報パネル（右）の 2 カラム
- **縦構造**: 海の断面図は上（海面）から下（超深海）へ -- Tiny Tower の反転
- **アンロック表現**: ロック状態は暗色 + 薄いボーダーで「まだ見ぬ領域」を示唆

---

## 6. Screen-by-Screen Visual Guide

### 6.1 Title Screen

| 要素 | 仕様 |
|------|------|
| 背景 | 暗い深海色 (`#0a1628`) のグラデーション |
| タイトル | ゴールド (`#c8a84e`)、Display サイズ (28-32px) |
| サブタイトル | Off-White (`#e8e4dc`)、Body サイズ |
| 母船 | 上部にシルエット配置（将来実装） |
| ボタン | 標準ボタンスタイル、中央配置 |
| 演出 | 静かなマリンスノーパーティクル（オプション） |

### 6.2 Main Screen

| 要素 | 仕様 |
|------|------|
| 左側: OceanPanel | 4 つの深度帯パネルを縦に並べた海の断面図。各パネルは `zone.color` + alpha 0.6 |
| 右側: InfoPanel | プレイヤーステータス、探査状態、ボタン群 |
| DIVE ボタン | ゴールド枠のプライマリアクション。最も目立つ要素 |
| 深度帯ボーダー | アンロック時: `#c8a84e30` / ロック時: `#40404030` |

### 6.3 Preparation Screen

| 要素 | 仕様 |
|------|------|
| 深度選択 | 4 階層をリスト表示。アンロック状態に応じたスタイル |
| 探査艇選択 | 探査艇スプライト + ステータス表示 |
| 装備選択 | 4 カテゴリのアイコングリッド |
| 出発ボタン | DIVE ボタンと同じゴールドプライマリスタイル |

### 6.4 Observation Screen

| 要素 | 仕様 |
|------|------|
| 背景 | `_color_surface` → `_color_deep` の線形補間グラデーション |
| 探査艇 | 中央水平、進行度に応じて上から下へ移動 |
| 深度ゲージ | 左側に深度表示 + ProgressBar |
| タイマー | HUD 上部 |
| Speed toggle | `x2 ON/OFF` ボタン |
| 背景オブジェクト | 右から左へスクロール。半透明 (0.5-0.7)、z-index: -1 |
| マリンスノー | (将来実装) 白い微粒子が上からゆっくり降下 |

### 6.5 Result Screen

| 要素 | 仕様 |
|------|------|
| 生物カード | 実写写真 + 名前 + サイズ情報 |
| NEW バッジ | ゴールド (`#c8a84e`) の目立つバッジ |
| XP 獲得表示 | ゴールドテキスト |
| 図鑑登録通知 | 発見報告のリスト形式 |

### 6.6 Encyclopedia Screen

| 要素 | 仕様 |
|------|------|
| レイアウト | グリッド表示 |
| 発見済み | 実写サムネイル + 名前 |
| 未発見 | 暗色パネル + `?` マーク |
| 詳細表示 | 実写写真大 + 豆知識テキスト（2 段階登録制） |

---

## 7. Real Photo (Deep-Sea Creatures) Guidelines

### 7.1 Source & License

| ソース | ライセンス | 用途 |
|--------|-----------|------|
| NOAA Ocean Exploration | パブリックドメイン（クレジット表記のみ） | メイン素材 |
| JAMSTEC J-EDI | 学術・教育目的は無償、商用は要申請 | 補完素材 |

### 7.2 Photo Selection Criteria

- **解像度**: 最低 512x512px 以上（図鑑での大表示に耐えるため）
- **背景**: 暗い背景のものを優先（深海撮影は自然に暗い）
- **構図**: 生物の全体像が分かるもの。部分アップよりも全身を優先
- **品質**: ピンボケ、ノイズ過多のものは除外
- **色調**: 自然な色味を維持。過度な色補正は行わない

### 7.3 Photo Processing Rules

| 処理 | 許可 | 備考 |
|------|------|------|
| トリミング | OK | 生物を中心にクロップ |
| 背景除去 | OK (慎重に) | 図鑑カード用に背景を透過にする場合 |
| 明度/コントラスト微調整 | OK | UI の暗い背景に馴染ませるための最小限の調整 |
| 色調変更 | NG | 自然な色を改変しない |
| 合成・加工 | NG | ドキュメンタリーの信頼性を損なう |
| AI 加工・生成 | NG | 聖域ルール違反 |

### 7.4 Photo Display Context

- **図鑑**: 暗色パネル内に配置。写真の周囲に十分な余白を確保
- **リザルト画面**: カード形式で表示。ゴールドボーダーの枠内
- **観察モード中の出現**: 将来的にテクスチャとして表示する場合も、加工は最小限にとどめる

---

## 8. Observation Mode Visual Direction

### 8.1 Background Color Progression

進行度に基づく背景色の連続的な変化が、潜行の臨場感を生む。

```
Progress 0.0 (海面付近)  : rgb(0.055, 0.11, 0.22)  -- 暗い紺
Progress 0.25            : 上記の中間補間
Progress 0.5             : 上記の中間補間
Progress 0.75            : 上記の中間補間
Progress 1.0 (最深部)    : rgb(0.015, 0.025, 0.055) -- ほぼ漆黒
```

### 8.2 Marine Snow Particles (Design Spec)

現在未実装。以下の仕様で将来実装予定。

| パラメータ | 中深層 | 漸深層 | 深海層 | 超深海層 |
|-----------|--------|--------|--------|---------|
| 密度 (個/秒) | 3-5 | 5-8 | 2-4 | 1-2 |
| サイズ (px) | 1-2 | 1-3 | 1-2 | 1 |
| 落下速度 (px/s) | 15-30 | 10-25 | 8-20 | 5-15 |
| 色 | `#ffffff20` | `#ffffff18` | `#ffffff10` | `#ffffff08` |
| 横揺れ | 微量 | 微量 | ほぼなし | なし |

方針: マリンスノーは現実の深海で常に存在する。浅いほど密度が高く、深いほど少なくなる。色も深度に応じて暗くなり、最深部ではほとんど見えない程度にする。

### 8.3 Background Object Spawn Rules

現在の実装 (observation_screen.gd) に基づく。

| 深度帯 | 出現オブジェクト |
|--------|----------------|
| 中深層 | Jellyfish |
| 漸深層 | Shipwreck, Jellyfish |
| 深海層 | Hydrothermal Vent, Rocky Cliff, Tubeworms |
| 超深海層 | Whale Skeleton, Hydrothermal Vent, Tubeworms |

- 出現間隔: 8-20 秒 (ランダム)
- 方向: 右端から左端へ水平スクロール (12-25 秒)
- 透過度: 0.5-0.7 (背景要素として主張しすぎない)

**深度帯別の演出方針**:
- **中深層**: 浮遊する生物（クラゲ）中心。まだ光がある世界
- **漸深層**: 人工物（沈没船）も登場。暗さが増す
- **深海層**: 地質学的構造（熱水噴出孔、岩壁）と生態系（チューブワーム）
- **超深海層**: 死と生が交差する世界（クジラの骨格 + 熱水噴出孔 + チューブワーム）

### 8.4 Bioluminescence (生物発光) Design Spec

現在未実装。将来的な演出方針。

- 深度が深くなるほど、背景に微かな発光点を散りばめる
- 色: 青緑 (`#00ffcc10` ~ `#00ffcc30`)、一部の生物は赤 (`#ff440010`)
- 明滅: ゆっくりとした明滅 (2-5 秒周期)
- 密度: 深海層以降で徐々に増加
- 方針: あくまで環境演出。過剰にせず、暗闇の中の「かすかな命の兆し」に留める

---

## 9. Asset Naming Convention

### 9.1 Directory Structure

```
godot/assets/
  submersibles/
    {submersible_id}/
      rotations/
        south.png, west.png, north.png, east.png
      animations/
        {animation_name}/
          {direction}/
            frame_000.png, frame_001.png, ...
  mothership/
    mothership.png
  equipment/
    {category}_{tier}.png
  objects/
    {object_name}.png
  tiles/
    {depth_zone_id}.png
  creatures/          (将来: 実写写真)
    {creature_id}.png
```

### 9.2 Naming Rules

- 全て **snake_case**、英語
- 探査艇: `nereid_1`, `nereid_2`, ...
- 装備: `{category}_{tier}` (例: `searchlight_1`, `camera_2`)
- オブジェクト: 英語名そのまま (例: `hydrothermal_vent`, `whale_skeleton`)
- フレーム: `frame_000.png` からゼロ埋め 3 桁

---

## 10. PixelLab Generation Checklist

新規アセット生成時のチェックリスト。

```
[ ] outline: lineless
[ ] shading: detailed shading
[ ] detail: high detail
[ ] view: side
[ ] サイズ: 探査艇 48px / 装備 32px / オブジェクト 48-64px / 母船 128px
[ ] 生成結果を get_character / get_tiles_pro 等で確認
[ ] 既存アセットとのトーン・色味の整合性チェック
[ ] ディレクターへサンプル提示（大量生成前）
[ ] ファイル命名規則に準拠
[ ] texture_filter: NEAREST の確認
```

---

## Appendix: Color Reference (Quick Access)

```
PRIMARY:      #0a1628
SECONDARY:    #1a2a3f
ACCENT/GOLD:  #c8a84e
TEXT:          #e8e4dc
TEXT_DIM:      #a0a0a0
TEXT_DISABLED: #606060
BORDER_LOCK:  #404040

ZONE_MESO:    #1a3a5c
ZONE_BATHY:   #0f2847
ZONE_ABYSSO:  #081a33
ZONE_HADAL:   #040d1a

OBS_SURFACE:  rgb(0.055, 0.11, 0.22)
OBS_DEEP:     rgb(0.015, 0.025, 0.055)
```
