extends RigidBody2D

@export var speed: float = 200.0
@export var agent: NavigationAgent2D
@export var playerchar: CharacterBody2D
var path: PackedVector2Array = []
var current_point_index: int = 0
var speed_scalar: float = 1000.0

func _ready() -> void:
	agent.target_desired_distance = 10
	set_target(playerchar.global_position)

func set_target(target_position: Vector2):
	agent.target_position = target_position
	agent.get_next_path_position()

func _physics_process(delta):
	set_target(playerchar.global_position)
	if not agent.is_target_reached():
		var target_point: Vector2 = agent.get_next_path_position()
		var dir: Vector2 = (target_point - global_position).normalized()
		apply_central_force(dir*speed_scalar)
		var distance = global_position.distance_to(target_point)
		#print("direction", dir, "target", target_point, "mob", global_position)
