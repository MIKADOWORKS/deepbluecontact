extends Control

@onready var ocean_background: ColorRect = $OceanBackground
@onready var submersible: Label = $Submersible
@onready var depth_label: Label = $DepthGauge/DepthLabel
@onready var depth_bar: ProgressBar = $DepthGauge/DepthBar
@onready var timer_label: Label = $HUD/TimerLabel
@onready var speed_button: Button = $HUD/SpeedButton
@onready var back_button: Button = $HUD/BackButton
@onready var event_log: Label = $EventLog

# 深度に応じた色（明→暗）
var _color_surface: Color = Color(0.1, 0.2, 0.4)
var _color_deep: Color = Color(0.01, 0.02, 0.05)


func _ready() -> void:
	ExpeditionManager.set_observing(true)
	ExpeditionManager.expedition_completed.connect(_on_expedition_completed)

	speed_button.pressed.connect(_on_speed_toggle)
	back_button.pressed.connect(_on_back_pressed)

	_update_speed_label()
	event_log.text = "潜行開始..."


func _exit_tree() -> void:
	ExpeditionManager.set_observing(false)
	if ExpeditionManager.expedition_completed.is_connected(_on_expedition_completed):
		ExpeditionManager.expedition_completed.disconnect(_on_expedition_completed)


func _process(_delta: float) -> void:
	if ExpeditionManager.state != ExpeditionManager.State.EXPLORING:
		return

	var progress: float = ExpeditionManager.get_progress()

	# 背景色を深度に応じて補間
	ocean_background.color = _color_surface.lerp(_color_deep, progress)

	# 探査艇の位置を進行に連動（上から下へ移動）
	var screen_size: Vector2 = get_viewport_rect().size
	submersible.position.x = (screen_size.x - submersible.size.x) / 2.0
	submersible.position.y = lerpf(100.0, screen_size.y - 100.0, progress)

	# 深度表示
	var current_depth: int = ExpeditionManager.get_current_depth()
	depth_label.text = "現在深度: %dm" % current_depth
	depth_bar.value = progress * 100.0

	# タイマー表示
	var remaining: float = ExpeditionManager.get_remaining_sec()
	var minutes: int = int(remaining) / 60
	var seconds: int = int(remaining) % 60
	timer_label.text = "残り: %02d:%02d" % [minutes, seconds]


func _update_speed_label() -> void:
	if ExpeditionManager.is_observing:
		speed_button.text = "×2 ON"
	else:
		speed_button.text = "×2 OFF"


func _on_speed_toggle() -> void:
	var new_state: bool = not ExpeditionManager.is_observing
	ExpeditionManager.set_observing(new_state)
	_update_speed_label()


func _on_back_pressed() -> void:
	GameManager.change_screen("res://scenes/main/main_screen.tscn")


func _on_expedition_completed(_result: ExpeditionResult) -> void:
	GameManager.change_screen("res://scenes/result/result_screen.tscn")
