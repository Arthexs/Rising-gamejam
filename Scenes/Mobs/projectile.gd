extends RigidBody2D

@export var speed: float = 600.0
@export var damage: float = 10.0
var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Auto-free after a few seconds to prevent memory leaks
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	linear_velocity = velocity

func set_velocity(v: Vector2):
	velocity = v
	linear_velocity = v

func _on_body_entered(body: Node) -> void:
	if body is Player:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("walls"): # optional
		queue_free()
