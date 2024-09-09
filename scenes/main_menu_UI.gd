extends Control


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/hello_world.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_exit_game_pressed():
	get_tree().quit()
