extends NavigationRegion2D

class_name Room

@export var tilemap: TileMapLayer

var door_connections: Array[Vector4i] = []
var door_cells_positions: Array[Vector2i] = []
var door_cell_connections: Array[int]
var offset: Vector2i = Vector2i.ZERO
var disabled_connection: int = -1

func _ready() -> void:
	set_door_connections()
	assert(door_connections.size() != 0)

## Returns [pos_x, pos_y, direction, length]
func set_door_connections() -> void:
	var i_door: int = -1 # Index in door_connections
	
	var door_positions: Array[Vector3i] = get_door_tile_positions()
	door_positions = sort_door_tiles(door_positions)
	door_cells_positions.clear()
	for cell: Vector3i in door_positions:
		door_cells_positions.append(Vector2i(cell.x, cell.y))
	
	
	
	var i_prev: int = 0 # Previous index in door_positions
	var i_now: int = -1 # Current index in door_positions
	
	while i_now < door_positions.size() - 1:
		i_now += 1
		
		if Vector2i(door_positions[i_now].x, door_positions[i_now].y) == Vector2i(19, 0):
			pass
		
		if (Vector2i(door_positions[i_prev].x, door_positions[i_prev].y) - Vector2i(door_positions[i_now].x, door_positions[i_now].y)).length_squared() == 1:
			var door_position: Vector2i = Vector2i(door_connections[i_door].x, door_connections[i_door].y)
			door_position = Vector2i(door_positions[i_now].x, door_positions[i_now].y).min(door_position)
			door_connections[i_door].x = door_position.x
			door_connections[i_door].y = door_position.y
			door_connections[i_door].w += 1
		else:
			i_door += 1
			door_connections.append(Vector4i(door_positions[i_now].x, door_positions[i_now].y, door_positions[i_now].z, 1))
		
		door_cell_connections.append(i_door)
		i_prev = i_now
	
	# Get tile position and what wall (x, y, enum Globals.Direction)
func get_door_tile_positions() -> Array[Vector3i]:
	var door_positions: Array[Vector3i]
	
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	for cell: Vector2i in tilemap.get_used_cells():
		if tilemap.get_cell_tile_data(cell).get_custom_data("Door"):
			for i_search: int in range(4):
				if tilemap.get_cell_tile_data(cell + directions[i_search]) == null:
					door_positions.append(Vector3i(cell.x, cell.y, i_search))
					break
	
	return door_positions
			#door_cells.append(cell)
	
	#for cell: Vector2i
	
	#var first_cell_pos: Vector2i = tilemap.get_used_cells()[0]
	#var cell_pos: Vector2i = first_cell_pos
	#var start: bool = true
	#var wall_found: bool = false
	#
	#var search_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT]
	#var i_search: int = 0
	#
	#var is_door: bool = false
	#
	#while cell_pos != first_cell_pos || start:
		#i_search -= 1
		#
		#cell_pos += search_directions[i_search]
		##print("search cell_pos: ", cell_pos)
		#
		#var cell: TileData = tilemap.get_cell_tile_data(cell_pos)
		#if cell == null:
			#cell_pos -= search_directions[i_search]
			#i_search += 2
			#continue
		#
		#start = false
#
		#is_door = cell.get_custom_data("Door") as bool
		#
		#if is_door:
			#door_cells_positions.append(cell_pos)
			#
			#var opening: Globals.directions
			#match (Vector2i(Transform2D.IDENTITY.rotated(-PI/2) * Vector2(search_directions[i_search]))):
				#Vector2i.UP:
					#opening = Globals.directions.UP
				#Vector2i.RIGHT:
					#opening = Globals.directions.RIGHT
				#Vector2i.DOWN:
					#opening = Globals.directions.DOWN
				#_:
					#opening = Globals.directions.LEFT
				#
			#door_positions.append(Vector3i(cell_pos.x, cell_pos.y, opening))
		#
	#
	#return door_positions

func sort_door_tiles(pos: Array[Vector3i]) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	
	var up_doors: Array[Vector3i] = []
	var right_doors: Array[Vector3i] = []
	var down_doors: Array[Vector3i] = []
	var left_doors: Array[Vector3i] = []
	
	for cell: Vector3i in pos:
		match cell.z as Globals.directions:
			Globals.directions.UP:
				up_doors.append(cell)
			Globals.directions.RIGHT:
				right_doors.append(cell)
			Globals.directions.DOWN:
				down_doors.append(cell)
			_: # Left
				left_doors.append(cell)
	
	up_doors.sort_custom(vector_x_ascend)
	right_doors.sort_custom(vector_y_ascend)
	down_doors.sort_custom(vector_x_descend)
	left_doors.sort_custom(vector_y_descend)
	
	result.append_array(up_doors)
	result.append_array(right_doors)
	result.append_array(down_doors)
	result.append_array(left_doors)
	
	return result

func vector_x_ascend(a: Vector3i, b: Vector3i) -> bool:
	return a.x < b.x
func vector_x_descend(a: Vector3i, b: Vector3i) -> bool:
	return a.x > b.x
func vector_y_ascend(a: Vector3i, b: Vector3i) -> bool:
	return a.x < b.x
func vector_y_descend(a: Vector3i, b: Vector3i) -> bool:
	return a.x < b.x

func rid_is_stairs(rid: RID) -> bool:
	if not tilemap.has_body_rid(rid): 
		return false
	else:
		var tile_data: TileData = tilemap.get_cell_tile_data(tilemap.get_coords_for_body_rid(rid))
		return tile_data.get_custom_data("Stair") as bool

func rid_is_door(rid: RID) -> bool:
	if not tilemap.has_body_rid(rid): 
		return false
	else:
		return door_cells_positions.has(tilemap.get_coords_for_body_rid(rid))

func door_connection_is_valid_for_rid(rid: RID) -> bool:
	var door_index: int = door_cells_positions.find(tilemap.get_coords_for_body_rid(rid))
	return door_cell_connections[door_index] != disabled_connection

func get_door_connection_for_rid(rid: RID) -> Vector4i:
	var door_index: int = door_cells_positions.find(tilemap.get_coords_for_body_rid(rid))
	return door_connections[door_cell_connections[door_index]]
