extends Control

@onready var tab_1: Button = $TabBar/Tab1
@onready var tab_2: Button = $TabBar/Tab2
@onready var tab_3: Button = $TabBar/Tab3
@onready var tab_4: Button = $TabBar/Tab4
@onready var grid: GridContainer = $GridContainer
@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_name: Label = $DetailPanel/VBox/NameLabel
@onready var detail_photo: ColorRect = $DetailPanel/VBox/PhotoRect
@onready var detail_size: Label = $DetailPanel/VBox/SizeRecord
@onready var detail_trivia: Label = $DetailPanel/VBox/TriviaLabel
@onready var close_button: Button = $DetailPanel/VBox/CloseButton
@onready var back_button: Button = $BackButton

const SpeciesCardScene: PackedScene = preload("res://scenes/components/species_card.tscn")

const ZONE_ORDER: Array[String] = ["mesopelagic", "bathypelagic", "abyssopelagic", "hadal"]
const ZONE_NAMES: Array[String] = ["中深層", "漸深層", "深海層", "超深海層"]

var _current_zone_index: int = 0
var _tab_buttons: Array[Button] = []


func _ready() -> void:
	_tab_buttons = [tab_1, tab_2, tab_3, tab_4]

	for i: int in range(_tab_buttons.size()):
		_tab_buttons[i].pressed.connect(_on_tab_pressed.bind(i))

	close_button.pressed.connect(_on_close_detail)
	back_button.pressed.connect(_on_back_pressed)

	detail_panel.visible = false
	_update_tabs()
	_show_zone(0)


func _update_tabs() -> void:
	for i: int in range(ZONE_ORDER.size()):
		var zone_id: String = ZONE_ORDER[i]
		var zone_species: Array[SpeciesData] = DataRegistry.get_species_by_zone(zone_id)
		var discovered: int = 0
		for sp: SpeciesData in zone_species:
			if sp.id in GameManager.player_data.discovered_species:
				discovered += 1
		_tab_buttons[i].text = "%s (%d/%d)" % [ZONE_NAMES[i], discovered, zone_species.size()]


func _show_zone(index: int) -> void:
	_current_zone_index = index

	# グリッドをクリア
	for child: Node in grid.get_children():
		child.queue_free()

	var zone_id: String = ZONE_ORDER[index]
	var zone_species: Array[SpeciesData] = DataRegistry.get_species_by_zone(zone_id)

	for sp: SpeciesData in zone_species:
		var is_discovered: bool = sp.id in GameManager.player_data.discovered_species
		if is_discovered:
			var card: SpeciesCard = SpeciesCardScene.instantiate() as SpeciesCard
			grid.add_child(card)
			card.setup_encyclopedia(sp, GameManager.player_data)
			# クリックで詳細表示
			card.gui_input.connect(_on_card_input.bind(sp))
		else:
			# 未発見: プレースホルダー（エレガントな未発見表示）
			var placeholder := PanelContainer.new()
			placeholder.custom_minimum_size = Vector2(280, 90)
			var label := Label.new()
			label.text = "?"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", Color("#e8e4dc30"))
			label.add_theme_font_size_override("font_size", 24)
			placeholder.add_child(label)

			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.06, 0.08, 0.12, 0.5)
			style.border_width_left = 1
			style.border_width_right = 1
			style.border_width_top = 1
			style.border_width_bottom = 1
			style.border_color = Color("#c8a84e10")
			style.corner_radius_top_left = 2
			style.corner_radius_top_right = 2
			style.corner_radius_bottom_left = 2
			style.corner_radius_bottom_right = 2
			placeholder.add_theme_stylebox_override("panel", style)

			grid.add_child(placeholder)

	detail_panel.visible = false


func _on_tab_pressed(index: int) -> void:
	_update_tabs()
	_show_zone(index)


func _on_card_input(event: InputEvent, species: SpeciesData) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_detail(species)


func _show_detail(species: SpeciesData) -> void:
	detail_panel.visible = true
	detail_name.text = species.name_jp
	detail_photo.color = Color(0.1, 0.15, 0.25)

	var max_size: float = GameManager.player_data.max_sizes.get(species.id, 0.0)
	detail_size.text = "最大記録: %.1f cm" % max_size

	# 豆知識: 再発見済み（発見回数 >= 2）の場合のみ表示
	var discovery_count: int = GameManager.player_data.discovered_species.get(species.id, 0)
	if discovery_count >= 2:
		detail_trivia.text = species.trivia_jp
		detail_trivia.visible = true
	else:
		detail_trivia.text = "（再発見すると豆知識が追加されます）"
		detail_trivia.visible = true


func _on_close_detail() -> void:
	detail_panel.visible = false


func _on_back_pressed() -> void:
	GameManager.change_screen("res://scenes/main/main_screen.tscn")
