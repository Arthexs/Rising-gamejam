extends RigidBody2D

class_name Hammer

# Rotation PD controller
var target_pos = Vector2.ZERO
var kp = 5000000.0
var kd = 500000.0

# Knockback tuning
@export var impulse_scale: float = 1.0
@export var max_impulse: float = 500.0
@export var minimum_impulse: float = 10.0
@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	contact_monitor = true
	max_contacts_reported = 8
	_animated_sprite.play("weapon")

func _physics_process(delta):
	# Rotation control (unchanged)
	target_pos = get_global_mouse_position()
	var desired_angle = (target_pos - global_position).angle()+PI/4
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	var angular_velocity_error = -angular_velocity
	var torque = (angle_diff * kp) + (angular_velocity_error * kd)
	apply_torque(torque)

func _integrate_forces(state):
	var contact_count = state.get_contact_count()
	for i in range(contact_count):
		var collider = state.get_contact_collider_object(i)
		if collider and collider.is_in_group("enemies"):
			# Convert local contact position to global position
			var contact_point = state.get_contact_local_position(i).rotated(rotation) + global_position
			_apply_momentum_knockback_to(collider, contact_point)

func _apply_momentum_knockback_to(body: Node, contact_point: Vector2):
	#if not body.has_method("apply_knockback_impulse"):
		#return
#
	## Original momentum calculation (angular velocity * mass)
	var w_angularvel: float = angular_velocity
	var w_mass: float = 0.001/PhysicsServer2D.body_get_direct_state(get_rid()).inverse_inertia
	var weapon_momentum: float = w_angularvel * w_mass  # still scalar like before
#
	## Direction: from contact point → mob center
	#var dir_vector: Vector2 = (body.global_position - contact_point)
	#if dir_vector.length_squared() == 0:
		#return
	#dir_vector = dir_vector.normalized()
#
	## Use your original projection approach but correctly as a scalar (since weapon_momentum is scalar)
	#var momentum_along: float = weapon_momentum  # We cannot do dot with scalar, so keep as-is
#
	## Build impulse vector
	#var impulse: Vector2 = dir_vector * momentum_along * impulse_scale
#
	## Clamp impulse
	#var impulse_length = impulse.length()
	#if impulse_length > max_impulse and impulse_length > 0:
		#impulse = impulse.normalized() * max_impulse
#
	#body.apply_knockback_impulse(impulse)
#
	#print("Hit:", body.name,
		#" Contact:", contact_point,
		#" Weapon momentum:", weapon_momentum,
		#" Impulse:", impulse)

	# Compute swing direction as perpendicular to the weapon
	var swing_direction = Vector2.RIGHT.rotated(rotation + PI / 2)

	# Ensure swing direction points toward the mob (optional)
	if swing_direction.dot(body.global_position - global_position) < 0:
		swing_direction = -swing_direction

	swing_direction = swing_direction.normalized()

	# Apply impulse along swing direction
	var impulse: Vector2 = swing_direction * weapon_momentum * impulse_scale

	# Clamp impulse
	if weapon_momentum > max_impulse:
		impulse = impulse.normalized() * max_impulse
	if weapon_momentum > minimum_impulse:
		body.apply_knockback_impulse(impulse)
		print(weapon_momentum)
