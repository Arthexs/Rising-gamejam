extends TileMapLayer

@export var player: Player
var spawnable_rooms: Array[Room]

var active_room: Room
var previous_room: Room

func _ready() -> void:
	spawnable_rooms.append_array(((get_node("Rooms") as Node2D).get_children()) as Array[Room])
	
	active_room = spawnable_rooms[0].duplicate()
	active_room.visible = true
	add_child(active_room)

#func _physics_process(delta: float) -> void:
	#door_interaction()

#func door_interaction() -> void:
	#var collision_rids: Array[RID] = player.get_collision_rids()
	#for rid: RID in collision_rids:
		#if not active_room.has_body_rid(rid): continue
#
		#if active_room.door_cells_positions.has(active_room.get_coords_for_body_rid(rid)):
			#print("hit door")


func _on_player_hurtbox_hit(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# Do door logic
	check_door(body_rid)

# Performs door logic based on collision rid (if rid belongs to door cell will perform door logic of said cell)
func check_door(rid: RID) -> void:
	if active_room.rid_is_door(rid):
		if active_room.door_connection_is_valid_for_rid(rid):
			var door_connection: Vector4i = active_room.get_door_connection_for_rid(rid)
			var door_position: Vector2i = Vector2i(door_connection.x, door_connection.y) + active_room.offset
			
			if previous_room != null: previous_room.queue_free()
			previous_room = active_room
			
			while active_room == previous_room:
				var i_room: int = randi()%(spawnable_rooms.size()) # TODO: Exclude 'special' rooms
				
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
