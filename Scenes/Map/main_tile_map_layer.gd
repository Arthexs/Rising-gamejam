extends Node2D

class_name RoomsManager

@export var player: Player
#@export var mob_scene: PackedScene
@export var rocks: CPUParticles2D
@export var min_spawn_distance: float = 160
@onready var rocks_player: AudioStreamPlayer = ($Audio/Rocks as AudioStreamPlayer)

#var spawnable_rooms: Array[Room]

signal do_screenshake(magnitude: float, duration: float)
signal spawned_mobs(mobs: Array[RigidBody2D])
signal game_end(win: bool)

var active_room: Room
var previous_room: Room
var active_room_name: String

signal change_room(room: Room)
signal added_monsters()

func _ready() -> void:
	#spawnable_rooms.append_array(get_node("Level1").get_children() as Array[Room])
	
	active_room_name = "starter_room"
	active_room = (Globals.special_rooms[active_room_name] as PackedScene).instantiate()
	
	#active_room = get_node("Special/Room0Start").duplicate()
	active_room.visible = true
	get_node("ActiveRooms").add_child(active_room)
	
	change_room.emit(active_room)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_hurtbox_hit(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# Do door logic
	check_door(body_rid)
	check_stairs(body_rid)

func check_stairs(rid: RID) -> void:
	if active_room.rid_is_stairs(rid):
		game_end.emit(true)

# Performs door logic based on collision drid (if rid belongs to door cell will perform door logic of said cell)
func check_door(rid: RID) -> void:
	if active_room.rid_is_door(rid):
		if active_room.door_connection_is_valid_for_rid(rid):
			var door_connection: Vector4i = active_room.get_door_connection_for_rid(rid)
			var door_position: Vector2i = Vector2i(door_connection.x, door_connection.y) + active_room.offset
			
			if previous_room != null: previous_room.queue_free()
			previous_room = active_room
			
			while active_room == previous_room:
				var room_name: String = active_room_name
				while room_name == active_room_name:
					room_name = Globals.pick_weighted_random(Globals.level_spawn_rates)
				
				var room: PackedScene = Globals.level_scenes[room_name]
				var room_scene: Room = room.instantiate()
				get_node("ActiveRooms").add_child(room_scene)
				
				#var i_room: int = randi()%(spawnable_rooms.size())
				
				var i_connection: int = get_matching_connection_index(door_connection, room_scene)
				if i_connection < 0: 
					room_scene.queue_free()
					#print("no connections")
					continue
				
				var room_connection: Vector4i = room_scene.door_connections[i_connection]
				var room_connection_pos: Vector2i = Vector2i(room_connection.x, room_connection.y)
				
				## Delete enemies
				for child: Node in active_room.get_children():
					if Globals.mob_scene_names.has(child.name):
						#print("found mob: ", child.name)
						child.queue_free()
				
				var offset_pos: Vector2i = door_position - room_connection_pos
				active_room = room_scene
				active_room.disabled_connection = i_connection
				active_room.offset = offset_pos
				active_room.visible = true
				active_room.global_position = offset_pos * Globals.tile_size
				#get_node("ActiveRooms").(active_room)
				#room_scene.queue_free()
				
				entering_room(door_connection)
				change_room.emit(active_room)

# searches for connection from given connection. Returns -1 if invalid
func get_matching_connection_index(connection: Vector4i, room: Room) -> int:
	#print(room.door_connections.size())

	var i: int = -1
	for room_connection: Vector4i in room.door_connections:
		i += 1 # connection index
		
		if room_connection.w != connection.w: # check sizes
			#print("in-compatible size")
			continue
		
		if abs(room_connection.z - connection.z) != 2: # check directions are oposite
			#print("in-compatible direction")
			continue
		
		return i
	
	return -1

func entering_room(connection: Vector4i) -> void:
	var mob_max: int = Globals.minimum_mobs_in_room + tanh((float(Globals.difficulty)-2.0)/(5.0*4.0)) * 20.0
	#print(mob_max)
	var mob_count: int = randi()%mob_max + Globals.minimum_mobs_in_room
	var size_correction: float = max(1.0, float(active_room.tilemap.get_used_cells().size())/float(Globals.tiles_in_a_room))
	
	mob_count = int(size_correction * float(mob_count))
	#print(mob_count, "/", mob_max)
	call_deferred("spawn_mobs", mob_count)
	
	var item_count: int = int(ceilf(max(float(randi()%(mob_count+3))/3.0, 0.0)))
	call_deferred("spawn_items", item_count)
	
	var directions: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	player.apply_velocity(directions[connection.z] * Globals.door_velocity, false)
	do_screenshake.emit(70.0, 0.3)
	
	rocks.position = player.global_position + directions[connection.z]*Globals.tile_size
	rocks.direction = directions[connection.z]
	rocks.restart()
	rocks.emitting = true
	rocks_player.play()
	
	
	
	#print("apply velocity")
	# start entering animation and stuff

func spawn_mobs(count: int) -> void:
	var activeTiles: Array[Vector2i] = active_room.tilemap.get_used_cells()
	
	var added_mobs: Array[RigidBody2D] = []
	
	var spawned_count: int = 0
	while spawned_count < count:
		var i_tile: int = randi() % activeTiles.size()
		var cell_pos: Vector2i = activeTiles[i_tile]
		var pos: Vector2 = (active_room.offset + cell_pos) * Globals.tile_size
		#print("spawn at ", pos)
		#print("spawn at tile pos: ", active_room.offset + cell_pos)
		
		if (pos-player.global_position).length() < min_spawn_distance:
			continue
		
		var cell: TileData = active_room.tilemap.get_cell_tile_data(cell_pos)
		if (cell.get_custom_data("Spawnable") != null):
			if (cell.get_custom_data("Spawnable") as bool) == false:
				continue
		
		var mob_name: String = Globals.pick_weighted_random(Globals.mob_spawn_rates)
		var mob_scene: PackedScene = Globals.mob_scenes[mob_name]
		
		var mob: RigidBody2D = mob_scene.instantiate()
		#print("spawned ", mob.name)
		mob.global_position = cell_pos * Globals.tile_size
		mob.player = player
		
		var mob_health: float = 60
		#print(mob)
		active_room.add_child(mob)
		if mob is RangedMob:
			var ranged_mob: RangedMob = mob as RangedMob
			ranged_mob.health_module.max_health += float(Globals.difficulty)*5
			ranged_mob.health_module.health = ranged_mob.health_module.max_health
			ranged_mob.shoot_interval = max(0, ranged_mob.shoot_interval - ranged_mob.shoot_interval/50*Globals.difficulty)
		elif mob is MeleeMob:
			var melee_mob: MeleeMob = mob as MeleeMob
			melee_mob.health_module.max_health += float(Globals.difficulty)*8
			melee_mob.health_module.health = melee_mob.health_module.max_health
			melee_mob.acceleration = melee_mob.acceleration*1.10
			melee_mob.max_velocity+= float(Globals.difficulty)*6
		
		added_mobs.append(mob)
		
		spawned_count += 1
	
	spawned_mobs.emit(added_mobs)

func spawn_items(count: int) -> void:
	var activeTiles: Array[Vector2i] = active_room.tilemap.get_used_cells()
	print("spawning items: ", count)
	var spawned_count = 0
	
	while spawned_count < count:
		var i_tile: int = randi() % activeTiles.size()
		var cell_pos: Vector2i = activeTiles[i_tile]
		var pos: Vector2 = (active_room.offset + cell_pos) * Globals.tile_size
		#print("spawn at ", pos)
		#print("spawn at tile pos: ", active_room.offset + cell_pos)
		
		if (pos-player.global_position).length() < min_spawn_distance:
			continue
		
		var cell: TileData = active_room.tilemap.get_cell_tile_data(cell_pos)
		if (cell.get_custom_data("Spawnable") != null):
			if (cell.get_custom_data("Spawnable") as bool) == false:
				continue
		
		var item_name: String = Globals.pick_weighted_random(Globals.item_spawn_rates)
		var item: BaseItem = Globals.item_scenes[item_name].instantiate()
		item.global_position = cell_pos * Globals.tile_size
		item.player = player
		
		active_room.add_child(item)
		spawned_count += 1
		print("item spawneddd at ", cell_pos)
