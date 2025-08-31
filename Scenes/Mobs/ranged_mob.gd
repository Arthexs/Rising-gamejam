extends RigidBody2D

class_name RangedMob

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

@export var projectile_scene: PackedScene
@export var shoot_interval: float = 1000
@export var projectile_speed: float = 1.0
@export var projectile_damage: float = 1.0

signal death()

var player_in_range: Player = null

var health_module: HealthModule
var prev_velocity: Vector2 = Vector2.ZERO
var mass_max: float = mass
var flying: bool = false

@onready var shooting_timer = $ShootingTimer
@onready var shooting_area = $ShootingArea
@onready var collision_shape = $ShootingArea/CollisionShape2D

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

func set_target(target_position: Vector2):
	agent.target_position = target_position
	agent.get_next_path_position()

func _physics_process(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	var distance = to_player.length()
	var direction: Vector2 = to_player.normalized()
	
	handle_damage(delta)
	
	# Decide behavior based on distance
	if distance > preferred_distance + tolerance:
		# Too far → move closer
		apply_movement(direction)
	elif distance < preferred_distance - tolerance:
		# Too close → move away
		apply_movement(-direction)
	else:
		# In range → apply friction so it stops
		apply_friction()
	
	prev_velocity = linear_velocity
	try_attack()
	
func handle_damage(delta: float) -> void:
	var delta_vel: float = linear_velocity.length() - prev_velocity.length()
	
	var force: float = abs(delta_vel)/delta * mass_max
	
	#print("force on ranged: ", force, "/", force_threshold)
	
	if force > force_threshold:
		var damage: float = force/25000 * damage_tuner
		#print("damage taken: ", damage, " | ", force/25000, "*", damage_tuner)
		health_module.take_damage(damage)
		mass = 0.1*mass_max
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


func try_attack():
	if player_in_range and shooting_timer.is_stopped():
		shoot_projectile()
		shooting_timer.start()

func _on_attack_timer_timeout() -> void:
	try_attack()

func died() -> void:
	death.emit()

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
	if not projectile_scene or not player_in_range:
		return

	var dir = (player_in_range.global_position - global_position).normalized()
	var projectile = projectile_scene.instantiate()
	
	projectile.global_position = global_position
	projectile.rotation = dir.angle()

	# Apply velocity if available
	projectile.linear_velocity = dir * projectile_speed
	projectile.damage = projectile_damage

	get_parent().add_child(projectile)

func _on_shooting_area_area_entered(body) -> void:
	if body is Player:
		player_in_range = body
		try_attack()


func _on_shooting_area_area_exited(body) -> void:
	if body == player_in_range:
		player_in_range = null
