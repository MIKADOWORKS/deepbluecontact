## SaveManager
## ゲームデータの永続化。
## Autoload シングルトンとして登録する。
extends Node

const SAVE_PATH: String = "user://save_data.tres"


func save_game() -> void:
	var data: Dictionary = {
		"player": _serialize_player_data(),
		"expedition": ExpeditionManager.get_save_data(),
	}

	var save_resource := Resource.new()
	save_resource.set_meta("save_data", data)

	var err: Error = ResourceSaver.save(save_resource, SAVE_PATH)
	if err != OK:
		push_error("SaveManager: セーブ失敗 — error code %d" % err)
	else:
		print("SaveManager: セーブ完了 — %s" % SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false

	var save_resource: Resource = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as Resource
	if save_resource == null:
		push_error("SaveManager: セーブファイル読み込み失敗")
		return false

	var data: Dictionary = save_resource.get_meta("save_data", {})
	if data.is_empty():
		push_error("SaveManager: セーブデータが空です")
		return false

	# プレイヤーデータ復元
	_deserialize_player_data(data.get("player", {}))

	# 探査状態の復元（放置復帰処理を含む）
	ExpeditionManager.restore_from_save(data.get("expedition", {}))

	print("SaveManager: ロード完了")
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
		print("SaveManager: セーブデータ削除完了")


# ==============================================================================
# PlayerData シリアライズ
# ==============================================================================

func _serialize_player_data() -> Dictionary:
	var pd: PlayerData = GameManager.player_data
	return {
		"level": pd.level,
		"xp": pd.xp,
		"discovered_species": pd.discovered_species,
		"max_sizes": pd.max_sizes,
		"unlocked_zones": pd.unlocked_zones,
		"unlocked_submersibles": pd.unlocked_submersibles,
		"unlocked_equipment": pd.unlocked_equipment,
	}


func _deserialize_player_data(data: Dictionary) -> void:
	var pd: PlayerData = GameManager.player_data
	pd.level = int(data.get("level", 1))
	pd.xp = int(data.get("xp", 0))
	pd.discovered_species = data.get("discovered_species", {})
	pd.max_sizes = data.get("max_sizes", {})

	var zones: Array = data.get("unlocked_zones", ["mesopelagic"])
	pd.unlocked_zones.clear()
	for z: String in zones:
		pd.unlocked_zones.append(z)

	var subs: Array = data.get("unlocked_submersibles", ["sub_basic"])
	pd.unlocked_submersibles.clear()
	for s: String in subs:
		pd.unlocked_submersibles.append(s)

	var equips: Array = data.get("unlocked_equipment", [])
	pd.unlocked_equipment.clear()
	for e: String in equips:
		pd.unlocked_equipment.append(e)
