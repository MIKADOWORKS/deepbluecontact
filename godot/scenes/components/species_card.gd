class_name SpeciesCard
extends PanelContainer

@onready var photo: ColorRect = $HBox/Photo
@onready var name_label: Label = $HBox/Info/NameLabel
@onready var size_label: Label = $HBox/Info/SizeLabel
@onready var badge_label: Label = $HBox/Info/BadgeLabel


## リザルト画面用: 発見結果を表示
func setup(species: SpeciesData, size_cm: float, is_new: bool) -> void:
	name_label.text = species.name_jp
	size_label.text = "%.1f cm" % size_cm
	badge_label.text = "NEW!" if is_new else "再発見"
	badge_label.modulate = Color.YELLOW if is_new else Color.WHITE


## 図鑑画面用: プレイヤーの発見状況を表示
func setup_encyclopedia(species: SpeciesData, player_data: PlayerData) -> void:
	var is_discovered: bool = species.id in player_data.discovered_species
	if is_discovered:
		name_label.text = species.name_jp
		var max_size: float = player_data.max_sizes.get(species.id, 0.0)
		size_label.text = "最大: %.1f cm" % max_size
		var count: int = player_data.discovered_species.get(species.id, 0)
		badge_label.text = "発見: %d回" % count
		photo.color = Color(0.2, 0.3, 0.5)
	else:
		name_label.text = "???"
		size_label.text = ""
		badge_label.text = ""
		photo.color = Color(0.3, 0.3, 0.3)
