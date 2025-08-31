extends AnimatedSprite2D

class_name SummoningProjectile

#@export var summoning_circle: AnimatedSprite2D
#@export var projectile_scene: PackedScene

func _ready() -> void:
	play("Summon")

func _on_animation_finished() -> void:
	print("end animation")
	queue_free()
	#pass # Replace with function body.
