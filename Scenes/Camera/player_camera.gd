extends Camera2D

@export var tracking_object: Node2D
var starting_size: Vector2

var base_zoom: Vector2 = zoom

func _ready() -> void:
	starting_size = get_viewport_rect().size

func _process(delta: float) -> void:
	do_cam_movement()

var shake_offset: Vector2 = Vector2.ZERO
var shake_magnitude: float = 1
var max_magnitude: float = 1
var ticks: int = 0
var tick_goal: int = 0

func shake_cam(magnitude: float, duration: float) -> void:
	#print("shake")
	ticks = 0
	tick_goal = int(duration/get_physics_process_delta_time())
	max_magnitude = magnitude
	shake_magnitude = max_magnitude

func do_cam_movement() -> void:
	position = tracking_object.global_position
	
	if ticks < tick_goal:
		offset = shake_magnitude * Vector2.UP.rotated(randf())
		
		ticks += 1
		shake_magnitude = (1-sin(PI/2*ticks/tick_goal))*max_magnitude

func limit_to_room(room: Room) -> void:
	var rect: Rect2i = room.tilemap.get_used_rect()
	
	var screen_zoom: Vector2 = starting_size / Vector2((rect.size- Vector2i(1, 0)) * Globals.tile_size)
	screen_zoom = screen_zoom.max(base_zoom)
	
	var upper_bound_zoom: float = max(screen_zoom.x, screen_zoom.y)
	
	zoom = Vector2(upper_bound_zoom, upper_bound_zoom)
	#zoom = screen_zoom
	
	var room_position: Vector2i = (rect.position + room.offset) * Globals.tile_size
	limit_top = room_position.y
	limit_left = room_position.x
	limit_bottom = room_position.y + rect.size.y * Globals.tile_size
	limit_right = room_position.x + (rect.size.x - 1) * Globals.tile_size
