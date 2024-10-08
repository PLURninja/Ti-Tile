extends Node3D

# Reference to the world
@onready var camera = $Camera3D
@onready var grid_map = $GridMap
@onready var player = $Player
@onready var nav = $AStar

# The mesh library associated with the grid map and tile preview instance
const WORLD_TILES_LIB = preload("res://mesh/WorldTilesLib.tres")
@onready var tile_preview = $TilePreview

# Camera Settings
@export var cam_move_speed = 69.0
@export var cam_rotation_sensitivity = 0.69
var cam_rotating = false
var cam_rotation_origin = Vector3()
var cam_click_pivot = Vector3()

# Tile Settings
const BLOCK_GRASS = 41
const BLOCK_GRASS_LOW = 23
const BLOCK_SNOW = 83
const BLOCK_SNOW_LOW = 65

var current_tile = 0
var first_tile_placed = false
var recent_tiles: Array[Vector3] = []

func _ready():
	current_tile = BLOCK_GRASS
	set_preview(current_tile)	

func _process(delta):
	handle_camera_movement(delta)
	handle_camera_rotation()
	handle_adventure_pathing()

func _input(event):
	var mouse_position = get_viewport().get_mouse_position()
	var hover_position = get_ray_position(mouse_position)
	if hover_position:
		var grid_coords = world_to_grid(hover_position)
		var cell_center = grid_to_world(grid_coords)
		if tile_preview:
			if is_empty(grid_coords):
				tile_preview.global_transform.origin = cell_center
				tile_preview.visible = true
			else:
				tile_preview.visible = false
	else:
		if tile_preview:
			tile_preview.visible = false
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var click_position = get_ray_position(event.position)
		if click_position:
			var grid_coords = world_to_grid(click_position)
			if is_valid_placement(grid_coords):
				add_tile(grid_coords)
				player.update_path(nav.find_path(player.global_transform.origin, grid_to_world(grid_coords)))
				
	
	if event is InputEventKey and event.pressed:
		if event.key_label == KEY_1:
			current_tile = BLOCK_GRASS
			set_preview(current_tile)
		elif event.key_label == KEY_2:
			current_tile = BLOCK_GRASS_LOW
			set_preview(current_tile)
		if event.key_label == KEY_3:
			current_tile = BLOCK_SNOW
			set_preview(current_tile)
		elif event.key_label == KEY_4:
			current_tile = BLOCK_SNOW_LOW
			set_preview(current_tile)
	

func handle_adventure_pathing():
	if Input.is_action_pressed("path"):
		player.update_path(nav.find_optimal_loop_path(recent_tiles))

func handle_camera_movement(delta):
	var input_direction = Vector3()
	
	if Input.is_action_pressed("cam_f"):
		input_direction.z += 1
	if Input.is_action_pressed("cam_b"):
		input_direction.z -= 1
	if Input.is_action_pressed("cam_l"):
		input_direction.x -= 1
	if Input.is_action_pressed("cam_r"):
		input_direction.x += 1
	
	var cam_forward = -camera.global_transform.basis.z
	var cam_side = camera.global_transform.basis.x
	cam_forward.y = 0
	cam_side.y = 0
	cam_forward = cam_forward.normalized()
	cam_side = cam_side.normalized()
	
	# Move the camera along its own X/Z plane
	var movement_vector = (cam_forward * input_direction.z + cam_side * input_direction.x).normalized()
	camera.global_transform.origin += movement_vector * cam_move_speed * delta

func handle_camera_rotation():
	if Input.is_action_just_pressed("click_r"):
		cam_rotating = true
		cam_click_pivot = get_viewport().get_mouse_position()
		cam_rotation_origin = camera.rotation_degrees
	
	if Input.is_action_pressed("click_r") and cam_rotating:
		var mouse_position = get_viewport().get_mouse_position()
		var delta_rotation = (mouse_position - cam_click_pivot) * cam_rotation_sensitivity
		camera.rotation_degrees.y = cam_rotation_origin.y - delta_rotation.x
	
	if Input.is_action_just_released("click_r"):
		cam_rotating = false

func get_ray_position(screen_position):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = camera.project_ray_origin(screen_position)
	query.to = query.from + camera.project_ray_normal(screen_position) * 1000
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	return null

func world_to_grid(world_position: Vector3) -> Vector3i:
	var cell_size = grid_map.cell_size
	var grid_x = int(floor(world_position.x / cell_size.x))
	var grid_y = int(floor(world_position.y / cell_size.y))
	var grid_z = int(floor(world_position.z / cell_size.z))
	return Vector3i(grid_x, grid_y, grid_z)

func grid_to_world(grid_coords: Vector3i) -> Vector3:
	var cell_size = grid_map.cell_size
	var world_x = (grid_coords.x + 0.5) * cell_size.x
	var world_y = (grid_coords.y + 0.5) * cell_size.y
	var world_z = (grid_coords.z + 0.5) * cell_size.z
	return Vector3(world_x, world_y, world_z)

func set_preview(tile: int):
	# Ensure the tile preview is hidden initially
	if tile_preview:
		var mesh = WORLD_TILES_LIB.get_item_mesh(tile)
		if mesh:
			tile_preview.mesh = mesh
			tile_preview.visible = false

func add_tile(grid_coords: Vector3i):
	grid_map.set_cell_item(grid_coords, current_tile)
	nav.add_point(grid_to_world(grid_coords))
	recent_tiles.push_front(grid_to_world(grid_coords))
	if recent_tiles.size() > 8:
		recent_tiles.pop_back()
	if not first_tile_placed:
		first_tile_placed = true

func is_empty(grid_coords: Vector3i):
	return grid_map.get_cell_item(grid_coords) == GridMap.INVALID_CELL_ITEM

func is_valid_placement(grid_coords: Vector3i) -> bool:
	if is_empty(grid_coords):
		if first_tile_placed:
			return is_adjacent_to_tile(grid_coords)
		else:
			return true
	return false

func is_adjacent_to_tile(grid_coords: Vector3i) -> bool:
	var directions = [
		Vector3i(1, 0, 0),
		Vector3i(-1, 0, 0),
		Vector3i(0, 0, 1),
		Vector3i(0, 0, -1)
	]
	for dir in directions:
		var adjacent_coords = grid_coords + dir
		if not is_empty(adjacent_coords):
			return true
	return false
