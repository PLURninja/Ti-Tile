extends Node3D

# Reference to the camera
@onready var camera = $Camera3D

# The grid map
@onready var grid_map = $GridMap

# The mesh library associated with the grid map
const WORLD_TILES_LIB = preload("res://mesh/WorldTilesLib.tres")

const BLOCK_GRASS_LARGE = 16

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var click_position = get_click_position(event.position)
		if click_position:
			var grid_coords = world_to_grid(click_position)
			if is_empty(grid_coords):
				add_tile(grid_coords)

func get_click_position(screen_position):
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	return null

func world_to_grid(world_position):
	var cell_size = grid_map.cell_size
	var grid_x = int(floor(world_position.x / cell_size.x))
	var grid_y = int(floor(world_position.y / cell_size.y))
	var grid_z = int(floor(world_position.z / cell_size.z))
	return Vector3i(grid_x, grid_y, grid_z)

func is_empty(grid_coords: Vector3i):
	return grid_map.get_cell_item(grid_coords) == GridMap.INVALID_CELL_ITEM

func add_tile(grid_coords: Vector3i):
	var item_id = BLOCK_GRASS_LARGE # Replace with the correct ID from your mesh library
	grid_map.set_cell_item(grid_coords, item_id)
