extends Control
@export var label: Label

var t: float = 0
var h_bob: float = 10
var offset: float = 0
var fade_rate: float = 255.0/200.0
var delay: float = 2
@onready var start: Vector2 = label.global_position
@onready var music_player: AudioStreamPlayer = ($Music as AudioStreamPlayer)


func _ready() -> void:
	music_player.play()

func _process(delta: float) -> void:
	t += delta
	if t > delay:
		#print("game over processw")
		offset = h_bob * sin(PI/2*(t-delay))
		
		label.global_position = start + Vector2(0, offset)
		label.modulate.a8 = min(255, label.modulate.a8 + fade_rate)
		#print(label.modulate.a8)
		if Input.is_anything_pressed():
			get_tree().reload_current_scene()
			
		#print(label.modulate.a)
