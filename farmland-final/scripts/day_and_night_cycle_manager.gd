extends Node

const minutes_day: int = 24 * 60
const minutes_hour: int = 60
const game_duration: float = TAU / minutes_day

var game_speed: float = 5.0
var initial_day: int = 1
var initial_hour: int = 12
var initial_minute: int = 30
var time: float = 0.0
var current_minute: int = -1
var current_day: int = 0

signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)

# Sets up the game's starting time when the time system is first loaded.
# The starting day, hour and minute are converted into the internal time value
# so that the game clock begins at the correct point.
func _ready() -> void:
	initial_time()

# Advances the game's internal clock every frame according to the game speed.
# It also emits the current time and recalculates the day, hour and minute so
# other parts of the game can respond when the time changes.
func _process(delta: float) -> void:
	time += delta * game_speed * game_duration
	game_time.emit(time)
	recalculate_time()

# Converts the chosen starting day and time into the internal time format used
# by the clock. This allows the game to begin at a specific time instead of zero.
func initial_time() -> void:
	var initial_total_minutes = (
		initial_day * minutes_day + (initial_hour * minutes_hour) 
		+ initial_minute
	)
	time = initial_total_minutes * game_duration

# Converts the internal clock value back into a readable day, hour and minute.
# Signals are only emitted when the minute or day changes, allowing other systems
# such as the UI to update without repeatedly sending the same values.
func recalculate_time() -> void:
	var total_minutes: int = int(time / game_duration)
	var day: int = int(total_minutes / minutes_day)
	var current_minutes: int = total_minutes % minutes_day
	var hour: int = int(current_minutes / minutes_hour)
	var minute: int = int(current_minutes % minutes_hour)

	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day, hour, minute)

	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
