class_name SpeciesData
extends Resource

@export var id: String = ""
@export var name_en: String = ""
@export var name_jp: String = ""
@export var depth_zone_id: String = ""  # mesopelagic, bathypelagic, abyssopelagic, hadal
@export var rarity: float = 1.0  # 0.0-1.0, higher = more common
@export var min_size_cm: float = 0.0
@export var max_size_cm: float = 0.0
@export var trivia_en: String = ""
@export var trivia_jp: String = ""
@export var image_path: String = ""  # 将来の実写写真パス
