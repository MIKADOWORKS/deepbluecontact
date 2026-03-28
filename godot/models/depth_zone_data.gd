class_name DepthZoneData
extends Resource

@export var id: String = ""
@export var name_en: String = ""
@export var name_jp: String = ""
@export var min_depth: int = 0
@export var max_depth: int = 0
@export var base_duration_sec: float = 1200.0  # 本番値
@export var debug_duration_sec: float = 60.0  # デバッグ値
@export var unlock_encyclopedia_percent: float = 0.0  # 解放に必要な前階層の図鑑達成率
@export var color: Color = Color.BLUE  # 表示用カラー
