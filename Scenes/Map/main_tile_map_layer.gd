extends Node2D

class_name RoomsManager

@export var player: Player
@export var mob_scene: PackedScene
var spawnable_rooms: Array[Room]

var active_room: Room
var previous_room: Room

signal change_room(room: Room)

func _ready() -> void:
	spawnable_rooms.append_array(get_node("Level1").get_children() as Array[Room])
	
	active_room = get_node("Special/RoomStart").duplicate()
	active_room.visible = true
	add_child(active_room)
	
	change_room.emit(active_room)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hurtbox_hit(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# Do door logic
	check_door(body_rid)

# Performs door logic based on collision drid (if rid belongs to door cell will perform door logic of said cell)
func check_door(rid: RID) -> void:
	if active_room.rid_is_door(rid):
		if active_room.door_connection_is_valid_for_rid(rid):
			var door_connection: Vector4i = active_room.get_door_connection_for_rid(rid)
			var door_position: Vector2i = Vector2i(door_connection.x, door_connection.y) + active_room.offset
			
			if previous_room != null: previous_room.queue_free()
			previous_room = active_room
			
			while active_room == previous_room:
				var i_room: int = randi()%(spawnable_rooms.size())
				
				var i_connection:InternalMode = get_matching_connection_index(door_connection, i_room)
				if i_connection < 0: 
					continue
				
				var room_connection: Vector4i = spawnable_rooms[i_room].door_connections[i_connection]
				var room_connection_pos: Vector2i = Vector2i(room_connection.x, room_connection.y)
				
				var offset_pos: Vector2i = door_position - room_connection_pos
				active_room = spawnable_rooms[i_room].duplicate()
				active_room.disabled_connection = i_connection
				active_room.offset = offset_pos
				active_room.visible = true
				active_room.global_position = offset_pos * Globals.tile_size
				add_child(active_room)
				
				change_room.emit(active_room)
				spawn_mobs(2)

# searches for connection from given connection. Returns -1 if invalid
func get_matching_connection_index(connection: Vector4i, i_room: int) -> int:
	var i: int = -1
	for room_connection: Vector4i in spawnable_rooms[i_room].door_connections:
		i += 1
		
		if room_connection.w != connection.w: # check sizes
			continue
		
		if abs(room_connection.z - connection.z) != 2: # check directions are oposite
			continue
		
		return i
	
	return -1
	
func spawn_mobs(difficulty: int) -> void:
	var activeTiles: Array[Vector2i] = active_room.tilemap.get_used_cells()
	var selectedTiles: Array[Vector2i]
	for i in range(difficulty):
		var i_tile: int = randi() % activeTiles.size()
		var cell_pos: Vector2i = activeTiles[i_tile]
		var pos: Vector2 = (active_room.offset + cell_pos) * Globals.tile_size
		var mob = mob_scene.instantiate()
		mob.global_position = pos
		add_child(mob)
