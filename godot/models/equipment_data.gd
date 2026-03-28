class_name EquipmentData
extends Resource

enum Category { SEARCHLIGHT, SENSOR, CAMERA, PROPULSION }

@export var id: String = ""
@export var name_en: String = ""
@export var name_jp: String = ""
@export var category: Category = Category.SEARCHLIGHT
@export var tier: int = 1
@export var effect_value: float = 0.0  # カテゴリに応じた効果値
@export var unlock_encyclopedia_percent: float = 0.0  # 解放条件
