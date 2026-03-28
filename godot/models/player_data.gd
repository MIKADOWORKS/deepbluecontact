class_name PlayerData
extends Resource

@export var level: int = 1
@export var xp: int = 0
@export var discovered_species: Dictionary = {}  # {species_id: discovery_count}
@export var max_sizes: Dictionary = {}  # {species_id: max_size_cm}
@export var unlocked_zones: Array[String] = ["mesopelagic"]
@export var unlocked_submersibles: Array[String] = ["sub_basic"]
@export var unlocked_equipment: Array[String] = []
