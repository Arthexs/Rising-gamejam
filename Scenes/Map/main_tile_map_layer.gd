extends TileMapLayer

@export var player: Player

var spawnable_rooms: Array[Room]

func _ready() -> void:
	spawnable_rooms.append_array(((get_node("Rooms") as Node2D).get_children()) as Array[Room])
	
	print(spawnable_rooms.size())
