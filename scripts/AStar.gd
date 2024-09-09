extends Node3D

@export var grid_step := 1.0
var points := {}
var astar = AStar3D.new()

func add_point(point: Vector3):
	var id = astar.get_available_point_id()
	astar.add_point(id, point)
	points[world_to_astar(point)] = id
	_connect_points()

func _connect_points():
	for point in points:
		var pos_str = point.split(",")
		var world_pos := Vector3(float(pos_str[0]), float(pos_str[1]), float(pos_str[2]))
		var adjacent_points = _get_adjacent_points(world_pos)
		var current_id = points[point]
		for neighbor_id in adjacent_points:
			if not astar.are_points_connected(current_id, neighbor_id):
				astar.connect_points(current_id, neighbor_id)

func _get_adjacent_points(world_point: Vector3) -> Array:
	var adjacent_points = []
	var search_coords = [-grid_step, 0, grid_step]
	# Check for adjacent points only along the X and Z axes (no diagonals)
	for x in search_coords:
		if x != 0:
			var potential_neighbor_x = world_to_astar(world_point + Vector3(x, 0, 0))
			if points.has(potential_neighbor_x):
				adjacent_points.append(points[potential_neighbor_x])
	
	for z in search_coords:
		if z != 0:
			var potential_neighbor_z = world_to_astar(world_point + Vector3(0, 0, z))
			if points.has(potential_neighbor_z):
				adjacent_points.append(points[potential_neighbor_z])
	
	return adjacent_points


func find_path(from: Vector3, to: Vector3) -> Array:
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	return astar.get_point_path(start_id, end_id)

func world_to_astar(world: Vector3) -> String:
	var x = snapped(world.x, grid_step)
	var y = snapped(world.y, grid_step)
	var z = snapped(world.z, grid_step)
	return "%d,%d,%d" % [x, y, z]

func find_optimal_loop_path(points: Array[Vector3]) -> Array:
	if points.size() < 2:
		return []  # No loop needed if fewer than 2 points
	
	var start_point = points[0]
	var visited = [start_point]  # Track visited points starting with the first one
	var total_path = []  # Store the final path

	var current_point = start_point
	var remaining_points = points.duplicate()  # Copy of points array to track remaining points
	remaining_points.remove_at(0)  # Remove the starting point from remaining points

	# Loop through all the points to find the nearest neighbor each time
	while remaining_points.size() > 0:
		var nearest_point = null
		var shortest_distance = INF
		var shortest_path = []

		# Find the nearest point based on direct distance
		for next_point in remaining_points:
			var distance = current_point.distance_to(next_point)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_point = next_point

		# Now that we know the nearest point, get the path to it
		shortest_path = find_path(current_point, nearest_point)

		# Add the path to the total path and mark the nearest point as visited
		total_path += shortest_path
		visited.append(nearest_point)
		current_point = nearest_point
		remaining_points.erase(nearest_point)

	# Once all points are visited, return to the starting point
	var return_path = find_path(current_point, start_point)
	total_path += return_path

	return total_path

# For use if needing mesh

#func _ready():
	#var pathables = get_tree().get_nodes_in_group("pathable")
	#_add_points(pathables)
	#_connect_points() 

#func _add_points(pathables: Array):
	#for pathable in pathables:
		#var mesh = pathable.get_node("MeshInstance")
		#var aabb: AABB = mesh.get_transformed_aabb()
		#
		#var start_point = aabb.position
		#
		#var x_steps = aabb.size.x / grid_step
		#var z_steps = aabb.size.z / grid_step
		#
		#for x in x_steps:
			#for z in z_steps:
				#var next_point = start_point + Vector3(x * grid_step, 0, z * grid_step)
				#_add_point(next_point)
				
