extends CharacterBody3D

@export var move_speed = 5.0
var target_position = Vector3()
var moving = false

func _ready():
	# Assuming the player spawns at the first tile's position (e.g., (0, 0, 0))
	target_position = global_transform.origin
	look_at(target_position)

func _physics_process(delta):
	if moving:
		move_to_target(delta)

	# Apply movement with built-in velocity
	move_and_slide()

func move_to_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	var distance = global_transform.origin.distance_to(target_position)

	# Only move if the player is not already at the target
	if distance > 0.1:
		# Move towards the target using built-in velocity
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		# Stop moving once the player reaches the tile
		velocity.x = 0
		velocity.z = 0
		moving = false

func set_new_target(new_position: Vector3):
	# Set the position of the newly placed tile
	target_position = new_position
	moving = true
