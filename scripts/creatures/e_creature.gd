extends CharacterBody3D

@onready var target_hero = $"../Player"
@onready var attack_timer = Timer.new()
@export var attack_damage = 10
@export var base_attack_speed = 1.5 # Base time between attacks in seconds
@export var attack_move_distance = 0.2
@export var attack_move_duration = 0.1

var current_attack_speed = base_attack_speed
var is_attacking = false
var attack_timer_elapsed = 0.0
var attack_direction = Vector3.ZERO
var original_position = Vector3.ZERO # Store the initial position

func _ready():
	original_position = position # Capture the starting position
	if target_hero != null and is_instance_valid(target_hero):
		print(name + " will attack " + target_hero.name + ".")
		add_child(attack_timer)
		attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
		attack_timer.wait_time = current_attack_speed
		attack_timer.start()
	else:
		print(name + " could not find the target hero.")

func _on_attack_timer_timeout():
	attack_target()

func attack_target():
	if target_hero != null and is_instance_valid(target_hero) && target_hero.health > 0:
		print(name + " is attacking " + target_hero.name + " for " + str(attack_damage) + " damage.")
		attack_direction = transform.basis.z * attack_move_distance / attack_move_duration # Calculate velocity
		is_attacking = true
		attack_timer_elapsed = 0.0
		target_hero.take_damage(attack_damage)
		# We don't restart the timer here anymore; it will restart after the movement.
	else:
		print(name + " has no valid target.")
		if is_instance_valid(attack_timer):
			attack_timer.stop()

func _physics_process(delta):
	if is_attacking:
		velocity = attack_direction
		move_and_slide()
		attack_timer_elapsed += delta
		if attack_timer_elapsed >= attack_move_duration: # Moved forward
			# Now move backward
			velocity = -attack_direction
			move_and_slide()
			if attack_timer_elapsed >= attack_move_duration * 2: # Moved back (approximately)
				is_attacking = false
				velocity = Vector3.ZERO
				position = original_position # Forcefully return to the original position
				attack_timer.start() # Restart the attack timer
	else:
		velocity = Vector3.ZERO # Ensure no movement when not attacking
		move_and_slide()
