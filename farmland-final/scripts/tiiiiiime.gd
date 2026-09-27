extends Node

@onready var time_label: Label = $time2/time_label
@onready var day_label: Label = $time2/day_label


# Gets the current main game scene and connects the time display to its
# game_time_updated signal when the signal is available. This allows the display
# to receive updated time information without directly controlling the clock.
func _ready() -> void:
	var main_game = get_tree().current_scene

	if main_game and main_game.has_signal("game_time_updated"):
		main_game.game_time_updated.connect(_on_game_time_updated)


# Formats the received hour and minute as a two-digit clock display and updates
# the current day label. This keeps the visible time and day synchronised with
# the main game's global clock.
func _on_game_time_updated(hour: int, minute: int, day: int) -> void:
	time_label.text = "%02d:%02d" % [hour, minute]
	day_label.text = "Day: " + str(day)
