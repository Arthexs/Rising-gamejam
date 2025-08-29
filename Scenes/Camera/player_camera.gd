extends Camera2D

@export var tracking_object: Node2D
var starting_size: Vector2

func _ready() -> void:
	starting_size = get_viewport_rect().size

func _process(delta: float) -> void:
	position = tracking_object.global_position

func limit_to_room(room: Room) -> void:
	var rect: Rect2i = room.get_used_rect()
	
	var screen_zoom: Vector2 = starting_size / Vector2((rect.size- Vector2i(1, 0)) * Globals.tile_size)
	screen_zoom = screen_zoom.max(Vector2.ONE)
	
	var upper_bound_zoom: float = max(screen_zoom.x, screen_zoom.y)
	
	zoom = Vector2(upper_bound_zoom, upper_bound_zoom)
	#zoom = screen_zoom
	
	var room_position: Vector2i = (rect.position + room.offset) * Globals.tile_size
	limit_top = room_position.y
	limit_left = room_position.x
	limit_bottom = room_position.y + rect.size.y * Globals.tile_size
	limit_right = room_position.x + (rect.size.x - 1) * Globals.tile_size
