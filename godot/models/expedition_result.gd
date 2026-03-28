class_name ExpeditionResult
extends Resource

@export var zone_id: String = ""
@export var submersible_id: String = ""
@export var species_found: Array[String] = []  # species_id のリスト
@export var sizes: Dictionary = {}  # {species_id: size_cm}
@export var xp_earned: int = 0
@export var is_new_discovery: Dictionary = {}  # {species_id: bool}
@export var events: Array[String] = []  # イベントテキスト
