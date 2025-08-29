extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
@export var speed: float = 120.0
@export var player: NodePath      # set in inspector to your Player node
@export var mass: float = 2.0     # effective mass for knockback calculations (tune this)
var player_ref: Node2D

# knockback state
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_decay: float = 500.0   # pixels/sec^2, larger = faster slowdown

func _ready() -> void:
	add_to_group("enemies")
	if player:
		player_ref = get_node(player)
	# find nav region (adjust path to your scene root if different)
	var nav_region = get_tree().get_root().get_node_or_null("Main/Map/NavigationRegion2D")
	if nav_region:
		nav_agent.navigation_map = nav_region.get_navigation_map()

# Called by weapon: pass the momentum impulse vector (Vector2)
func apply_knockback_impulse(impulse: Vector2) -> void:
	# Convert impulse (momentum) -> velocity change: delta_v = impulse / mass
	if mass <= 0:
		mass = 0.1
	var delta_v: Vector2 = impulse / mass
	knockback_velocity += delta_v
	print("apply_knockback_impulse: impulse=", impulse, " delta_v=", delta_v, " total_knockback=", knockback_velocity)

func _physics_process(delta: float) -> void:
	# Update agent
	if player_ref:
		nav_agent.target_position = player_ref.global_position

	var move_velocity = Vector2.ZERO
	if not nav_agent.is_navigation_finished():
		var next_point = nav_agent.get_next_path_position()
		# if next_point is (0,0) check nav map; but we'll just avoid zero-length direction
		var dir = next_point - global_position
		if dir.length_squared() > 1:
			dir = dir.normalized()
			move_velocity = dir * speed

	# Add knockback (this pushes the mob)
	move_velocity += knockback_velocity

	# Apply movement using CharacterBody2D's velocity and move_and_slide()
	velocity = move_velocity
	move_and_collide(velocity*delta)

	# Decay knockback toward zero
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
