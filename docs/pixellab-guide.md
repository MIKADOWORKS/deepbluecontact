# PixelLab MCP — ゲームアセット生成ガイド

> **対象読者**: Claude Code を使って Godot / Unity 等のゲームを開発するプロジェクト
> **前提**: Claude Code に PixelLab MCP が設定済みであること
> **作成**: MIKADO WORKS — Deep Blue Contact プロジェクトの実践知見より

---

## 1. PixelLab MCP とは

Claude Code のツールとして呼び出せる **AI ピクセルアート生成サービス**。
テキスト説明からキャラクター・タイル・マップオブジェクトを自動生成する。

### できること

| カテゴリ | ツール | 生成物 |
|---------|-------|--------|
| キャラクター | `create_character` | 4/8 方向スプライト + アニメーション |
| マップオブジェクト | `create_map_object` | 背景・建物・小道具（透過PNG） |
| タイル (Pro) | `create_tiles_pro` | 地形タイル複数枚を一括 |
| 等角タイル | `create_isometric_tile` | アイソメトリック視点タイル |

### 料金体系（クレジット）

| 操作 | コスト |
|------|--------|
| `create_character` (standard, 4方向) | 1 クレジット |
| `create_character` (standard, 8方向) | 1 クレジット |
| `create_character` (pro モード) | 20〜40 クレジット |
| `animate_character` (テンプレート) | 1 クレジット/方向 |
| `animate_character` (カスタム) | 20〜40 クレジット/方向 ⚠️ 要確認 |
| `create_map_object` | 1 クレジット前後 |
| `create_tiles_pro` | タイル数に依存 |

> ⚠️ **カスタムアニメーション** は高コスト。必ずユーザーに金額を提示し、明示的な承認を得てから `confirm_cost: true` で実行すること。

---

## 2. 非同期ワークフロー（重要）

PixelLab の生成は **非同期**。呼び出したら即座に Job ID / Asset ID が返り、実際の生成には時間がかかる。

```
create_character()         ← ジョブ投入（即返却）
      ↓ 2〜5分後
get_character(id)          ← 完了確認 + URL 取得
      ↓
ダウンロード（curl / wget）
```

### ポーリングの目安

| ツール | 待ち時間目安 |
|--------|------------|
| `create_character` (4方向) | 2〜3分 |
| `create_character` (8方向) | 3〜5分 |
| `create_tiles_pro` | 15〜30秒 |
| `create_map_object` | 15〜30秒 |
| `animate_character` | 2〜4分 |

**レートリミット**に達した場合は数分待ってから再試行する。

---

## 3. ツール別リファレンス

### 3.1 `create_character` — キャラクタースプライト

探査艇・プレイヤー・NPC・乗り物などに使用。

#### 主要パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|---------|------|
| `description` | string | 必須 | キャラクターの外見説明（英語推奨） |
| `size` | int | 48 | キャンバスサイズ (px)。16〜128 |
| `n_directions` | 4 or 8 | 8 | 生成方向数 |
| `view` | enum | `low top-down` | カメラ角度。`side` / `low top-down` / `high top-down` |
| `outline` | enum | `single color black outline` | 輪郭スタイル |
| `shading` | enum | `basic shading` | 陰影の複雑さ |
| `detail` | enum | `medium detail` | ディテール量 |
| `body_type` | enum | `humanoid` | `humanoid` / `quadruped` |
| `mode` | enum | `standard` | `standard`（安価）/ `pro`（高品質・高コスト） |

#### `outline` オプション比較

| 値 | 見た目 | 適したゲームスタイル |
|----|--------|-------------------|
| `single color black outline` | 黒の太枠線 | 古典ドット絵、アケゲー |
| `single color outline` | 単色の枠線 | 柔らかめドット絵 |
| `selective outline` | 必要な部分だけ輪郭 | モダンドット絵 |
| `lineless` | 輪郭線なし | NatGeo風・写実的・大人向け |

#### `shading` オプション比較

| 値 | 見た目 |
|----|--------|
| `flat shading` | ベタ塗り。影なし |
| `basic shading` | 簡単な影付き |
| `medium shading` | 中程度の立体感 |
| `detailed shading` | リッチな光源・グラデーション |

#### `view` の使い分け

```
side          → 横スクロール / サイドビュー
low top-down  → RPG / ストラテジー（やや斜め上から）
high top-down → ダンジョン系（真上近く）
```

#### 実践例：横向きの研究船

```
description: "oceanographic research vessel, white hull, crane on deck,
              satellite antenna, scientific survey ship, side view,
              detailed equipment visible"
size: 128
n_directions: 4
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

#### 実践例：深海探査艇

```
description: "deep sea submersible, white and gray hull, viewport window,
              robotic arm, thruster pods, underwater research vehicle"
size: 64
n_directions: 4
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

---

### 3.2 `animate_character` — アニメーション追加

`create_character` で生成したキャラクターに動きをつける。

#### テンプレートアニメーション一覧（humanoid）

主要なものを抜粋:

