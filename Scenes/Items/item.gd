extends Sprite2D

class_name BaseItem

#@export var player: Player
@export var interaction_range: CollisionShape2D
@export var description_label: Label
var cost: int = 10
var text: String = "Test item with text"
var fade_time: float = 0.4

var placed_label_position: Vector2

var is_showing: bool = false



func _ready() -> void:
	print("get position")
	print(interaction_range.shape.get_rect().position)
	#print(position)
	print(global_position)
	#print("printed")
	#description_label.text = text

#func _process(delta: float) -> void:
	# Reparent label to top layer if not done already
	#if description_label.get_parent() is BaseItem:
		#for node: Node in get_tree().root.get_children():
			#if node.name == "Main":
				#description_label.position = Vector2.ZERO
				##print(description_label.position)
				##var prev_transform: Transform2D = node.position
				##print(prev_transform)
				#description_label.reparent(node)
				##description_label.position = Vector2.ZERO
				#print(description_label.position)
				#print(description_label.get_parent().name)
				#description_label.move_to_front()
				#print(description_label)
		#print(description_label.text)

func remove_label() -> void:
	if is_showing:
		print("removing shown label at", placed_label_position)
		is_showing = false
		Globals.popup_manager.remove_label(placed_label_position.x, placed_label_position.y)

func make_label() -> void:
	if not is_showing:
		is_showing = true
		placed_label_position = global_position - Vector2(0, interaction_range.shape.get_rect().size.y/2*scale.y)
		print("placed at: ", placed_label_position)
		Globals.popup_manager.place_label(placed_label_position.x, placed_label_position.y, text, fade_time)
