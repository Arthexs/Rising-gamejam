extends Node2D

@export var max_health: float = 100.0
var health: float = max_health

signal death()
signal damaged(damage: float)

func take_damage(damage: float) -> void:
	health -= damage
	health = min(health, max_health)
	
	damaged.emit(damage)
	
	if health <= 0.0:
		die()

func die() -> void:
	death.emit()
	get_parent().queue_free()
