extends Control

@onready var ocean_background: ColorRect = $OceanBackground
@onready var submersible: TextureRect = $Submersible
@onready var depth_label: Label = $DepthGauge/DepthLabel
@onready var depth_bar: ProgressBar = $DepthGauge/DepthBar
@onready var timer_label: Label = $HUD/TimerLabel
@onready var speed_button: Button = $HUD/SpeedButton
@onready var back_button: Button = $HUD/BackButton
@onready var event_log: Label = $EventLog

# 深度に応じた色（明→暗） - NatGeo風の深海グラデーション
var _color_surface: Color = Color(0.055, 0.11, 0.22)
var _color_deep: Color = Color(0.015, 0.025, 0.055)

# 探査艇テクスチャマッピング
const SUBMERSIBLE_TEXTURES: Dictionary = {
	"nereid_1": "res://assets/submersibles/nereid_1/rotations/south.png",
	"nereid_2": "res://assets/submersibles/nereid_2/rotations/south.png",
}

# 深度帯ごとの背景オブジェクトテクスチャ
const DEPTH_OBJECTS: Dictionary = {
	"mesopelagic": ["res://assets/objects/jellyfish.png"],
	"bathypelagic": ["res://assets/objects/shipwreck.png", "res://assets/objects/jellyfish.png"],
	"abyssopelagic": ["res://assets/objects/hydrothermal_vent.png", "res://assets/objects/rocky_cliff.png", "res://assets/objects/tubeworms.png"],
	"hadal": ["res://assets/objects/whale_skeleton.png", "res://assets/objects/hydrothermal_vent.png", "res://assets/objects/tubeworms.png"],
}

var _next_object_time: float = 0.0


func _ready() -> void:
	ExpeditionManager.set_observing(true)
	ExpeditionManager.expedition_completed.connect(_on_expedition_completed)

	speed_button.pressed.connect(_on_speed_toggle)
	back_button.pressed.connect(_on_back_pressed)

	_load_submersible_texture()
	_update_speed_label()
	event_log.text = "潜行開始..."


func _load_submersible_texture() -> void:
	var sub_id: String = ExpeditionManager._submersible_id
	if sub_id in SUBMERSIBLE_TEXTURES:
		var tex: Texture2D = load(SUBMERSIBLE_TEXTURES[sub_id])
		if tex != null:
			submersible.texture = tex


func _exit_tree() -> void:
	ExpeditionManager.set_observing(false)
	if ExpeditionManager.expedition_completed.is_connected(_on_expedition_completed):
		ExpeditionManager.expedition_completed.disconnect(_on_expedition_completed)


func _process(delta: float) -> void:
	if ExpeditionManager.state != ExpeditionManager.State.EXPLORING:
		return

	_try_spawn_object(delta)

	var progress: float = ExpeditionManager.get_progress()

	# 背景色を深度に応じて補間
	ocean_background.color = _color_surface.lerp(_color_deep, progress)

	# 探査艇の位置を進行に連動（上から下へ移動）
	var screen_size: Vector2 = get_viewport_rect().size
	var sub_size: Vector2 = submersible.size
	submersible.position.x = (screen_size.x - sub_size.x) / 2.0
	submersible.position.y = lerpf(50.0, screen_size.y - sub_size.y - 50.0, progress)

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


func _try_spawn_object(delta: float) -> void:
	_next_object_time -= delta
	if _next_object_time <= 0.0:
		_next_object_time = randf_range(8.0, 20.0)
		_spawn_background_object()


func _spawn_background_object() -> void:
	var zone_id: String = ExpeditionManager.get_zone_id()
	var objects: Array = DEPTH_OBJECTS.get(zone_id, [])
	if objects.is_empty():
		return
	var tex_path: String = objects[randi() % objects.size()]
	var tex: Texture2D = load(tex_path)
	if tex == null:
		return
	var sprite := TextureRect.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.custom_minimum_size = tex.get_size() * 2.5
	sprite.size = tex.get_size() * 2.5
	sprite.modulate.a = randf_range(0.5, 0.7)
	sprite.z_index = -1
	sprite.position = Vector2(1300, randf_range(200, 600))
	add_child(sprite)
	# 左へスクロールするTween
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "position:x", -300.0, randf_range(12.0, 25.0))
	tween.tween_callback(sprite.queue_free)


func _on_expedition_completed(_result: ExpeditionResult) -> void:
	GameManager.change_screen("res://scenes/result/result_screen.tscn")
