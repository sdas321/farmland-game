extends Control

@onready var button_press: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Handles the Play button by playing the button sound and changing the current
# scene to the main game. The scene waits for the audio to finish playing before changing.
func _on_play_pressed() -> void:
	button_press.play()
	await button_press.finished
	get_tree().change_scene_to_file(Global.GAME_SCENE)

# Handles the How to Play button by playing the button sound and opening the
# instructions scene so the player can view the game's controls and mechanics.
# The scene waits for the audio to finish playing before changing.
func _on_how_to_play_pressed() -> void:
	button_press.play()
	await button_press.finished
	get_tree().change_scene_to_file(Global.HOW_TO_PLAY_SCENE)

# Handles the Quit button by playing the button sound and closing the application.
# The scene waits for the audio to finish playing before changing.
func _on_quit_pressed() -> void:
	button_press.play()
	await button_press.finished
	get_tree().quit()