| ID | 動き |
|----|------|
| `breathing-idle` | 待機・呼吸 |
| `walk` / `walking` | 歩行 |
| `running-4-frames` | 走行（4フレーム） |
| `jumping-1` | ジャンプ |
| `picking-up` | 拾い上げ |
| `pushing` | 押す |

> テンプレートアニメーションは **1 クレジット/方向** と安価。まずテンプレートで対応できないか検討すること。

#### カスタムアニメーション（高コスト）

テンプレートにない動きは `action_description` で指定できるが、**方向ごとに 20〜40 クレジット**かかる。

```
⚠️ 必須手順:
1. confirm_cost: false で呼び出してコストを確認
2. ユーザーにコストを提示
3. 明示的承認を得てから confirm_cost: true で再実行
```

---

### 3.3 `create_map_object` — 背景・オブジェクト

地形オブジェクト・家具・小道具・エフェクトなど、透過PNGで生成。

#### 主要パラメータ

| パラメータ | 説明 |
|-----------|------|
| `description` | オブジェクトの説明 |
| `width` / `height` | キャンバスサイズ (32〜400px) |
| `view` | カメラ角度（`side` / `low top-down` / `high top-down`） |
| `outline` | 輪郭スタイル（`single color outline` / `selective outline` / `lineless`） |
| `shading` | 陰影の複雑さ |
| `background_image` | スタイル参照画像（既存タイルに合わせる時） |

#### 実践例：深海クラゲ

```
description: "bioluminescent jellyfish, translucent blue-white body,
              long tentacles flowing, glowing in dark deep sea,
              side view"
width: 64
height: 96
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

#### 実践例：熱水噴出孔

```
description: "hydrothermal vent, black smoker chimney, dark minerals,
              superheated water rising, deep sea floor environment,
              side view"
width: 64
height: 96
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

#### `background_image` でスタイル統一

既存アセットとトーンを合わせたい場合:

```json
{
  "type": "path",
  "path": "godot/assets/tiles/mesopelagic.png"
}
```

> `path` 形式を使うと curl コマンドが返ってくるので、それを実行してアップロードする。`base64` 形式より大幅にトークン節約できる。

---

### 3.4 `create_tiles_pro` — タイル一括生成

地形・床・壁タイルをまとめて生成。

#### 主要パラメータ

| パラメータ | デフォルト | 説明 |
|-----------|---------|------|
| `description` | 必須 | タイル説明。番号付きで各タイルを指定 |
| `n_tiles` | 自動 | 生成枚数 (1〜16) |
| `tile_type` | `isometric` | タイル形状 |
| `tile_size` | 32 | サイズ (16〜128px) |
| `tile_view` | `low top-down` | 視点 |
| `outline_mode` | `outline` | `outline` / `segmentation`（クリーンなタイルに） |

#### `tile_type` の選択

| 値 | 形状 | 用途 |
|----|------|------|
| `square_topdown` | 正方形 | RPG・ダンジョン・横スクロール背景 |
| `isometric` | ひし形 | アイソメゲーム |
| `hex` | 六角形（flat-top） | ストラテジー |
| `hex_pointy` | 六角形（pointy-top） | ストラテジー |

#### 実践例：深度帯タイル4種を一括生成

```
description: "1). mesopelagic ocean water, soft blue, light rays penetrating
              2). bathypelagic deep sea, darker blue, no light
              3). abyssopelagic abyss, very dark navy, pressure
              4). hadal ultradeep, almost black, crushing darkness"
n_tiles: 4
tile_type: "square_topdown"
tile_size: 64
tile_view: "side"
outline_mode: "segmentation"
```

---

## 4. Godot への組み込み手順

### 4.1 ダウンロード

`get_character` / `get_tiles_pro` 等で返ってくる ZIP または画像 URL を取得し、curl でダウンロード:

```bash
curl -L "https://..." -o godot/assets/submersibles/nereid_1.zip
cd godot/assets/submersibles/ && unzip nereid_1.zip -d nereid_1/
```

### 4.2 ディレクトリ構成（推奨）

```
godot/assets/
  submersibles/
    {id}/
      rotations/
        south.png, west.png, north.png, east.png
      animations/
        {anim_name}/
          {direction}/
            frame_000.png, frame_001.png, ...
  mothership/
    mothership.png
  equipment/
    {category}_{tier}.png       # searchlight_1.png, camera_2.png ...
  objects/
    {object_name}.png           # jellyfish.png, shipwreck.png ...
  tiles/
    {depth_zone_id}.png         # mesopelagic.png, hadal.png ...
```

### 4.3 テクスチャフィルター設定

**ピクセルアートは必ず Nearest フィルター** を設定しないとボケる。

`.tscn` ファイルでの設定:
```
texture_filter = 0   # TEXTURE_FILTER_NEAREST
```

GDScript での動的設定:
```gdscript
sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
```

`project.godot` でプロジェクト全体に適用:
```
[rendering]
textures/canvas_textures/default_texture_filter=0
```

---

## 5. スタイルガイド早見表

プロジェクトのビジュアル方針に合わせて設定を選ぶ。

### パターン A: クラシックドット絵（レトロ風）

