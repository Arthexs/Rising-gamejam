extends CanvasLayer

class_name HUD

var meter_value = 0
var meter_max = 100
var increase_speed = 1 # units per second
var health_value: float = 100
@export var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	meter_value += increase_speed * delta
	if meter_value > meter_max:
		meter_value = meter_max
	health_value = player.health_module.health
	$CorruptionMeter.value = meter_value
	$HealthMeter.value = health_value
	
func _on_main_tile_map_layer_spawned_mobs(mobs: Array[RigidBody2D]) -> void:
	for mob: RigidBody2D in mobs:
		if mob is MeleeMob:
			var melee_mob: MeleeMob = mob as MeleeMob
			melee_mob.death.connect(_on_melee_mob_death)
		if mob is RangedMob:
			var ranged_mob: RangedMob = mob as RangedMob
			ranged_mob.death.connect(_on_ranged_mob_death)



func _on_melee_mob_death(mob: MeleeMob) -> void:
	print("death detected of ", mob)
	#if $CorruptionMeter.value >= 0:
	meter_value -= 10
	meter_value = max(meter_value, 0)


func _on_ranged_mob_death(mob: RangedMob) -> void:
	print("death detected of ", mob)
	#if $CorruptionMeter.value >= 0:
	meter_value -= 10
	meter_value = max(meter_value, 0)
