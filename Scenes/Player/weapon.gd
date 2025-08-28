extends RigidBody2D

var target_pos = Vector2.ZERO
var kp = 50000.0   # Proportional gain
var kd = 5000.0    # Derivative gain (damping)

func _physics_process(delta):
	target_pos = get_global_mouse_position()
	
	var desired_angle = (target_pos - global_position).angle()
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	
	var angular_velocity_error = -angular_velocity  # Derivative term
	
	# PD control torque
	var torque = (angle_diff * kp) + (angular_velocity_error * kd)
	apply_torque(torque)
