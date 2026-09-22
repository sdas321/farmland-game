extends Control

# Starts the main game when the Play button is pressed by changing the current
# scene to the game's main gameplay scene.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Returns the player to the main menu when the button is pressed.
# Although the function is named Quit, its current behaviour is to leave this
# screen and return to the main menu rather than closing the application.
func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
