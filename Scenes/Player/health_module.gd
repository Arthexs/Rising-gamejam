extends ProgressBar

class_name HealthModule

@export var box: CollisionShape2D
@export var max_health: float = 100.0
@onready var health: float = max_health

signal death()
signal damaged(damage: float)

func _ready() -> void:
	scale_bar()

func _process(delta: float) -> void:
	value = health/max_health * max_value

func take_damage(damage: float) -> void:
	health -= damage
	health = min(health, max_health)
		
	damaged.emit(damage)
	
	if health <= 0.0:
		die()

func scale_bar() -> void:
	var rect: Rect2 = box.shape.get_rect()
	print(rect.position)
	size.x = rect.size.x * 0.7
	global_position = rect.position + box.global_position
	global_position.y -= size.y + 8
	global_position.x += rect.size.x/2 - size.x/2 

func die() -> void:
	death.emit()
	get_parent().queue_free()
