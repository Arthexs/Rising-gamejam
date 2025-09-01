extends AudioStreamPlayer

func _ready() -> void:
	play()

func _process(delta: float) -> void:
	if not playing:
		queue_free()
