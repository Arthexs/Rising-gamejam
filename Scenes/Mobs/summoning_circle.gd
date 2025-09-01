extends AnimatedSprite2D

class_name SummoningProjectile

#@export var summoning_circle: AnimatedSprite2D
#@export var projectile_scene: PackedScene

@onready var summoning_player: AudioStreamPlayer = ($Summoning as AudioStreamPlayer)


func _ready() -> void:
	play("Summon")
	summoning_player.play()

func _on_animation_finished() -> void:
	print("end animation")
	queue_free()
	#pass # Replace with function body.
