extends Control

@onready var screen_container: Control = $ScreenContainer
@onready var fade_rect: ColorRect = $TransitionLayer/FadeRect


func _ready() -> void:
	_setup_theme()
	GameManager.set_screen_container(screen_container)
	GameManager.screen_changed.connect(_on_screen_changed)

	# ウィンドウ閉じ要求を手動処理（オートセーブのため）
	get_tree().set_auto_accept_quit(false)

	# タイトル画面から開始（セーブのロードはタイトル画面で行う）
	GameManager.change_screen("res://scenes/title/title_screen.tscn")


func _setup_theme() -> void:
	var theme := Theme.new()

	# フォントサイズ
	theme.set_font_size("font_size", "Label", 16)
	theme.set_font_size("font_size", "Button", 16)

	# Label
	theme.set_color("font_color", "Label", Color("#e8e4dc"))

	# Button - 青の洞窟スタイル
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = Color("#0d2d5580")
	btn_normal.border_width_left = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color("#40c8f040")
	btn_normal.corner_radius_top_left = 2
	btn_normal.corner_radius_top_right = 2
	btn_normal.corner_radius_bottom_left = 2
	btn_normal.corner_radius_bottom_right = 2
	btn_normal.content_margin_left = 20.0
	btn_normal.content_margin_right = 20.0
	btn_normal.content_margin_top = 10.0
	btn_normal.content_margin_bottom = 10.0
	theme.set_stylebox("normal", "Button", btn_normal)

	var btn_hover := btn_normal.duplicate()
	btn_hover.bg_color = Color("#1a4a7a80")
	btn_hover.border_color = Color("#40c8f080")
	theme.set_stylebox("hover", "Button", btn_hover)

	var btn_pressed := btn_normal.duplicate()
	btn_pressed.bg_color = Color("#c8a84e30")
	btn_pressed.border_color = Color("#c8a84e")
	theme.set_stylebox("pressed", "Button", btn_pressed)

	var btn_disabled := btn_normal.duplicate()
	btn_disabled.bg_color = Color("#0a0a0a40")
	btn_disabled.border_color = Color("#40404040")
	theme.set_stylebox("disabled", "Button", btn_disabled)

	theme.set_color("font_color", "Button", Color("#e8e4dc"))
	theme.set_color("font_hover_color", "Button", Color("#40c8f0"))
	theme.set_color("font_pressed_color", "Button", Color("#c8a84e"))
	theme.set_color("font_disabled_color", "Button", Color("#606060"))

	# Panel - 青の洞窟スタイル半透明パネル
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#0a1e3a80")
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color("#40c8f020")
	panel_style.corner_radius_top_left = 2
	panel_style.corner_radius_top_right = 2
	panel_style.corner_radius_bottom_left = 2
	panel_style.corner_radius_bottom_right = 2
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# ProgressBar
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color("#0d2d55")
	pb_bg.corner_radius_top_left = 1
	pb_bg.corner_radius_top_right = 1
	pb_bg.corner_radius_bottom_left = 1
	pb_bg.corner_radius_bottom_right = 1
	theme.set_stylebox("background", "ProgressBar", pb_bg)

	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = Color("#c8a84e")
	pb_fill.corner_radius_top_left = 1
	pb_fill.corner_radius_top_right = 1
	pb_fill.corner_radius_bottom_left = 1
	pb_fill.corner_radius_bottom_right = 1
	theme.set_stylebox("fill", "ProgressBar", pb_fill)

	# ルートノードに適用（全子ノードに伝播）
	get_tree().root.theme = theme


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		GameManager.debug_mode = not GameManager.debug_mode
		print("Debug mode: %s" % str(GameManager.debug_mode))


func _on_screen_changed(_scene_path: String) -> void:
	pass
