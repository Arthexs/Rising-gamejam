extends CanvasLayer

class_name HUD

var meter_value = 0
var meter_max = 100
var increase_speed: float = Globals.misams_base_rate # units per second
var health_value: float = 100
@export var player: Player
@export var popup_manager: PopupManager

@export var game_over_scene: PackedScene
@export var win_screen_scene: PackedScene

@export var skel_death_scene: PackedScene
@export var eye_death_scene: PackedScene

@onready var corruption_meter: TextureProgressBar = $CorruptionMeter
@onready var health_meter: TextureProgressBar = $HealthMeter

var game_has_ended: bool = false

var previous_dead_mob: RID

var previous_meter_value: float = 0
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	meter_value += increase_speed * delta
	if meter_value > meter_max:
		meter_value = meter_max
		player_died()
	health_value = player.health_module.health/player.health_module.max_health*100
	corruption_meter.value = meter_value
	health_meter.value = health_value
	
	previous_meter_value = meter_value
	
	increase_speed = Globals.misams_base_rate + tanh((float(Globals.difficulty)-2.0)/(5.0*4.0))*2.5
	#print(Globals.difficulty, "|", increase_speed, "|", tanh(5.0/12.0))#float(5/12*180)/PI)
	#if health_meter.value 

#func show_end_screen(good: bool) -> void:


func _on_main_tile_map_layer_spawned_mobs(mobs: Array[RigidBody2D]) -> void:
	for mob: RigidBody2D in mobs:
		if mob is MeleeMob:
			var melee_mob: MeleeMob = mob as MeleeMob
			melee_mob.death.connect(_on_melee_mob_death)
		if mob is RangedMob:
			var ranged_mob: RangedMob = mob as RangedMob
			ranged_mob.death.connect(_on_ranged_mob_death)
			#print("hooked ranged")


func _on_melee_mob_death(mob: MeleeMob) -> void:
	print("death detected of ", mob)
	if mob.get_rid() == previous_dead_mob:
		return
	previous_dead_mob = mob.get_rid()
	
	meter_value = previous_meter_value - 10
	meter_value = max(meter_value, 0)
	
	$Audio.add_child(skel_death_scene.instantiate())
	
	mob_died()
	player.flash(Color.WHITE, 0.7, 0.2)


func _on_ranged_mob_death(mob: RangedMob) -> void:
	print("death detected of ", mob)
	if mob.get_rid() == previous_dead_mob:
		return
	previous_dead_mob = mob.get_rid()
	
	meter_value = previous_meter_value - 40
	meter_value = max(meter_value, 0)
	$Audio.add_child(eye_death_scene.instantiate())
	mob_died()
	player.flash(Color.WHITE, 0.7, 0.2)

func mob_died() -> void:
	Globals.level_spawn_rates["stairs_room"] += Globals.stairs_appearance_rate
	var pos: Vector2 = player.global_position + Vector2(0, -player.collision_box.shape.get_rect().size.y/2)
	popup_manager.place_label(pos.x, pos.y, "-Corruption", 0.5, 0.5)

func player_died() -> void:
	game_ending(false)

func _on_main_tile_map_layer_game_end(win: bool) -> void:
	game_ending(win)

func game_ending(you_win: bool) -> void:
	if game_has_ended:
		return
	game_has_ended = true
	
	var screen: Control
	if you_win:
		screen = win_screen_scene.instantiate()
		#print("you win")
	else:
		screen = game_over_scene.instantiate()
		#print("you lose")
	add_child(screen)
	screen.move_to_front()
