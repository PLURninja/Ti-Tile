extends CharacterBody3D

@onready var damage_timer = Timer.new()
@export var damage_move_distance = 0.2
@export var damage_move_duration = 0.1

var is_damaged = false
var damage_timer_elapsed = 0.0
var damage_direction = Vector3.ZERO
var original_position = Vector3.ZERO # Store the initial position

var health = 100

func _ready():
	original_position = position # Capture the starting position

func take_damage(damage_amount):
	health -= damage_amount
	damage_direction = -transform.basis.y * damage_move_distance / damage_move_duration # Calculate velocity
	is_damaged = true
	damage_timer_elapsed = 0.0
	print(name + " took " + str(damage_amount) + " damage. Current health: " + str(health))
	if health <= 0:
		print(name + " has been defeated!")

func _physics_process(delta):
	if is_damaged:
		velocity = damage_direction
		move_and_slide()
		damage_timer_elapsed += delta
		if damage_timer_elapsed >= damage_move_duration: # Moved forward
			# Now move backward
			velocity = -damage_direction
			move_and_slide()
			if damage_timer_elapsed >= damage_move_duration * 2: # Moved back (approximately)
				is_damaged = false
				velocity = Vector3.ZERO
				position = original_position # Forcefully return to the original position
				damage_timer.start() # Restart the damage timer
	else:
		velocity = Vector3.ZERO # Ensure no movement when not attacking
		move_and_slide()
