extends Control

@onready var species_container: VBoxContainer = $SpeciesContainer
@onready var xp_label: Label = $XPLabel
@onready var level_up_label: Label = $LevelUpLabel
@onready var unlock_label: Label = $UnlockLabel
@onready var ok_button: Button = $OKButton

const SpeciesCardScene: PackedScene = preload("res://scenes/components/species_card.tscn")


func _ready() -> void:
	ok_button.pressed.connect(_on_ok_pressed)

	level_up_label.visible = false
	unlock_label.visible = false

	_show_result()


func _show_result() -> void:
	# ExpeditionManager の最新結果を取得
	var result: ExpeditionResult = ExpeditionManager.get_result()
	if result == null:
		xp_label.text = "結果なし"
		return
	var prev_level: int = GameManager.player_data.level

	# 発見生物カードを生成
	for species_id: String in result.species_found:
		var species: SpeciesData = DataRegistry.get_species(species_id)
		if species == null:
			continue

		var size_cm: float = result.sizes.get(species_id, 0.0)
		var is_new: bool = result.is_new_discovery.get(species_id, false)

		# 図鑑登録
		GameManager.register_discovery(species_id, size_cm)

		# カード生成
		var card: SpeciesCard = SpeciesCardScene.instantiate() as SpeciesCard
		species_container.add_child(card)
		card.setup(species, size_cm, is_new)

	# XP加算
	GameManager.add_xp(result.xp_earned)
	xp_label.text = "獲得XP: +%d" % result.xp_earned

	# レベルアップ判定
	var new_level: int = GameManager.player_data.level
	if new_level > prev_level:
		level_up_label.text = "Level Up! Lv.%d → Lv.%d" % [prev_level, new_level]
		level_up_label.visible = true

	# アンロック確認
	var unlocks: Array[String] = GameManager.check_unlocks()
	if not unlocks.is_empty():
		var unlock_names: PackedStringArray = PackedStringArray()
		for uid: String in unlocks:
			unlock_names.append(_get_unlock_display_name(uid))
		unlock_label.text = "NEW: %s" % ", ".join(unlock_names)
		unlock_label.visible = true

	# 探査状態をリセット
	ExpeditionManager.state = ExpeditionManager.State.IDLE

	# オートセーブ
	SaveManager.save_game()


func _get_unlock_display_name(id: String) -> String:
	# zone
	var zone: DepthZoneData = DataRegistry.get_depth_zone(id)
	if zone != null:
		return zone.name_jp

	# submersible
	var sub: SubmersibleData = DataRegistry.get_submersible(id)
	if sub != null:
		return sub.name_jp

	# equipment
	var equip: EquipmentData = DataRegistry.get_equipment(id)
	if equip != null:
		return equip.name_jp

	return id


func _on_ok_pressed() -> void:
	GameManager.change_screen("res://scenes/main/main_screen.tscn")
