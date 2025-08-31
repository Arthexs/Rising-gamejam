extends Control

class_name PopupManager

@export var popup_packed_scene: PackedScene

var popups: Array[Label] = []
var popups_fade_rate: Array[int] = []
var popups_is_showing: Array[int] = []

var label_correction: Vector2

func _ready() -> void:
	var label_scene: Label = popup_packed_scene.instantiate()
	label_correction = label_scene.size*label_scene.scale - Vector2(label_scene.size.x/2*label_scene.scale.x, 0) #-label_scene.position
	#print(label_correction)

func place_label(x: float, y: float, text: String, fade_time: float) -> void:
	var pos: Vector2 = Vector2(x, y) - label_correction
	
	var label: Label = popup_packed_scene.instantiate()
	
	label.set_global_position(pos)
	label.text = text
	
	add_child(label)
	popups.append(label)
	
	var fade_rate: int = int(255/(fade_time/get_physics_process_delta_time()))
	popups_fade_rate.append(fade_rate)
	
	popups_is_showing.append(fade_rate)

func remove_label(x: float, y: float) -> void:
	var pos: Vector2 = Vector2(x, y) - label_correction
	for i: int in range(popups.size()):
		var label: Label = popups[i]
		var epsilon: float = 0.001
		if label.global_position.distance_squared_to(pos) <= epsilon:
			popups_is_showing[i] = false

func _physics_process(delta: float) -> void:
	var i: int = 0
	while i < popups.size():
		var label: Label = popups[i]
		if popups_is_showing[i]:
			label.modulate.a8 += popups_fade_rate[i]
			min(label.modulate.a8, 255)
		else:
			label.modulate.a8 -= popups_fade_rate[i]
			if label.modulate.a8 <= 0:
				delete_label(i)
				i -= 1
		i += 1

func delete_label(i: int) -> void:
	var label: Label = popups[i]
	popups.remove_at(i)
	popups_fade_rate.remove_at(i)
	popups_is_showing.remove_at(i)
	label.queue_free()
