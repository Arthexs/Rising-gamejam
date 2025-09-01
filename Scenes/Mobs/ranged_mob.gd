extends RigidBody2D

class_name RangedMob

@export var body: AnimatedSprite2D

@export var preferred_distance: float = 150.0 # sweet spot distance
@export var tolerance: float = 25.0           # +/- range around preferred_distance
#@export var speed: float = 200.0
@export var agent: NavigationAgent2D
@export var player: Player
@export var acceleration: float = 0.6
@export var friction_coefficient: float = 40 # px/m/s
var movement_force = acceleration * mass * 32 # px/m

@export var force_threshold: float = 170000 # force threshold to be send flying
@export var brake_threshold: float = 0.6 # Fraction of velocity needed to be lost to take damage on impact
@export var damage_tuner: float = 1.0

@export var summoning_scene: PackedScene = preload("res://Scenes/Mobs/summoning_circle.tscn") as PackedScene
@export var projectile_scene: PackedScene
@export var shoot_interval: float = 3
@export var projectile_speed: float = 200
@export var projectile_damage: float = 20.0


@onready var moving_player: AudioStreamPlayer = ($Audio/Moving as AudioStreamPlayer)
@onready var death_player: AudioStreamPlayer = ($Audio/Death as AudioStreamPlayer)
@onready var bash_player: AudioStreamPlayer = ($Audio/Bash as AudioStreamPlayer)

signal death(mob: RangedMob)

var player_in_range: Player = null

var health_module: HealthModule
var prev_velocity: Vector2 = Vector2.ZERO
var mass_max: float = mass
var flying: bool = false
var attacking: bool = false
var stuck: bool = false

var agro: bool = false
var summoning_circ: SummoningProjectile

@onready var shooting_timer = $ShootingTimer
@onready var shooting_area = $ShootingArea
@onready var collision_shape = $ShootingArea/CollisionShape2D
@onready var hitbox_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	mass_max = mass
	health_module = get_node("HealthModule")
	
	agent.target_desired_distance = 10
	set_target(player.global_position)
	
	shooting_timer.wait_time = shoot_interval
	shooting_timer.one_shot = true
	
	shooting_area.body_entered.connect(_on_shooting_area_area_entered)
	shooting_area.body_exited.connect(_on_shooting_area_area_exited)
	
	var shape = collision_shape.shape
	if shape is CircleShape2D:
		shape.radius = preferred_distance + tolerance
	
	body.play("idle")

func set_target(target_position: Vector2):
	agent.target_position = target_position
	agent.get_next_path_position()

