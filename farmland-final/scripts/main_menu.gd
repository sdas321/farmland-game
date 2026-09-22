extends Control
@onready var button_press: AudioStreamPlayer2D = $AudioStreamPlayer2D



# Starts the gam"res://scenes/main_menu.tscn"e after the Play button is pressed by providing button audio
# feedback and changing the current scene to the main game scene.
func _on_play_pressed() -> void:
	button_press.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Opens the instructions scene when the player selects How to Play.
# The same button sound is played first so the interface provides immediate feedback.
func _on_how_to_play_pressed() -> void:
	button_press.play()
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

# Closes the game when the Quit button is pressed after playing the button sound.
# This ends the running Godot application rather than changing to another scene.
func _on_quit_pressed() -> void:
	button_press.play()
	get_tree().quit()
