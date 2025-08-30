extends RigidBody2D

@export var speed: float = 200.0
@export var damage: float = 10.0
#var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Auto-free after a few seconds to prevent memory leaks
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	pass

func _on_projectile_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
		queue_free()
