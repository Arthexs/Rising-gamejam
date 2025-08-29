extends RigidBody2D

class_name MeleeMob

#@export var speed: float = 50.0
@export var agent: NavigationAgent2D
@export var player: Player
@export var damage: float = 10.0

@export var force_threshold: float = 170000 # force threshold to be send flying
@export var brake_threshold: float = 0.6 # Fraction of velocity needed to be lost to take damage on impact
@export var damage_tuner: float = 1.0
@export var friction_coefficient: float = 25 # px/m/s
@export var acceleration: float = 1.5
var movement_force = acceleration * mass * 32 # px/m

@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

signal death()

#var speed_scalar: float = 200.0
var player_in_range: Player = null

var health_module: HealthModule
var prev_velocity: Vector2 = Vector2.ZERO
var mass_max: float = mass
var flying: bool = false
#@export var force_threshold: float = 300000 # force threshold to be send flying
#@export var brake_threshold: float = 0.6 # Fraction of velocity needed to be lost to take damage on impact
#@export var damage_tuner: float = 1.0

func _ready() -> void:
	mass_max = mass
	health_module = get_node("HealthModule")
	
	agent.target_desired_distance = 10
	set_target(player.global_position)
	
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	#attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.one_shot = true

func set_target(target_position: Vector2):
	agent.target_position = target_position
	agent.get_next_path_position()

func _physics_process(delta: float) -> void:
	handle_damage(delta)
	
	set_target(player.global_position)
	if not agent.is_target_reached():
		var direction: Vector2 = (agent.get_next_path_position() - global_position).normalized()
		apply_movement(direction)
	
	apply_friction()
	prev_velocity = linear_velocity
	
func handle_damage(delta: float) -> void:
	var delta_vel: float = linear_velocity.length() - prev_velocity.length()
	
	var force: float = abs(delta_vel)/delta * mass_max
	#print("force: ", force)
	if force > force_threshold:
		var damage: float = force/100000 * damage_tuner
		#print("damage taken: ", damage)
		health_module.take_damage(damage)
		mass = 0.1*mass_max
		#apply_central_force(linear_velocity.normalized() * force)
		flying = true
	
	if prev_velocity.length() != 0:
		#print(delta_vel/prev_velocity.length(), " < ", - (1-brake_threshold))
		if delta_vel/prev_velocity.length() < - (1-brake_threshold) && flying:
			var damage: float = force/100000 * damage_tuner
			#print("damage taken: ", damage)
			health_module.take_damage(damage)
			linear_velocity = Vector2.ZERO
			mass = mass_max
			flying = false
	
	prev_velocity = linear_velocity

func _on_attack_area_body_entered(body):
	if body is Player:
		player_in_range = body
		try_attack()

func _on_attack_area_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		
func try_attack():
	if player_in_range and attack_timer.is_stopped():
		player_in_range.take_damage(damage)
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	try_attack()

func died() -> void:
	death.emit()

func apply_friction() -> void:
	#print(linear_velocity.length(), "/", max_vel)
	if flying:
		#flying = false
		apply_central_force(-linear_velocity.normalized() * friction_coefficient*0.1)
	else:
		apply_central_force(-linear_velocity.normalized() * friction_coefficient)
		#flying = true

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
