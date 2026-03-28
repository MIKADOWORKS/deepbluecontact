## GameManager
## プレイヤー状態、画面遷移、進行管理。
## Autoload シングルトンとして登録する。
extends Node

signal screen_changed(scene_path: String)
signal level_up(new_level: int)
signal zone_unlocked(zone_id: String)

var player_data: PlayerData = PlayerData.new()
var debug_mode: bool = true  # true の場合デバッグ用の短い探査時間を使用

# XP テーブル（レベル 1->2 は 100XP、以降 1.5 倍ずつ）
var _xp_table: Array[int] = [0, 100, 150, 225, 338, 506, 759, 1139, 1709, 2563]

var _screen_container: Control = null


# ==============================================================================
# 画面遷移
# ==============================================================================

func set_screen_container(container: Control) -> void:
	_screen_container = container


func change_screen(scene_path: String) -> void:
	if _screen_container == null:
		push_warning("GameManager: screen_container が未設定です")
		return

	# フェードアウト
	var tween: Tween = create_tween()
	tween.tween_property(_screen_container, "modulate:a", 0.0, 0.2)
	await tween.finished

	# 子ノードをクリア
	for child: Node in _screen_container.get_children():
		child.queue_free()

	# 新しいシーンを読み込み・追加
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("GameManager: シーン読み込み失敗 — %s" % scene_path)
		_screen_container.modulate.a = 1.0
		return

	var instance: Node = packed_scene.instantiate()
	_screen_container.add_child(instance)

	# フェードイン
	var tween_in: Tween = create_tween()
	tween_in.tween_property(_screen_container, "modulate:a", 1.0, 0.2)
	await tween_in.finished

	screen_changed.emit(scene_path)


# ==============================================================================
# XP・レベル
# ==============================================================================

func add_xp(amount: int) -> void:
	player_data.xp += amount
	var required: int = get_xp_for_next_level()
	while required > 0 and player_data.xp >= required:
		player_data.xp -= required
		player_data.level += 1
		level_up.emit(player_data.level)
		# アンロックチェック
		check_unlocks()
		required = get_xp_for_next_level()


func get_xp_for_next_level() -> int:
	var idx: int = player_data.level  # level 1 -> index 1 (100XP)
	if idx < _xp_table.size():
		return _xp_table[idx]
	# テーブル外は最後の値の 1.5 倍を積み上げ
	return int(_xp_table[_xp_table.size() - 1] * pow(1.5, idx - _xp_table.size() + 1))


func get_level_progress() -> float:
	var required: int = get_xp_for_next_level()
	if required <= 0:
		return 1.0
	return clampf(float(player_data.xp) / float(required), 0.0, 1.0)


# ==============================================================================
# アンロック判定
# ==============================================================================

func is_zone_unlocked(zone_id: String) -> bool:
	return zone_id in player_data.unlocked_zones


func is_submersible_unlocked(sub_id: String) -> bool:
	return sub_id in player_data.unlocked_submersibles


func is_equipment_unlocked(equip_id: String) -> bool:
	return equip_id in player_data.unlocked_equipment


func check_unlocks() -> Array[String]:
	var newly_unlocked: Array[String] = []

	# --- 深度階層のアンロック ---
	var zones: Array[DepthZoneData] = DataRegistry.get_all_depth_zones()
	var zone_order: Array[String] = ["mesopelagic", "bathypelagic", "abyssopelagic", "hadal"]
	for i: int in range(1, zone_order.size()):
		var zone_id: String = zone_order[i]
		if zone_id in player_data.unlocked_zones:
			continue
		var zone: DepthZoneData = DataRegistry.get_depth_zone(zone_id)
		if zone == null:
			continue
		# 前階層の図鑑達成率で判定
		var prev_zone_id: String = zone_order[i - 1]
		var prev_pct: float = get_encyclopedia_percent(prev_zone_id)
		if prev_pct >= zone.unlock_encyclopedia_percent:
			player_data.unlocked_zones.append(zone_id)
			newly_unlocked.append(zone_id)
			zone_unlocked.emit(zone_id)

	# --- 探査艇のアンロック ---
	for sub: SubmersibleData in DataRegistry.get_all_submersibles():
		if sub.id in player_data.unlocked_submersibles:
			continue
		if player_data.level >= sub.unlock_level:
			player_data.unlocked_submersibles.append(sub.id)
			newly_unlocked.append(sub.id)

	# --- 装備のアンロック ---
	var total_pct: float = get_total_encyclopedia_percent()
	for equip: EquipmentData in DataRegistry.get_all_equipment():
		if equip.id in player_data.unlocked_equipment:
			continue
		if total_pct >= equip.unlock_encyclopedia_percent:
			player_data.unlocked_equipment.append(equip.id)
			newly_unlocked.append(equip.id)

	return newly_unlocked


# ==============================================================================
# 図鑑
# ==============================================================================

func get_encyclopedia_percent(zone_id: String) -> float:
	var zone_species: Array[SpeciesData] = DataRegistry.get_species_by_zone(zone_id)
	if zone_species.is_empty():
		return 0.0
	var discovered_count: int = 0
	for sp: SpeciesData in zone_species:
		if sp.id in player_data.discovered_species:
			discovered_count += 1
	return float(discovered_count) / float(zone_species.size())


func get_total_encyclopedia_percent() -> float:
	var all_species: Array[SpeciesData] = DataRegistry.get_all_species()
	if all_species.is_empty():
		return 0.0
	var discovered_count: int = 0
	for sp: SpeciesData in all_species:
		if sp.id in player_data.discovered_species:
			discovered_count += 1
	return float(discovered_count) / float(all_species.size())


func register_discovery(species_id: String, size_cm: float) -> bool:
	var is_new: bool = not (species_id in player_data.discovered_species)
	if is_new:
		player_data.discovered_species[species_id] = 1
		player_data.max_sizes[species_id] = size_cm
	else:
		player_data.discovered_species[species_id] += 1
		var current_max: float = player_data.max_sizes.get(species_id, 0.0)
		if size_cm > current_max:
			player_data.max_sizes[species_id] = size_cm
	return is_new
