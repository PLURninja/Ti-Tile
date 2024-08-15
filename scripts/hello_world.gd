extends Node3D

@onready var grid_map = $GridMap

var blocks_grass

# Called when the node enters the scene tree for the first time.
func _ready():
	blocks_grass = grid_map.get_used_cells_by_item()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_pressed("click"):
		event.get_