## DataRegistry — Autoload singleton. Access via DataRegistry global name.
extends Node

## ゲームデータの読み込みと参照を提供するステートレスな辞書。
## Autoload シングルトンとして登録する。

var _species: Dictionary = {}       # {id: SpeciesData}
var _depth_zones: Dictionary = {}   # {id: DepthZoneData}
var _submersibles: Dictionary = {}  # {id: SubmersibleData}
var _equipment: Dictionary = {}     # {id: EquipmentData}


func _ready() -> void:
	_init_depth_zones()
	_init_species()
	_init_submersibles()
	_init_equipment()


# ==============================================================================
# アクセサ
# ==============================================================================

func get_species(id: String) -> SpeciesData:
	return _species.get(id) as SpeciesData


func get_all_species() -> Array[SpeciesData]:
	var result: Array[SpeciesData] = []
	for s: SpeciesData in _species.values():
		result.append(s)
	return result


func get_species_by_zone(zone_id: String) -> Array[SpeciesData]:
	var result: Array[SpeciesData] = []
	for s: SpeciesData in _species.values():
		if s.depth_zone_id == zone_id:
			result.append(s)
	return result


func get_depth_zone(id: String) -> DepthZoneData:
	return _depth_zones.get(id) as DepthZoneData


func get_all_depth_zones() -> Array[DepthZoneData]:
	var result: Array[DepthZoneData] = []
	for z: DepthZoneData in _depth_zones.values():
		result.append(z)
	return result


func get_submersible(id: String) -> SubmersibleData:
	return _submersibles.get(id) as SubmersibleData


func get_all_submersibles() -> Array[SubmersibleData]:
	var result: Array[SubmersibleData] = []
	for sub: SubmersibleData in _submersibles.values():
		result.append(sub)
	return result


func get_equipment(id: String) -> EquipmentData:
	return _equipment.get(id) as EquipmentData


func get_all_equipment() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for e: EquipmentData in _equipment.values():
		result.append(e)
	return result


func get_equipment_by_category(category: EquipmentData.Category) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for e: EquipmentData in _equipment.values():
		if e.category == category:
			result.append(e)
	return result


# ==============================================================================
# データ初期化（コード内で直接生成 -- .tres 不使用）
# ==============================================================================

func _init_depth_zones() -> void:
	_add_zone("mesopelagic", "Mesopelagic", "中深層",
		200, 1000, 1200.0, 30.0, 0.0, Color("0070b8"))
	_add_zone("bathypelagic", "Bathypelagic", "漸深層",
		1000, 3000, 3600.0, 60.0, 0.5, Color("004d8a"))
	_add_zone("abyssopelagic", "Abyssopelagic", "深海層",
		3000, 6000, 10800.0, 120.0, 0.5, Color("002d52"))
	_add_zone("hadal", "Hadal", "超深海層",
		6000, 11000, 21600.0, 300.0, 0.5, Color("0a1428"))


func _add_zone(id: String, name_en: String, name_jp: String,
		min_d: int, max_d: int, base_sec: float, debug_sec: float,
		unlock_pct: float, col: Color) -> void:
	var zone := DepthZoneData.new()
	zone.id = id
	zone.name_en = name_en
	zone.name_jp = name_jp
	zone.min_depth = min_d
	zone.max_depth = max_d
	zone.base_duration_sec = base_sec
	zone.debug_duration_sec = debug_sec
	zone.unlock_encyclopedia_percent = unlock_pct
	zone.color = col
	_depth_zones[id] = zone


func _init_species() -> void:
	# --- mesopelagic (3) ---
	_add_species("hatchetfish", "Hatchetfish", "ハダカイワシ",
		"mesopelagic", 0.8, 3.0, 8.0)
	_add_species("viperfish", "Viperfish", "ホウライエソ",
		"mesopelagic", 0.6, 15.0, 35.0)
	_add_species("glass_squid", "Glass Squid", "クラゲダコ",
		"mesopelagic", 0.5, 10.0, 45.0)
	# --- bathypelagic (3) ---
	_add_species("giant_squid", "Giant Squid", "ダイオウイカ",
		"bathypelagic", 0.3, 500.0, 1300.0)
	_add_species("flapjack_octopus", "Flapjack Octopus", "メンダコ",
		"bathypelagic", 0.6, 10.0, 20.0)
	_add_species("oarfish", "Oarfish", "リュウグウノツカイ",
		"bathypelagic", 0.2, 300.0, 1100.0)
	# --- abyssopelagic (2) ---
	_add_species("barreleye", "Barreleye", "デメニギス",
		"abyssopelagic", 0.4, 4.0, 15.0)
	_add_species("frilled_shark", "Frilled Shark", "ラブカ",
		"abyssopelagic", 0.3, 100.0, 200.0)
	# --- hadal (2) ---
	_add_species("amphipod", "Amphipod", "カイコウオオソコエビ",
		"hadal", 0.5, 2.0, 5.0)
	_add_species("snailfish", "Snailfish", "シンカイクサウオ",
		"hadal", 0.4, 8.0, 30.0)