```
outline:  "single color black outline"
shading:  "flat shading" or "basic shading"
detail:   "medium detail"
view:     "low top-down" (RPG) / "side" (横スクロール)
```

### パターン B: モダンドット絵（インディーゲーム風）

```
outline:  "selective outline"
shading:  "medium shading"
detail:   "high detail"
view:     用途に応じて
```

### パターン C: NatGeo / 写実的・大人向け（Deep Blue Contact スタイル）

```
outline:  "lineless"
shading:  "detailed shading"
detail:   "high detail"
view:     "side"
```

### パターン D: ミニマル・チビキャラ

```
outline:  "single color black outline"
shading:  "flat shading"
detail:   "low detail"
proportions: '{"type": "preset", "name": "chibi"}'
```

---

## 6. ベストプラクティス

### ✅ DO

- **英語でプロンプトを書く** — 精度が上がる
- **視点を明示する** — "side view" "from the front" など
- **色・素材を具体的に** — "dark navy blue hull with orange thrusters"
- **用途を含める** — "game sprite" "2D pixel art character"
- **複数タイルはまとめて** — `create_tiles_pro` で `n_tiles: 4` など一括生成
- **既存アセットと合わせる** — `background_image` でスタイル統一
- **安いテンプレートアニメを先に試す** — `breathing-idle`, `walk` 等

### ❌ DON'T

- **カスタムアニメを無断実行しない** — 高コスト（20〜40 クレジット/方向）
- **`pro` モードを気軽に使わない** — 20〜40 クレジット消費
- **ポーリングを短すぎる間隔で連打しない** — レートリミットに当たる
- **生成直後に `get_*` を呼ばない** — 2〜5分待つ
- **聖域ルールを破らない** — プロジェクト固有の絶対仕様は守ること

### 📝 プロンプト例：表現の精度を上げるコツ

```
# NG: 曖昧
"a submarine"

# OK: 具体的
"deep sea research submersible, white and gray hull, circular viewport window,
 two robotic arms, four blue thruster pods, side view, metal texture"

# NG: 矛盾するスタイル
outline: "single color black outline" + shading: "detailed shading"

# OK: スタイルを統一
outline: "lineless" + shading: "detailed shading"  # 写実系
outline: "single color black outline" + shading: "flat shading"  # ドット絵系
```

---

## 7. トラブルシューティング

| 症状 | 原因 | 対処 |
|------|------|------|
| `get_*` を呼んでも `pending` | まだ生成中 | 2〜5分待ってから再試行 |
| レートリミットエラー | 短時間に多くのリクエスト | 3〜5分待って再試行 |
| 画像がボケる | texture_filter 未設定 | `TEXTURE_FILTER_NEAREST` を適用 |
| スタイルがバラバラ | パラメータが一貫していない | スタイルガイドを参照して統一 |
| ZIP を展開したら空 | ダウンロード失敗 | URL を再取得して再ダウンロード |
| `confirm_cost` なしで高コスト | カスタムアニメを誤実行 | 常に `confirm_cost: false` で確認してから |
| キャラクターが小さすぎる | `size` が小さい | `size: 64` 〜 `128` に上げる |

---

## 8. Deep Blue Contact での実績

本プロジェクトで実際に生成したアセット一覧と使用パラメータ。

### 探査艇 Nereid-1（4方向 + breathing-idle アニメ）

```
description: "deep sea submersible, white and light gray hull,
              circular viewport, robotic arm, thruster pods,
              underwater research vehicle, clean design"
size: 64
n_directions: 4
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

### 母船 Mothership

```
description: "oceanographic research vessel, white hull, blue stripe,
              crane and winch on deck, satellite dish, scientific
              survey ship, side view, realistic proportions"
size: 128  (実際は create_map_object で width:192, height:96 を使用)
view: "side"
outline: "lineless"
shading: "detailed shading"
detail: "high detail"
```

### 深度帯タイル4種

```
description: "1). mesopelagic ocean water 200-1000m, soft blue, light rays
              2). bathypelagic deep sea 1000-3000m, darker blue navy
              3). abyssopelagic abyss 3000-6000m, very dark navy
              4). hadal ultradeep 6000m+, near black"
n_tiles: 4
tile_type: "square_topdown"
tile_size: 64
view: "side"
```

### 装備アイコン8種（4カテゴリ × Tier1/2）

```
# Searchlight Tier 1
description: "underwater searchlight, yellow beam, metal housing,
              mounted equipment, single lens, side view"
width: 32, height: 32
view: "side"
outline: "lineless"
shading: "detailed shading"
```

---

## Appendix: MCP 設定方法

### `~/.claude/settings.json` への追加

```json
{
  "mcpServers": {
    "pixellab": {
      "command": "npx",
      "args": ["-y", "@pixellab/mcp-server"],
      "env": {
        "PIXELLAB_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

### API キーの取得

1. [pixellab.ai](https://pixellab.ai) でアカウント作成
2. Dashboard → API Keys → Create Key
3. サブスクリプション契約（クレジット付与）

---

*作成: MIKADO WORKS / Deep Blue Contact プロジェクト*
*最終更新: 2026-03-29*
