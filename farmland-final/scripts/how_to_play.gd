extends Control




func _on_home_pressed() -> void:
	$button_press.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

	
