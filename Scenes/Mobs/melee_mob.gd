extends RigidBody2D

class_name MeleeMob

#@export var speed: float = 50.0
@export var agent: NavigationAgent2D
@export var player: Player
@export var attack_power: float = 10.0
@export var attack_interval: float = 1.0
@onready var _animated_sprite = $AnimatedSprite2D

@export var force_threshold: float = 155000 # force threshold to be send flying
@export var brake_threshold: float = 0.6 # Fraction of velocity needed to be lost to take damage on impact
@export var damage_tuner: float = 2.0
@export var friction_coefficient: float = 25 # px/m/s
@export var acceleration: float = 1.5
@export var max_velocity: float = 80
var movement_force = acceleration * mass * 32 # px/m

@onready var moving_player: AudioStreamPlayer = ($Audio/Moving as AudioStreamPlayer)
@onready var death_player: AudioStreamPlayer = ($Audio/Death as AudioStreamPlayer)
@onready var bash_player: AudioStreamPlayer = ($Audio/Bash as AudioStreamPlayer)


@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

signal death(MeleeMob)

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
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = true

func take_damage(_damage: float) -> void:
	flash(Color.RED, 0.7, 0.3)
	#print("took damage")

func _process(delta: float) -> void:
	do_animation(delta)

## Flashing
var t_anim: float = 0
var t_anim_goal: float = 0
var c_anim: Color = Color.WHITE

func do_animation(delta: float) -> void:
	if t_anim_goal != 0:
		t_anim += delta
		_animated_sprite.set_instance_shader_parameter("t", t_anim/t_anim_goal)
		if t_anim >= t_anim_goal:
			t_anim_goal = 0
			t_anim = 0

func flash(color: Color, depth: float, duration: float) -> void:
	t_anim_goal = duration
	_animated_sprite.set_instance_shader_parameter("color", color)
	_animated_sprite.set_instance_shader_parameter("depth", depth)

func set_target(target_position: Vector2):
	agent.target_position = target_position
	agent.get_next_path_position()

func _physics_process(delta: float) -> void:
	handle_damage(delta)
	
	set_target(player.global_position)
	if not agent.is_target_reached() and agent.distance_to_target() < Globals.vision_radius:
		var direction: Vector2 = (agent.get_next_path_position() - global_position).normalized()
		apply_movement(direction)
		_animated_sprite.play("move")
	else :
		_animated_sprite.play("idle")
	if linear_velocity.x < -Globals.flip_velocity: # moving left
		_animated_sprite.flip_h = true
	elif linear_velocity.x > Globals.flip_velocity: # moving right
		_animated_sprite.flip_h = false
	apply_friction()
	prev_velocity = linear_velocity
	
	if linear_velocity.length() > Globals.flip_velocity:
		if not moving_player.playing:
			moving_player.play()
	else:
		if moving_player.playing:
			moving_player.stop()
	#print(abs(prev_velocity.length()))
	
func handle_damage(delta: float) -> void:
	var delta_vel: float = linear_velocity.length() - prev_velocity.length()
	#print("dv: ", abs(delta_vel))
	
	var force: float = abs(delta_vel)/delta * mass_max
	#print("force: ", force)
	if player.is_hitting:
		var damage: float = force/25000 * damage_tuner
		#print(damage)
		if damage > 5:
			health_module.take_damage(damage*0.6)
			if not bash_player.playing:
				#print("Bashed")
				bash_player.play()
			if force > force_threshold and player.is_hitting:
				health_module.take_damage(damage*0.4)
				#player.
				#print("damage taken: ", damage)
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

func _on_attack_area_body_entered(body):
	if body is Player:
		player_in_range = body
		try_attack()

func _on_attack_area_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		
func try_attack():
	if player_in_range and attack_timer.is_stopped():
		player_in_range.take_damage(attack_power)
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	try_attack()

func died() -> void:
	death.emit(self)
	
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
	linear_velocity = linear_velocity.limit_length(max_velocity)
