extends Control

@onready var continue_button: Button = $MenuContainer/ContinueButton
@onready var new_game_button: Button = $MenuContainer/NewGameButton
@onready var quit_button: Button = $MenuContainer/QuitButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog


func _ready() -> void:
	# Continue ボタンはセーブがある場合のみ表示
	continue_button.visible = SaveManager.has_save()

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_new_game)


func _on_continue_pressed() -> void:
	var loaded: bool = SaveManager.load_game()
	if not loaded:
		push_warning("TitleScreen: セーブデータのロードに失敗しました")
		return

	# 探査完了済みならリザルト画面へ、それ以外はメイン画面へ
	if ExpeditionManager.state == ExpeditionManager.State.COMPLETED:
		GameManager.change_screen("res://scenes/result/result_screen.tscn")
	else:
		GameManager.change_screen("res://scenes/main/main_screen.tscn")


func _on_new_game_pressed() -> void:
	if SaveManager.has_save():
		# セーブがある場合は確認ダイアログを表示
		confirm_dialog.popup_centered()
	else:
		_start_new_game()


func _on_confirm_new_game() -> void:
	SaveManager.delete_save()
	_start_new_game()


func _start_new_game() -> void:
	# プレイヤーデータを初期化
	GameManager.player_data = PlayerData.new()
	ExpeditionManager.state = ExpeditionManager.State.IDLE
	GameManager.change_screen("res://scenes/main/main_screen.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
