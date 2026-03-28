extends Control

@onready var status_label: Label = $InfoPanel/StatusLabel
@onready var status_text: Label = $InfoPanel/ExpeditionStatus/StatusText
@onready var timer_label: Label = $InfoPanel/ExpeditionStatus/TimerLabel
@onready var progress_bar: ProgressBar = $InfoPanel/ExpeditionStatus/ProgressBar
@onready var dive_button: Button = $InfoPanel/DiveButton
@onready var observe_button: Button = $InfoPanel/ObserveButton
@onready var encyclopedia_button: Button = $InfoPanel/EncyclopediaButton
@onready var debug_label: Label = $InfoPanel/DebugLabel

@onready var depth_zone_1: Panel = $OceanPanel/DepthZone1
@onready var depth_zone_2: Panel = $OceanPanel/DepthZone2
@onready var depth_zone_3: Panel = $OceanPanel/DepthZone3
@onready var depth_zone_4: Panel = $OceanPanel/DepthZone4

var _zone_panels: Dictionary = {}  # {zone_id: Panel}


func _ready() -> void:
	_zone_panels = {
		"mesopelagic": depth_zone_1,
		"bathypelagic": depth_zone_2,
		"abyssopelagic": depth_zone_3,
		"hadal": depth_zone_4,
	}

	# シグナル接続
	ExpeditionManager.expedition_started.connect(_on_expedition_started)
	ExpeditionManager.expedition_completed.connect(_on_expedition_completed)

	dive_button.pressed.connect(_on_dive_pressed)
	observe_button.pressed.connect(_on_observe_pressed)
	encyclopedia_button.pressed.connect(_on_encyclopedia_pressed)

	_update_ui()
	_update_zone_display()


func _exit_tree() -> void:
	if ExpeditionManager.expedition_started.is_connected(_on_expedition_started):
		ExpeditionManager.expedition_started.disconnect(_on_expedition_started)
	if ExpeditionManager.expedition_completed.is_connected(_on_expedition_completed):
		ExpeditionManager.expedition_completed.disconnect(_on_expedition_completed)


func _process(_delta: float) -> void:
	if ExpeditionManager.state == ExpeditionManager.State.EXPLORING:
		var remaining: float = ExpeditionManager.get_remaining_sec()
		var minutes: int = int(remaining) / 60
		var seconds: int = int(remaining) % 60
		timer_label.text = "残り: %02d:%02d" % [minutes, seconds]
		progress_bar.value = ExpeditionManager.get_progress() * 100.0

	# デバッグ表示
	debug_label.visible = GameManager.debug_mode


func _update_ui() -> void:
	# プレイヤーステータス
	var pd: PlayerData = GameManager.player_data
	var required_xp: int = GameManager.get_xp_for_next_level()
	status_label.text = "Level: %d  XP: %d/%d" % [pd.level, pd.xp, required_xp]

	# 探査状態
	var is_exploring: bool = ExpeditionManager.state == ExpeditionManager.State.EXPLORING
	if is_exploring:
		status_text.text = "探査中..."
		dive_button.disabled = true
		observe_button.visible = true
	else:
		status_text.text = "待機中"
		timer_label.text = ""
		progress_bar.value = 0.0
		dive_button.disabled = false
		observe_button.visible = false


func _update_zone_display() -> void:
	for zone_id: String in _zone_panels:
		var panel: Panel = _zone_panels[zone_id]
		var unlocked: bool = GameManager.is_zone_unlocked(zone_id)
		var zone: DepthZoneData = DataRegistry.get_depth_zone(zone_id)
		if zone == null:
			continue

		# 背景スタイルをシンプルに設定
		var style := StyleBoxFlat.new()
		if unlocked:
			style.bg_color = zone.color
		else:
			style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		panel.add_theme_stylebox_override("panel", style)


func _on_dive_pressed() -> void:
	GameManager.change_screen("res://scenes/preparation/preparation_screen.tscn")


func _on_observe_pressed() -> void:
	GameManager.change_screen("res://scenes/observation/observation_screen.tscn")


func _on_encyclopedia_pressed() -> void:
	GameManager.change_screen("res://scenes/encyclopedia/encyclopedia_screen.tscn")


func _on_expedition_started() -> void:
	_update_ui()


func _on_expedition_completed(_result: ExpeditionResult) -> void:
	GameManager.change_screen("res://scenes/result/result_screen.tscn")
