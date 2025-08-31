extends Node2D

class_name SummoningProjectile

@export var summoning_circle: AnimatedSprite2D
@export var projectile_scene: PackedScene

func _ready() -> void:
	summoning_circle.play("Summon")

func spawn_projectile() -> void:
	queue_free()
