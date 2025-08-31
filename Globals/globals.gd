extends Node

#class_name Globals

var popup_manager: PopupManager

func _ready() -> void:
	for node: Node in get_tree().root.get_children():
		if node.name == "Main":
			popup_manager = node.find_child("Popup_manager")
	print(popup_manager.name)

enum directions {UP, RIGHT, DOWN, LEFT}

const tile_size: float = 32.0
const vision_radius: float = 32*6

const door_velocity: float = 800

const tiles_in_a_room: int = 300
const minimum_mobs_in_room: int = 2

var time_elapsed: float = 0
const time_per_difficulty:float = 50 # [s]
var difficulty: int = 2

const mob_spawn_rates: Dictionary[String, int] = {
	"melee1" = 4,
	"ranged1"= 2,
}

var mob_scenes: Dictionary[String, PackedScene] = {
	"melee1" = preload("res://Scenes/Mobs/melee_mob.tscn") as PackedScene,
	"ranged1" = preload("res://Scenes/Mobs/ranged_mob.tscn") as PackedScene,
}

var level_spawn_rates: Dictionary[String, int] = {
	"room1" = 10,
	"room2" = 10,
	"room3" = 10,
	"room4" = 10,
	"room5" = 10,
	"room6" = 10,
	"room7" = 10,
	"room8" = 10,
	"room9" = 10,
}

var level_scenes: Dictionary[String, PackedScene] = {
	"room1" = preload("res://Scenes/Map/Hell6/room1.tscn") as PackedScene,
	"room2" = preload("res://Scenes/Map/Hell6/room2.tscn") as PackedScene,
	"room3" = preload("res://Scenes/Map/Hell6/room3.tscn") as PackedScene,
	"room4" = preload("res://Scenes/Map/Hell6/room4.tscn") as PackedScene,
	"room5" = preload("res://Scenes/Map/Hell6/room5.tscn") as PackedScene,
	"room6" = preload("res://Scenes/Map/Hell6/room6.tscn") as PackedScene,
	"room7" = preload("res://Scenes/Map/Hell6/room7.tscn") as PackedScene,
	"room8" = preload("res://Scenes/Map/Hell6/room8.tscn") as PackedScene,
	"room9" = preload("res://Scenes/Map/Hell6/room9.tscn") as PackedScene,
}

var special_rooms: Dictionary[String, PackedScene] = {
	"starter_room" = preload("res://Scenes/Map/Hell6/room0Start.tscn") as PackedScene,
	"stairs_room" = preload("res://Scenes/Map/Hell6/room10STAIRS.tscn") as PackedScene,
}


func _physics_process(delta: float) -> void:
	time_elapsed += delta
	difficulty = int(time_elapsed/time_per_difficulty)

func pick_weighted_random(weights: Dictionary) -> String:
	var total_weights: int = 0
	var keys: Array[String] = weights.keys()
	var values: Array[int] = weights.values()
	
	for weight: int in values:
		total_weights += weight
	
	var rand_value: int = randi() % total_weights
	
	var running_total: int = 0
	for i_mob: int in range(keys.size()):
		running_total += values[i_mob]
		if rand_value < running_total:
			return keys[i_mob]
	
	return ""
	
func vec2i_from_vec3i(a: Vector3i) -> Vector2i:
	return Vector2i(a.x, a.y)
