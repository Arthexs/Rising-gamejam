extends RigidBody2D

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@export var nav_agent: NavigationAgent2D
@export var player: Player
@export var acceleration: float = 3.0
@export var max_vel: float = 300.0
@export var friction_coefficient: float = 50 # px/m/s
var movement_force = acceleration * mass * 32 # px/m

@export var force_threshold: float = 300000 # force threshold to be send flying
@export var brake_threshold: float = 0.6 # Fraction of velocity needed to be lost to take damage on impact
@export var damage_tuner: float = 1.0

var mass_max: float
var flying: bool = false

var prev_velocity: Vector2 = Vector2.ZERO

var health_module: HealthModule

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	mass_max = mass
	
	health_module = get_node("HealthModule")
	nav_agent.target_desired_distance = 10.0
	contact_monitor = true
	max_contacts_reported = 8

func set_target(target: Vector2):
	nav_agent.target_position = target
	nav_agent.get_next_path_position()

func _physics_process(delta: float) -> void:
	handle_damage(delta)
	
	set_target(player.global_position)
	if not nav_agent.is_target_reached():
		var direction: Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
		apply_movement(direction)
	
	apply_friction()
	prev_velocity = linear_velocity

func handle_damage(delta: float) -> void:
	var delta_vel: float = linear_velocity.length() - prev_velocity.length()
	
	var force: float = abs(delta_vel)/delta * mass_max
	
	if force > force_threshold:
		var damage: float = force/100000
		print("damage taken: ", damage)
		health_module.take_damage(damage)
		mass = 0.1*mass_max
		#apply_central_force(linear_velocity.normalized() * force)
		flying = true
	
	if prev_velocity.length() != 0:
		#print(delta_vel/prev_velocity.length(), " < ", - (1-brake_threshold))
		if delta_vel/prev_velocity.length() < - (1-brake_threshold) && flying:
			var damage: float = force/100000
			#print("damage taken: ", damage)
			health_module.take_damage(damage)
			linear_velocity = Vector2.ZERO
			mass = mass_max
			flying = false
			#apply_impulse(applied_impulse * 1.0, state.get_contact_collider_position(i))
			#collider.apply_impulse(-applied_impulse, state.get_contact_collider_position(i))
			#print("apply impulse")

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#var applied_impulse: Vector2 = Vector2.ZERO
	#for i: int in range(get_contact_count()):
		#applied_impulse += state.get_contact_impulse(i)
		##print(i)
		#var collider: Node2D = state.get_contact_collider_object(i) as Node2D
		##var collider_rid: RID = state.get_contact_collider(i)
		#if collider is TileMapLayer:
			#pass
			##print("collided with wall")
		#
		#if collider is Hammer:
			#pass
			##print("collided with hammer")
		#
		#if collider.is_in_group("enemies"):
			#pass
			##print("collided with enemy")
		#

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
		print("flying")
		return
	
	if direction.dot(linear_velocity) < 0:
		apply_central_force(direction * movement_force*1.5)
	else:
		apply_central_force(direction * movement_force)
