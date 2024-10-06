extends Sprite2D

var rotating = false  # Boolean flag to control whether the dial is currently rotating.
var rotation_speed = 200  # Speed at which the dial will rotate (in degrees per second).

func _process(delta):
	# If the rotating flag is true, apply a rotation to the dial.
	if rotating:
		# Rotate the dial by converting the desired rotation speed (in degrees) to radians.
		# Multiply the speed by delta to ensure frame-independent motion (rotation speed remains consistent).
		rotate(deg_to_rad(rotation_speed * delta))

func start_rotation():
	# Start the rotation by setting the rotating flag to true.
	rotating = true

func stop_rotation():
	# Stop the rotation by setting the rotating flag to false.
	rotating = false
