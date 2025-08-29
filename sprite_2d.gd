extends Sprite2D

var speed = 400
var angular_speed = PI

func _process(delta):
	var direction = 0
	
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1
	
	rotation += angular_speed * delta * direction
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed
	
	position += velocity * delta
	
func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	visible = not visible

func _on_button_pressed() -> void:
	set_process(not is_processing())
