extends Camera2D

@export var tracking_object: Node2D

func _process(delta: float) -> void:
	position = tracking_object.global_position
