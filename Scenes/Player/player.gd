extends CharacterBody2D
class_name player

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size 
var line_color = Color(1, 0, 0)  # Red line
var line_width = 2

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta: float):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()
	position += velocity * delta
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