func _add_species(id: String, name_en: String, name_jp: String,
		zone_id: String, rarity: float, min_cm: float, max_cm: float) -> void:
	var s := SpeciesData.new()
	s.id = id
	s.name_en = name_en
	s.name_jp = name_jp
	s.depth_zone_id = zone_id
	s.rarity = rarity
	s.min_size_cm = min_cm
	s.max_size_cm = max_cm
	s.trivia_en = "Trivia about %s" % name_en
	s.trivia_jp = "%sの豆知識" % name_jp
	_species[id] = s


func _init_submersibles() -> void:
	_add_submersible("sub_basic", "Nereid I", "ネレイド I号",
		3000, 1,
		"A reliable submersible for mid-depth exploration.",
		"中深度探査用の信頼性の高い探査艇。")
	_add_submersible("sub_advanced", "Nereid II", "ネレイド II号",
		11000, 3,
		"An advanced submersible capable of reaching the deepest trenches.",
		"最深部の海溝にも到達可能な高性能探査艇。")


func _add_submersible(id: String, name_en: String, name_jp: String,
		max_d: int, unlock_lv: int, desc_en: String, desc_jp: String) -> void:
	var sub := SubmersibleData.new()
	sub.id = id
	sub.name_en = name_en
	sub.name_jp = name_jp
	sub.max_depth = max_d
	sub.unlock_level = unlock_lv
	sub.description_en = desc_en
	sub.description_jp = desc_jp
	_submersibles[id] = sub


func _init_equipment() -> void:
	# Searchlight: 発見数ボーナス
	_add_equipment("searchlight_1", "Searchlight Mk.I", "サーチライト Mk.I",
		EquipmentData.Category.SEARCHLIGHT, 1, 0.1, 0.0)
	_add_equipment("searchlight_2", "Searchlight Mk.II", "サーチライト Mk.II",
		EquipmentData.Category.SEARCHLIGHT, 2, 0.2, 0.3)
	# Sensor: レア度補正
	_add_equipment("sensor_1", "Sensor Mk.I", "センサー Mk.I",
		EquipmentData.Category.SENSOR, 1, 0.1, 0.0)
	_add_equipment("sensor_2", "Sensor Mk.II", "センサー Mk.II",
		EquipmentData.Category.SENSOR, 2, 0.2, 0.3)
	# Camera: 豆知識取得率
	_add_equipment("camera_1", "Camera Mk.I", "カメラ Mk.I",
		EquipmentData.Category.CAMERA, 1, 0.3, 0.0)
	_add_equipment("camera_2", "Camera Mk.II", "カメラ Mk.II",
		EquipmentData.Category.CAMERA, 2, 0.5, 0.3)
	# Propulsion: 時間短縮
	_add_equipment("propulsion_1", "Propulsion Mk.I", "推進装置 Mk.I",
		EquipmentData.Category.PROPULSION, 1, 0.1, 0.0)
	_add_equipment("propulsion_2", "Propulsion Mk.II", "推進装置 Mk.II",
		EquipmentData.Category.PROPULSION, 2, 0.2, 0.3)


func _add_equipment(id: String, name_en: String, name_jp: String,
		category: EquipmentData.Category, tier: int,
		effect: float, unlock_pct: float) -> void:
	var equip := EquipmentData.new()
	equip.id = id
	equip.name_en = name_en
	equip.name_jp = name_jp
	equip.category = category
	equip.tier = tier
	equip.effect_value = effect
	equip.unlock_encyclopedia_percent = unlock_pct
	_equipment[id] = equip
