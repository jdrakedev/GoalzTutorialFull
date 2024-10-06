extends CharacterBody2D

# Create onready variable the access child nodes in the scene
@onready var dial = $Dial
@onready var raycast = $Dial/RayCast2D
@onready var shoot_timer = $ShootTimer
@onready var exclamation = $Exclamation
@onready var tick_timer = $TickTimer

# Create constants (immutable variables) to represent values that cannot be changed
const SPEED = 700
const GRAVITY = 400
const FRICTION = 0.91
const JUMP_FORCE = 580
const POST_SHOT_VELOCITY = 50

# Create are regular variables
var timer_called = false
var can_shoot = true

func _physics_process(delta):
	# Initialize our default velocity value to 0.0
	var velocity = 0.0
	
	# Use the move_toward function to gradually adjust our velocity 
	# towards 0 (slowing down) over time based on the SPEED constant.
	# This creates a smooth deceleration effect.
	velocity = move_toward(velocity, 0, SPEED)
	
	# Call functions
	apply_gravity(delta)
	apply_friction()
	update_shoot_ability()
	update_exclamation_visibility()
	shoot()
	
	# Use the move_and_slide() function to move our Ball based on the calculated velocity.
	# If the character collides with another object, it will automatically slide along the surface 
	# rather than coming to an abrupt stop. This provides more natural movement and prevents 
	# characters from getting stuck on obstacles.
	move_and_slide()
	
	# If the timer hasn't been called yet, check if the dial is rotating.
	# Start the tick timer if the dial is rotating, and set timer_called to true
	# to prevent this block from executing again until reset.
	if not timer_called:
		if dial.rotating:
			tick_timer.start()
			timer_called = true

func apply_gravity(delta):
	# Check if the ball is not on the floor (in the air).
	if not is_on_floor(): 
		# Increase the y component of our velocity vector to simulate gravity.
		# The y component is affected by GRAVITY, and we multiply it by delta 
		# to ensure smooth and frame rate-independent motion.
		velocity.y += GRAVITY * delta
		
		# To prevent the ball from falling too fast or floating upward uncontrollably,
		# we clamp the y velocity to a specific range defined by -JUMP_FORCE and JUMP_FORCE.
		# This limits the maximum speed at which the ball can fall or rise due to gravity.
		velocity.y = clamp(velocity.y, -JUMP_FORCE, JUMP_FORCE)

func apply_friction():
	# To simulate friction, we multiply the current velocity of the ball by a friction factor.
	# This gradually reduces the speed of the ball over time, giving it a more realistic feel.
	velocity *= FRICTION

# This function will dictate our ability to shoot (or launch the ball in the direction of the dial)
func update_shoot_ability():
	# If we have almost stopped moving, we can shoot again
	if velocity.length_squared() < POST_SHOT_VELOCITY:
		can_shoot = true
	# If we are still moving, we cant shoot yet
	else:
		can_shoot = false

# This function will provide a visual representation of when we are able to shoot again.
func update_exclamation_visibility():
	# Because can_shoot represents a boolean value, we can just set our ! visibility to that.
	exclamation.visible = can_shoot

func start_shooting():
	# When this function is called, we will call the start_rotation function (from the dial script)
	dial.start_rotation()
	# We set the dial sprite to be visible here to the player can choose a direction to launch in.
	dial.visible = true
	# We will enable our raycast here so that it can find a collision with one of the bricks
	raycast.enabled = true

func stop_shooting():
	# Stop the tick timer to prevent any further ticking sounds.
	tick_timer.stop()
	# Start the shoot timer to manage the cooldown period for shooting.
	shoot_timer.start()
	# Stop the dial from rotating. 
	dial.stop_rotation()
	# Make the dial invisible until the next shot is ready.
	dial.visible = false
	# Set our velocity to the return value of the calculate_initial_velocity function.
	velocity = calculate_initial_velocity()

func calculate_initial_velocity():
	# If the raycast is colliding with an object, calculate the direction from the player's position
	# to the collision point and normalize it to get the unit vector in that direction.
	# Multiply this by SPEED to set the initial velocity for the shot. Otherwise, return zero velocity.
	if raycast.is_colliding():
		var aim_direction = (raycast.get_collision_point() - global_position).normalized()
		return aim_direction * SPEED
	return Vector2.ZERO

func shoot():
	# Check if we can shoot (i.e., we're not moving fast). If we can, check for player input.
	if can_shoot:
		# When the "Touch" action is pressed, we start shooting (rotating the dial to select direction).
		if Input.is_action_pressed("Touch"):
			start_shooting()
		# When the "Touch" action is released, play the shooting sound and stop the shooting process.
		elif Input.is_action_just_released("Touch"):
			$Shoot.play()
			stop_shooting()

func _on_shoot_timer_timeout():
	# Disable the raycast to prevent further collision detection and 
	raycast.enabled = false
	# Reset the timer_called flag so the timer can be started again when the dial rotates.
	timer_called = false

func _on_tick_timer_timeout():
	# Play the ticking sound effect whenever the tick timer times out. 
	# This will indicate that time is passing or that a countdown is active.
	$Tick.playing = true

func _on_ball_area_body_entered(body):
	# Check if the body that the ball has collided with is not part of the "NotWall" group.
	# If it's not part of the group, it must be a wall, so play the wall collision sound effect.
	if not body.is_in_group("NotWall"):
		$Hitwall.play()
