extends Control

@onready var step_indicator: Label = $StepIndicator
@onready var content_container: VBoxContainer = $ContentContainer
@onready var launch_button: Button = $LaunchButton
@onready var back_button: Button = $BackButton

var _current_step: int = 1
var _selected_zone_id: String = ""
var _selected_submersible_id: String = ""
var _selected_equipment: Array[String] = []

# 装備カテゴリの選択状態 {category_index: equipment_id}
var _equipment_selections: Dictionary = {}

const ZONE_ORDER: Array[String] = ["mesopelagic", "bathypelagic", "abyssopelagic", "hadal"]
const EQUIPMENT_CATEGORIES: Array = [
	{"category": EquipmentData.Category.SEARCHLIGHT, "name": "サーチライト"},
	{"category": EquipmentData.Category.SENSOR, "name": "センサー"},
	{"category": EquipmentData.Category.CAMERA, "name": "カメラ"},
	{"category": EquipmentData.Category.PROPULSION, "name": "推進装置"},
]


func _ready() -> void:
	launch_button.pressed.connect(_on_launch_pressed)
	back_button.pressed.connect(_on_back_pressed)
	launch_button.visible = false
	_show_step(_current_step)


func _show_step(step: int) -> void:
	_current_step = step
	_clear_content()
	launch_button.visible = false

	match step:
		1:
			step_indicator.text = "Step 1/3: 深度選択"
			_build_zone_selection()
		2:
			step_indicator.text = "Step 2/3: 探査艇選択"
			_build_submersible_selection()
		3:
			step_indicator.text = "Step 3/3: 装備選択"
			_build_equipment_selection()


func _clear_content() -> void:
	for child: Node in content_container.get_children():
		child.queue_free()


# ==========================================================================
# Step 1: 深度帯選択
# ==========================================================================

func _build_zone_selection() -> void:
	for zone_id: String in ZONE_ORDER:
		var zone: DepthZoneData = DataRegistry.get_depth_zone(zone_id)
		if zone == null:
			continue
		var btn := Button.new()
		btn.text = "%s (%d-%dm)" % [zone.name_jp, zone.min_depth, zone.max_depth]
		btn.custom_minimum_size = Vector2(0, 50)
		var unlocked: bool = GameManager.is_zone_unlocked(zone_id)
		btn.disabled = not unlocked
		if unlocked:
			btn.pressed.connect(_on_zone_selected.bind(zone_id))
		content_container.add_child(btn)


func _on_zone_selected(zone_id: String) -> void:
	_selected_zone_id = zone_id
	_show_step(2)


# ==========================================================================
# Step 2: 探査艇選択
# ==========================================================================

func _build_submersible_selection() -> void:
	var zone: DepthZoneData = DataRegistry.get_depth_zone(_selected_zone_id)
	if zone == null:
		return

	for sub: SubmersibleData in DataRegistry.get_all_submersibles():
		var btn := Button.new()
		btn.text = "%s (最大深度: %dm)" % [sub.name_jp, sub.max_depth]
		btn.custom_minimum_size = Vector2(0, 50)

		var unlocked: bool = GameManager.is_submersible_unlocked(sub.id)
		var can_reach: bool = sub.max_depth >= zone.max_depth
		btn.disabled = not (unlocked and can_reach)

		if not btn.disabled:
			btn.pressed.connect(_on_submersible_selected.bind(sub.id))
		content_container.add_child(btn)


func _on_submersible_selected(sub_id: String) -> void:
	_selected_submersible_id = sub_id
	_show_step(3)


# ==========================================================================
# Step 3: 装備選択
# ==========================================================================

func _build_equipment_selection() -> void:
	_equipment_selections.clear()

	for i: int in range(EQUIPMENT_CATEGORIES.size()):
		var cat_info: Dictionary = EQUIPMENT_CATEGORIES[i]
		var category: EquipmentData.Category = cat_info["category"]
		var cat_name: String = cat_info["name"]

		var label := Label.new()
		label.text = cat_name
		content_container.add_child(label)

		var hbox := HBoxContainer.new()
		content_container.add_child(hbox)

		# 「なし」ボタン
		var none_btn := Button.new()
		none_btn.text = "なし"
		none_btn.toggle_mode = true
		none_btn.button_pressed = true
		none_btn.pressed.connect(_on_equipment_selected.bind(i, ""))
		hbox.add_child(none_btn)

		# カテゴリ別装備
		var equips: Array[EquipmentData] = DataRegistry.get_equipment_by_category(category)
		for equip: EquipmentData in equips:
			var btn := Button.new()
			btn.text = equip.name_jp
			btn.toggle_mode = true
			var unlocked: bool = GameManager.is_equipment_unlocked(equip.id)
			btn.disabled = not unlocked
			if unlocked:
				btn.pressed.connect(_on_equipment_selected.bind(i, equip.id))
			hbox.add_child(btn)

	launch_button.visible = true


func _on_equipment_selected(category_index: int, equip_id: String) -> void:
	if equip_id.is_empty():
		_equipment_selections.erase(category_index)
	else:
		_equipment_selections[category_index] = equip_id


# ==========================================================================
# 出発 / 戻る
# ==========================================================================

func _on_launch_pressed() -> void:
	# 選択した装備IDを配列にまとめる
	_selected_equipment.clear()
	for equip_id: String in _equipment_selections.values():
		if not equip_id.is_empty():
			_selected_equipment.append(equip_id)

	ExpeditionManager.start_expedition(
		_selected_zone_id,
		_selected_submersible_id,
		_selected_equipment
	)
	GameManager.change_screen("res://scenes/main/main_screen.tscn")


func _on_back_pressed() -> void:
	if _current_step > 1:
		_show_step(_current_step - 1)
	else:
		GameManager.change_screen("res://scenes/main/main_screen.tscn")
