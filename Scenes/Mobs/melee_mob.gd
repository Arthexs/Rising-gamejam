extends RigidBody2D

@export var speed: float = 200.0
@export var agent: NavigationAgent2D
@export var playerchar: CharacterBody2D
@export var damage: float = 10.0

@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

var player_in_range: Player = null
var path: PackedVector2Array = []
var current_point_index: int = 0
var speed_scalar: float = 1000.0

func _ready() -> void:
	agent.target_desired_distance = 10
	set_target(playerchar.global_position)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.one_shot = true

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

func _on_attack_area_body_entered(body):
	if body is Player:
		player_in_range = body
		try_attack()

func _on_attack_area_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		
func try_attack():
	if player_in_range and attack_timer.is_stopped():
		#player_in_range.take_damage(damage)
		attack_timer.start()

func _on_attack_timer_timeout() -> void:
	try_attack()
