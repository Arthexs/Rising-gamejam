extends RigidBody2D

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@export var nav_agent: NavigationAgent2D
@export var player: Player
@export var acceleration: float = 3.0
@export var max_vel: float = 300.0
@export var friction_coefficient: float = 20 # px/m/s
var movement_force = acceleration * mass * 32 # px/m

@export var impact_threshold: float = 0.6 # Fraction of velocity needed to be lost to be considered impacted
@export var impact_damage_tuner: float = 1.0

var flying: bool = false

var prev_velocity: Vector2 = Vector2.ZERO

var health_module: HealthModule

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	health_module = get_node("HealthModule")
	nav_agent.target_desired_distance = 10.0
	contact_monitor = true
	max_contacts_reported = 8

func set_target(target: Vector2):
	nav_agent.target_position = target
	nav_agent.get_next_path_position()

func _physics_process(delta):
	var delta_vel: float = (linear_velocity - prev_velocity).length()

	if delta_vel/prev_velocity.length() > impact_threshold && flying:
		var force: float = delta_vel/delta * mass
		var damage: float = force/100000
		print("damage taken: ", damage)
		health_module.take_damage(damage)
		linear_velocity = Vector2.ZERO
			#apply_impulse(applied_impulse * 1.0, state.get_contact_collider_position(i))
			#collider.apply_impulse(-applied_impulse, state.get_contact_collider_position(i))
			#print("apply impulse")

	
	set_target(player.global_position)
	if not nav_agent.is_target_reached():
		var direction: Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
		apply_movement(direction)
	
	apply_friction()
	prev_velocity = linear_velocity

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var applied_impulse: Vector2 = Vector2.ZERO
	for i: int in range(get_contact_count()):
		applied_impulse += state.get_contact_impulse(i)
		#print(i)
		var collider: Node2D = state.get_contact_collider_object(i) as Node2D
		#var collider_rid: RID = state.get_contact_collider(i)
		if collider is TileMapLayer:
			print("collided with wall")
		
		if collider is Hammer:
			pass
			#print("collided with hammer")
		
		if collider.is_in_group("enemies"):
			print("collided with enemy")
		

func apply_friction() -> void:
	#print(linear_velocity.length(), "/", max_vel)
	if linear_velocity.length() < max_vel:
		flying = false
		apply_central_force(-linear_velocity.normalized() * friction_coefficient)
	else:
		flying = true
		apply_central_force(-linear_velocity.normalized() * friction_coefficient*0.1)

func apply_movement(direction: Vector2) -> void:
	if flying:
		print("flying")
		return
	
	if direction.dot(linear_velocity) < 0:
		apply_central_force(direction * movement_force*1.5)
	else:
		apply_central_force(direction * movement_force)
