extends CharacterBody2D
class_name Player

@export var speed = 100 # How fast the player will move (pixels/sec).
@export var hurtbox: Area2D
@export var collision_box: CollisionShape2D 
@export var health_module: HealthModule
@export var hud_info: HUD
@onready var _animated_sprite = $AnimatedSprite2D
@export var min_angular_hit_velocity: float = 3
@onready var weapon: Hammer = $weapon
@onready var footstep_player: AudioStreamPlayer = ($Audio/Footsteps as AudioStreamPlayer)
@onready var hurt_player: AudioStreamPlayer = ($Audio/Hurt as AudioStreamPlayer)

## Flashing
var t_anim: float = 0
var t_anim_goal: float = 0
var c_anim: Color = Color.WHITE
#@onready sprite: Animat

var applied_velocity: Vector2 = Vector2.ZERO
@export var deaccel: float = 50.0 # px/s^2
var can_collide: bool = true

signal hurtbox_hit(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int)
signal player_dies()

var screen_size 
var line_color = Color(1, 0, 0)  # Red line
var line_width = 2

var next_is_hitting: bool = false
var is_hitting: bool = false

func _ready():
	screen_size = get_viewport_rect().size

func do_animation(delta: float) -> void:
	if t_anim_goal != 0:
		t_anim += delta
		_animated_sprite.set_instance_shader_parameter("t", t_anim/t_anim_goal)
		if t_anim >= t_anim_goal:
			t_anim_goal = 0
			t_anim = 0
			_animated_sprite.set_instance_shader_parameter("t", 0)

func flash(color: Color, depth: float, duration: float) -> void:
	t_anim_goal = duration
	_animated_sprite.set_instance_shader_parameter("color", color)
	_animated_sprite.set_instance_shader_parameter("depth", depth)

func _physics_process(delta: float):
	var input_vector = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("Right"):
		input_vector.x += 1
	if Input.is_action_pressed("Left"):
		input_vector.x -= 1
	if Input.is_action_pressed("Down"):
		input_vector.y += 1
	if Input.is_action_pressed("Up"):
		input_vector.y -= 1
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit() 
	
	is_hitting = next_is_hitting
	next_is_hitting = abs(weapon.angular_velocity) > min_angular_hit_velocity
	#print(is_hitting)
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stssop()
	#print(applied_velocity)
	if applied_velocity == Vector2.ZERO:
		can_collide = true
		velocity = input_vector * speed
	else:
		velocity = applied_velocity
		if deaccel > applied_velocity.length():
			applied_velocity = Vector2.ZERO
			can_collide = true
		else:
			applied_velocity -= applied_velocity.normalized() * deaccel
	#print(can_collide)
	
	if can_collide:
		move_and_slide()
	else:
		global_position += velocity * delta
	
	var current_stage = "stage" + str(int(floor(hud_info.meter_value / 20)+1))
	_animated_sprite.play(current_stage)
	if velocity.x > Globals.flip_velocity:
		_animated_sprite.flip_h = false
	elif velocity.x < -Globals.flip_velocity:
		#_animated_sprite.play(current_stage)
		_animated_sprite.flip_h = true
	elif abs(velocity.y) < Globals.flip_velocity:
		_animated_sprite.stop()
	
	if velocity.length() > Globals.flip_velocity:
		if not footstep_player.playing:
			print("playing")
			footstep_player.play()
	else:
		if footstep_player.playing:
			footstep_player.stop()
		
	
	handle_items()
	#queue_redraw()  # Forces redraw every frame

func apply_velocity(v: Vector2, hitable: bool) -> void:
	applied_velocity = v
	can_collide = hitable

#func _draw():
	#var mouse_position = get_global_mouse_position()
	#var start_pos = Vector2.ZERO  # Character's local origin
	#var end_pos = to_local(mouse_position)  # Convert global to local space
	#draw_line(start_pos, end_pos, line_color, line_width)

func _unhandled_input(event: InputEvent) -> void:
	pass

func _process(delta) -> void:
	do_animation(delta)

func take_damage(damage: float) -> void:
	health_module.take_damage(damage)
	if damage >= 0:
		flash(Color.RED, 0.6, 0.2)
		hurt_player.play()
		

#func get_hurt_rids() -> Array[RID]:
	#var slide_collisions: Array[RID] = []
	#for body: Node2D in hurtbox.get_overlapping_bodies(): 
		#slide_collisions.append(body)
	#return slide_collisions


func _on_hurt_box_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hurtbox_hit.emit(body_rid, body, body_shape_index, local_shape_index)

func handle_items() -> void:
	var areas_overlapping: Array[Area2D] = hurtbox.get_overlapping_areas()
	var closest_item: BaseItem = BaseItem.new()
	closest_item.cost = -1
	var closest_item_distance: float = INF
	
	var player_center: Vector2 = collision_box.shape.get_rect().position + collision_box.shape.get_rect().size/2
	
	for area: Area2D in areas_overlapping:
		var collider_root: Node2D = area.owner
		if not collider_root is BaseItem:
			continue
		
		var item: BaseItem = collider_root as BaseItem
		#print(d)
		
		var item_pos: Vector2 = item.interaction_range.shape.get_rect().size/2 + item.interaction_range.global_position
		var item_dist: float = (item_pos-player_center).length()
		if item_dist < closest_item_distance:
			closest_item_distance = item_dist
			closest_item = item
		else:
			item.remove_label()
			# Maybe delete closest_item if cost -1 if it is not automatically deleted
	
	if closest_item.cost != -1:
		closest_item.make_label()
		if Input.is_action_just_released("interact"):
			gain_corruption(5)
			closest_item.effect()

func _on_hitbox_area_exited(area: Area2D) -> void:
	var collider_root: Node2D = area.owner
	if not collider_root is BaseItem:
		return
	
	#print("removing label")
	var item: BaseItem = collider_root as BaseItem
	item.remove_label()

func dies() -> void:
	player_dies.emit()

func gain_corruption(value: float) -> void:
	hud_info.meter_value += value
	hud_info.previous_meter_value += value
