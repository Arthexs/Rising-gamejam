extends Sprite2D

class_name BaseItem

#@export var player: Player
@export var interaction_range: CollisionShape2D
@export var player: Player

var cost: int = 10
var text: String = "Test item  with  text"
var fade_time: float = 0.4

var placed_label_position: Vector2

var is_showing: bool = false


func effect() -> void:
	player.flash(Color.WEB_GREEN, 0.6, 0.4)
	remove_self()

func remove_self() -> void:
	remove_label()
	queue_free()

func remove_label() -> void:
	if is_showing:
		is_showing = false
		Globals.popup_manager.remove_label(placed_label_position.x, placed_label_position.y)

func make_label() -> void:
	if not is_showing:
		is_showing = true
		placed_label_position = global_position - Vector2(0, interaction_range.shape.get_rect().size.y/2*scale.y)
		Globals.popup_manager.place_label(placed_label_position.x, placed_label_position.y, text, fade_time)