func _physics_process(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	var distance = to_player.length()
	var direction: Vector2 = to_player.normalized()
	
	handle_damage(delta)
	
	
	if agro and not attacking:
	# Decide behavior based on distance
		#print(stuck)
		if distance > preferred_distance + tolerance:
			# Too far → move closer
			apply_movement(direction)
		elif distance < preferred_distance - tolerance:
			# Too close → move away
			apply_movement(-direction)
			if linear_velocity.length_squared() < 1:
				stuck = true
		else:
			# In range → apply friction so it stops
			apply_friction()
		try_attack()
	else:
		agro = to_player.length() < Globals.vision_radius
		#if agro:
			#print("enemy agro'ed")
	
	do_animation(delta)
	
	prev_velocity = linear_velocity
	
	if linear_velocity.length() > Globals.flip_velocity:
		if not moving_player.playing:
			moving_player.play()
	else:
		if moving_player.playing:
			moving_player.stop()

func do_animation(delta: float) -> void:
	if body.animation == "attacking" and not attacking:
		body.play("idle")
	elif body.animation == "idle" and attacking:
		body.play("attacking")
	
	if linear_velocity.length() > Globals.flip_velocity:
		body.flip_h = linear_velocity.x < 0
	
	if t_anim_goal != 0:
		t_anim += delta
		body.set_instance_shader_parameter("t", t_anim/t_anim_goal)
		if t_anim >= t_anim_goal:
			t_anim_goal = 0
			t_anim = 0
	

func handle_damage(delta: float) -> void:
	var delta_vel: float = linear_velocity.length() - prev_velocity.length()
	
	var force: float = abs(delta_vel)/delta * mass_max
	
	#print("force on ranged: ", force, "/", force_threshold)
	
	if force > force_threshold and player.is_hitting:
		if not bash_player.playing:
			#print("Bashed")
			bash_player.play()
		
		var damage: float = force/25000 * damage_tuner
		#print("damage taken: ", damage, " | ", force/25000, "*", damage_tuner)
		health_module.take_damage(damage)
		mass = 0.1*mass_max
		stop_attacking()
		#apply_central_force(linear_velocity.normalized() * force)
		flying = true
	
	if prev_velocity.length() != 0:
		#print(delta_vel/prev_velocity.length(), " < ", - (1-brake_threshold))
		if delta_vel/prev_velocity.length() < - (1-brake_threshold) && flying:
			var damage: float = force/25000 * damage_tuner
			#print("damage taken: ", damage)
			health_module.take_damage(damage)
			linear_velocity = Vector2.ZERO
			mass = mass_max
			flying = false
	
	prev_velocity = linear_velocity

func stop_attacking() -> void:
	attacking = false
	stuck = false

func try_attack():
	#print(shooting_timer.time_left)
	if player_in_range and shooting_timer.time_left < 0.01:
		start_attack()
		shooting_timer.start()

func start_attack() -> void:
	attacking = true
	#print(summoning_scene)
	summoning_circ = summoning_scene.instantiate()
	summoning_circ.global_position = Vector2(0, -hitbox_shape.shape.get_rect().size.y/2-20)
	add_child(summoning_circ)
	summoning_circ.animation_finished.connect(shoot_projectile)
	
	#add_child(summoning_scene.)
	

#func _on_attack_timer_timeout() -> void:
	#try_attack()

func died() -> void:
	death.emit(self)

func apply_friction() -> void:
	if linear_velocity.length() > 0:
		apply_central_force(-linear_velocity.normalized() * friction_coefficient)
	#print(linear_velocity.length(), "/", max_vel)
	#if flying:
		##flying = false
		#apply_central_force(-linear_velocity.normalized() * friction_coefficient*0.1)
	#else:
		#apply_central_force(-linear_velocity.normalized() * friction_coefficient)
		##flying = true

func apply_movement(direction: Vector2) -> void:
	if flying:
		#print("flying")
		return
	
	var comp_dir: Vector2
	# Negative rejection
	comp_dir = -(linear_velocity - linear_velocity.dot(direction) * direction) * mass * 5
	# Target force (compensate when going in the wrong direction)
	if linear_velocity.dot(direction) < 0:
		comp_dir += direction * movement_force * 7.5
	else:
		comp_dir += direction * movement_force
	
	apply_central_force(comp_dir)

func shoot_projectile():
	print("shooting")
#	
	var dir = (player.global_position - global_position).normalized()
	var projectile = projectile_scene.instantiate()
	
	get_parent().add_child(projectile)
	projectile.global_position = global_position + Vector2(0, -hitbox_shape.shape.get_rect().size.y/2-3)
	print(projectile.global_position)
	print(player.global_position)
	projectile.rotation = dir.angle()

	# Apply velocity if available
	#print("given speed: ", projectile_speed)
	projectile.linear_velocity = dir * projectile_speed
	projectile.damage = projectile_damage
	shooting_timer.start(shoot_interval)
	
	stop_attacking()

func take_damage(_damage: float) -> void:
	flash(Color.RED, 0.7, 0.3)

## Flashing
var t_anim: float = 0
var t_anim_goal: float = 0
var c_anim: Color = Color.WHITE

func flash(color: Color, depth: float, duration: float) -> void:
	t_anim_goal = duration
	body.set_instance_shader_parameter("color", color)
	body.set_instance_shader_parameter("depth", depth)


func _on_shooting_area_area_entered(body) -> void:
	#print("hit")
	if body is Player:
		#print("hit player")
		player_in_range = body
		#try_attack()


func _on_shooting_area_area_exited(body) -> void:
	if body == player_in_range:
		player_in_range = null
