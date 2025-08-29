extends CharacterBody2D


@onready var nav_agent = $NavigationAgent2D
@export var speed: float = 120.0

var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Scenes/Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if player:
		# Update the target position of the NavigationAgent2D
		nav_agent.target_position = player.global_position
		
		# Check if path is finished
		if not nav_agent.is_navigation_finished():
			var next_point = nav_agent.get_next_path_position()
			
			# Calculate direction toward the next point
			var direction = (next_point - global_position).normalized()
			
			# Apply movement using move_and_slide()
			velocity = direction * speed
			move_and_slide()
