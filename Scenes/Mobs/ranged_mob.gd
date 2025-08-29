extends RigidBody2D

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@export var nav_agent: NavigationAgent2D
@export var player: Player
@export var acceleration: float = 10.0
var movement_force = acceleration * mass

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	nav_agent.target_desired_distance = 10.0

func set_target(target: Vector2):
	nav_agent.target_position = target
	nav_agent.get_next_path_position()

func _physics_process(delta):
	set_target(player.global_position)
	if not nav_agent.is_target_reached():
		var direction: Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
		print(player.global_position)
		print(nav_agent.get_next_path_position())
		print(global_position)
		
		apply_movement(direction)

func apply_movement(direction: Vector2) -> void:
	if direction.dot(linear_velocity) < 0:
		apply_central_force(direction * movement_force*1.5)
	else:
		apply_central_force(direction * movement_force)
