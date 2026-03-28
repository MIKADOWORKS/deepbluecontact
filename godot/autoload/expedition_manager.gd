## ExpeditionManager
## 探査のライフサイクル管理。
## Autoload シングルトンとして登録する。
##
## 聖域ルール遵守:
##   _generate_result() は start_expedition() 内で1回だけ呼ばれる。
##   is_observing は _process() のタイマー加速にのみ使用。
##   結果生成コードは is_observing を一切参照しない。
extends Node

signal expedition_started()
signal expedition_tick(elapsed: float, total: float)
signal expedition_completed(result: ExpeditionResult)

enum State { IDLE, EXPLORING, COMPLETED }

var state: State = State.IDLE
var is_observing: bool = false  # 観察モード中か

var _zone_id: String = ""
var _submersible_id: String = ""
var _equipment_ids: Array[String] = []
var _elapsed_sec: float = 0.0
var _total_sec: float = 0.0
var _result: ExpeditionResult = null
var _start_timestamp: float = 0.0  # Unix timestamp（放置復帰用）


# ==============================================================================
# 探査制御
# ==============================================================================

func start_expedition(
	zone_id: String,
	submersible_id: String,
	equipment_ids: Array[String]
) -> void:
	if state != State.IDLE:
		push_warning("ExpeditionManager: 探査中に新たな探査は開始できません")
		return

	_zone_id = zone_id
	_submersible_id = submersible_id
	_equipment_ids = equipment_ids.duplicate()

	# 所要時間の計算
	var zone: DepthZoneData = DataRegistry.get_depth_zone(zone_id)
	if zone == null:
		push_error("ExpeditionManager: 不明な zone_id — %s" % zone_id)
		return

	var base_duration: float = zone.debug_duration_sec if GameManager.debug_mode else zone.base_duration_sec

	# 推進装備による時間短縮
	var propulsion_reduction: float = 0.0
	for eid: String in _equipment_ids:
		var equip: EquipmentData = DataRegistry.get_equipment(eid)
		if equip != null and equip.category == EquipmentData.Category.PROPULSION:
			propulsion_reduction += equip.effect_value

	_total_sec = base_duration * maxf(1.0 - propulsion_reduction, 0.3)
	_elapsed_sec = 0.0
	_start_timestamp = Time.get_unix_time_from_system()

	# 結果を事前決定（聖域ルール: 観察モードは結果に影響しない）
	_result = _generate_result()

	state = State.EXPLORING
	expedition_started.emit()

	# 探査開始時オートセーブ（放置復帰に備える）
	SaveManager.save_game()


func _process(delta: float) -> void:
	if state != State.EXPLORING:
		return

	# 観察モード中は 2 倍速（聖域ルール: 時間短縮のみ）
	var speed: float = 2.0 if is_observing else 1.0
	_elapsed_sec += delta * speed

	expedition_tick.emit(_elapsed_sec, _total_sec)

	if _elapsed_sec >= _total_sec:
		_complete_expedition()


func set_observing(observing: bool) -> void:
	is_observing = observing


func get_progress() -> float:
	if _total_sec <= 0.0:
		return 0.0
	return clampf(_elapsed_sec / _total_sec, 0.0, 1.0)


func get_remaining_sec() -> float:
	return maxf(_total_sec - _elapsed_sec, 0.0)


func get_result() -> ExpeditionResult:
	return _result


func get_current_depth() -> int:
	var zone: DepthZoneData = DataRegistry.get_depth_zone(_zone_id)
	if zone == null:
		return 0
	var progress: float = get_progress()
	return int(lerpf(float(zone.min_depth), float(zone.max_depth), progress))


# ==============================================================================
# 結果生成（聖域ルール: is_observing を一切参照しない）
# ==============================================================================

