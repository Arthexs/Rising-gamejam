extends Node

#class_name Globals

@export var melee1_packed_scene: PackedScene = preload("res://Scenes/Mobs/melee_mob.tscn") as PackedScene
@export var ranged1_packed_scene: PackedScene = preload("res://Scenes/Mobs/ranged_mob.tscn") as PackedScene

enum directions {UP, RIGHT, DOWN, LEFT}

const tile_size: float = 32.0

const door_velocity: float = 1200

const tiles_in_a_room: int = 100
const minimum_mobs_in_room: int = 2

var time_elapsed: float = 0
const time_per_difficulty:float = 50 # [s]
var difficulty: int = 2

const mob_spawn_rates: Dictionary[String, int] = {
	"melee1" = 3,
	"ranged1"= 2,
}

var mob_scenes: Dictionary[String, PackedScene] = {
	"melee1" = melee1_packed_scene,
	"ranged1" = ranged1_packed_scene,
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
	
