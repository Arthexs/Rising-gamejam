extends RigidBody2D

class_name FireBall

#@export var speed: float = 200.0
@export var damage: float = 10.0
var pulse_size: float = 0.5
var t: float = 0
#var velocity: Vector2 = Vector2.ZERO
var fuck: bool = true

func _ready():
	# Auto-free after a few seconds to prevent memory leaks
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta: float) -> void:
	t += delta
	var size: float = 1 + pulse_size*sin(t*2*PI)
	if not fuck:
		scale = Vector2(size, size)
	fuck = not fuck
	#print(scale)

#func _physics_process(delta: float) -> void:
	#move_and_collide(linear_velocity*delta)
	#print(linear_velocity)
	#pass

func _on_projectile_area_body_entered(body: Node2D) -> void:
	#print("projectile hit")
	if body is Player:
		body.take_damage(damage)
		queue_free()
