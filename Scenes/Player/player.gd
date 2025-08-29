extends CharacterBody2D
class_name Player

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var hurtbox: Area2D
@export var health_module: HealthModule

signal hurtbox_hit(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int)

var screen_size 
var line_color = Color(1, 0, 0)  # Red line
var line_width = 2

func _ready():
	screen_size = get_viewport_rect().size

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
		
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stssop()
	velocity = input_vector * speed
	move_and_slide()
	queue_redraw()  # Forces redraw every frame

func _draw():
	var mouse_position = get_global_mouse_position()
	var start_pos = Vector2.ZERO  # Character's local origin
	var end_pos = to_local(mouse_position)  # Convert global to local space
	draw_line(start_pos, end_pos, line_color, line_width)

func _unhandled_input(event: InputEvent) -> void:
	pass

func _process(delta) -> void:
	pass

func take_damage(damage: float) -> void:
	health_module.take_damage(damage)

#func get_hurt_rids() -> Array[RID]:
	#var slide_collisions: Array[RID] = []
	#for body: Node2D in hurtbox.get_overlapping_bodies(): 
		#slide_collisions.append(body)
	#return slide_collisions


func _on_hurt_box_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hurtbox_hit.emit(body_rid, body, body_shape_index, local_shape_index)
