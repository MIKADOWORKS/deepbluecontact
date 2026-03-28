extends Control

@onready var screen_container: Control = $ScreenContainer
@onready var fade_rect: ColorRect = $TransitionLayer/FadeRect


func _ready() -> void:
	GameManager.set_screen_container(screen_container)
	GameManager.screen_changed.connect(_on_screen_changed)

	# ウィンドウ閉じ要求を手動処理（オートセーブのため）
	get_tree().set_auto_accept_quit(false)

	# タイトル画面から開始（セーブのロードはタイトル画面で行う）
	GameManager.change_screen("res://scenes/title/title_screen.tscn")


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