func _generate_result() -> ExpeditionResult:
	var result := ExpeditionResult.new()
	result.zone_id = _zone_id
	result.submersible_id = _submersible_id

	var zone_species: Array[SpeciesData] = DataRegistry.get_species_by_zone(_zone_id)
	if zone_species.is_empty():
		result.xp_earned = 50
		return result

	# 装備効果の集計
	var searchlight_bonus: float = 0.0
	var sensor_bonus: float = 0.0
	var _camera_bonus: float = 0.0
	for eid: String in _equipment_ids:
		var equip: EquipmentData = DataRegistry.get_equipment(eid)
		if equip == null:
			continue
		match equip.category:
			EquipmentData.Category.SEARCHLIGHT:
				searchlight_bonus += equip.effect_value
			EquipmentData.Category.SENSOR:
				sensor_bonus += equip.effect_value
			EquipmentData.Category.CAMERA:
				_camera_bonus += equip.effect_value

	# 発見数: 基本 1-3 種 + searchlight ボーナス
	var base_count: int = randi_range(1, 3)
	var bonus_count: int = 1 if randf() < searchlight_bonus else 0
	var target_count: int = mini(base_count + bonus_count, zone_species.size())

	# rarity に基づく加重ランダム選択（sensor ボーナスで低 rarity の出現率向上）
	var weighted_pool: Array[SpeciesData] = []
	for sp: SpeciesData in zone_species:
		var adjusted_rarity: float = sp.rarity + sensor_bonus
		# rarity を重みとして複数回追加
		var weight: int = maxi(int(adjusted_rarity * 10.0), 1)
		for _w: int in range(weight):
			weighted_pool.append(sp)

	# 重複なしで選択
	var selected_ids: Dictionary = {}
	var attempts: int = 0
	while selected_ids.size() < target_count and attempts < 100:
		var pick: SpeciesData = weighted_pool[randi() % weighted_pool.size()]
		if pick.id not in selected_ids:
			selected_ids[pick.id] = true
			result.species_found.append(pick.id)

			# サイズ: min-max 間のランダム
			var size: float = randf_range(pick.min_size_cm, pick.max_size_cm)
			result.sizes[pick.id] = snappedf(size, 0.1)

			# 新規発見判定
			result.is_new_discovery[pick.id] = not (
				pick.id in GameManager.player_data.discovered_species
			)
		attempts += 1

	# XP 計算: base(50) x depth_multiplier x species_count
	var zone_data: DepthZoneData = DataRegistry.get_depth_zone(_zone_id)
	var depth_multiplier: float = 1.0
	if zone_data != null:
		depth_multiplier = 1.0 + (float(zone_data.min_depth) / 2000.0)
	result.xp_earned = int(50.0 * depth_multiplier * float(result.species_found.size()))

	return result


func _complete_expedition() -> void:
	state = State.COMPLETED
	expedition_completed.emit(_result)


# ==============================================================================
# 放置復帰用セーブ/ロード
# ==============================================================================

func get_save_data() -> Dictionary:
	return {
		"state": state,
		"zone_id": _zone_id,
		"submersible_id": _submersible_id,
		"equipment_ids": _equipment_ids,
		"elapsed_sec": _elapsed_sec,
		"total_sec": _total_sec,
		"start_timestamp": _start_timestamp,
		"result": _serialize_result(_result),
	}


func restore_from_save(data: Dictionary) -> void:
	state = int(data.get("state", State.IDLE)) as State
	_zone_id = str(data.get("zone_id", ""))
	_submersible_id = str(data.get("submersible_id", ""))
	var raw_equip_ids: Array = data.get("equipment_ids", [])
	_equipment_ids.clear()
	for eid in raw_equip_ids:
		_equipment_ids.append(str(eid))
	_total_sec = float(data.get("total_sec", 0.0))
	_start_timestamp = float(data.get("start_timestamp", 0.0))

	# 放置時間を反映（観察なし = 等速で計算）
	var saved_elapsed: float = data.get("elapsed_sec", 0.0) as float
	var time_diff: float = Time.get_unix_time_from_system() - _start_timestamp
	_elapsed_sec = maxf(saved_elapsed, time_diff)

	# 結果の復元
	_result = _deserialize_result(data.get("result", {}))

	# 既に完了していたら即完了
	if state == State.EXPLORING and _elapsed_sec >= _total_sec:
		_complete_expedition()


func _serialize_result(result: ExpeditionResult) -> Dictionary:
	if result == null:
		return {}
	return {
		"zone_id": result.zone_id,
		"submersible_id": result.submersible_id,
		"species_found": result.species_found,
		"sizes": result.sizes,
		"xp_earned": result.xp_earned,
		"is_new_discovery": result.is_new_discovery,
		"events": result.events,
	}


func _deserialize_result(data: Dictionary) -> ExpeditionResult:
	if data.is_empty():
		return null
	var result := ExpeditionResult.new()
	result.zone_id = str(data.get("zone_id", ""))
	result.submersible_id = str(data.get("submersible_id", ""))
	result.species_found.assign(data.get("species_found", []))
	result.sizes = data.get("sizes", {})
	result.xp_earned = int(data.get("xp_earned", 0))
	result.is_new_discovery = data.get("is_new_discovery", {})
	result.events.assign(data.get("events", []))
	return result
