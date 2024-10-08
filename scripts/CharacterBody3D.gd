extends CharacterBody3D

@onready var nav = $"../AStar"

@export var move_speed = 5.0
var current_target = Vector3.INF
var current_velocity = Vector3.ZERO
var path = []

func _physics_process(delta: float) -> void:
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		new_velocity = lerp(current_velocity, move_speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
	current_velocity = new_velocity
	velocity = current_velocity
	move_and_slide()


func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
	else:
		current_target = Vector3.INF


func update_path(new_path: Array):
	path = new_path
	find_next_point_in_path()
