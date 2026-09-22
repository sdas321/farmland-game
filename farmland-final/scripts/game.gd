extends Node2D

signal game_time_updated(hour: int, minute: int, day: int)

const SECONDS: float = 86400.0
const ITEMS: Dictionary = {
	"bed": preload("res://scenes/products/bed.tscn"),
	"carpet": preload("res://scenes/products/carpet.tscn"),
	"chair": preload("res://scenes/products/chair.tscn"),
	"chicken": preload("res://scenes/products/chicken.tscn"),
	"clock": preload("res://scenes/products/clock.tscn"),
	"cow": preload("res://scenes/products/cow.tscn"),
	"drawer": preload("res://scenes/products/drawer.tscn"),
	"lamp": preload("res://scenes/products/lamp.tscn"),
	"painting": preload("res://scenes/products/painting.tscn"),
	"table": preload("res://scenes/products/table.tscn")
}

@export var time_speed_multiplier: float = 500.0
@export var spawn_point: Marker2D
@export var dialogue_resource: Resource
@export var dialogue = preload("res://tutorial.dialogue")

@onready var player: CharacterBody2D = %player
@onready var animal_container = $AnimalContainer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var pause_menu: Control = $PauseLayer/PauseMenu

var ghost: Sprite2D = null
var current_item_name: String = ""
var can_place: bool = false
var balloon_scene = preload("res://scenes/balloon.tscn")


# Initialises the main game scene and restores important game information when
# the scene loads. It sets the starting time, restores the player's position,
# starts the tutorial once, reloads previously placed animals and updates the time display.
func _ready() -> void:
	if Global.game_seconds == 0.0 and Global.current_day == 1:
		Global.game_seconds = 21600.0

	if Global.player_saved_position:
		player.global_position = Global.player_spawn_position + Vector2(0, 20)

	if dialogue and not Global.tutorial_played:
		Global.tutorial_played = true
		DialogueManager.show_dialogue_balloon(dialogue, "start")

	_load_animals()
	_process_time()

# Runs the main game updates every frame, including the passage of in-game time,
# day changes, pause controls and the movement of the selected item's placement preview.
# The preview also changes colour to show whether the current location is valid for placement.
func _process(delta: float) -> void:
	Global.game_seconds += delta * time_speed_multiplier

	if Global.game_seconds >= SECONDS:
		Global.game_seconds -= SECONDS
		Global.current_day += 1

	_process_time()

	if Input.is_action_just_pressed("pause"):
		_pause()

	if ghost != null:
		ghost.global_position = get_global_mouse_position()

		if can_place:
			ghost.modulate = Color(1.0, 1.0, 1.0, 0.6)
		else:
			ghost.modulate = Color(1.0, 0.3, 0.3, 0.6)

# Toggles the game's paused state when the player uses the pause control.
# The pause menu is made visible or hidden at the same time so the interface
# matches whether the game is currently paused.
func _pause() -> void:
	var new_pause = not get_tree().paused
	get_tree().paused = new_pause

	if pause_menu:
		pause_menu.visible = new_pause

# Calculates the current hour and minute from the Global game clock and updates
# the scene's lighting according to different times of day. The lighting gradually
# transitions between colours at sunrise and sunset before sending the updated time to the UI.
func _process_time() -> void:
	var current_hour = int(Global.game_seconds / 3600) % 24
	var current_minute = int(fmod(Global.game_seconds, 3600) / 60)

	if canvas_modulate:
		var midnight_color = Color(0.15, 0.15, 0.4)
		var sunrise_color = Color(0.9, 0.4, 0.5)
		var midday_color = Color(1.0, 1.0, 1.0)
		var sunset_color = Color(1.0, 0.6, 0.3)

		var time_in_hours = Global.game_seconds / 3600.0

		if time_in_hours >= 0.0 and time_in_hours < 4.0:
			canvas_modulate.color = midnight_color
		elif time_in_hours >= 4.0 and time_in_hours < 5.0:
			var t = time_in_hours - 4.0
			canvas_modulate.color = midnight_color.lerp(sunrise_color, t)
		elif time_in_hours >= 5.0 and time_in_hours < 6.0:
			var t = time_in_hours - 5.0
			canvas_modulate.color = sunrise_color.lerp(midday_color, t)
		elif time_in_hours >= 6.0 and time_in_hours < 18.0:
			canvas_modulate.color = midday_color
		elif time_in_hours >= 18.0 and time_in_hours < 20.0:
			var t = (time_in_hours - 18.0) / 2.0
			canvas_modulate.color = midday_color.lerp(sunset_color, t)
		elif time_in_hours >= 20.0 and time_in_hours < 22.0:
			var t = (time_in_hours - 20.0) / 2.0
			canvas_modulate.color = sunset_color.lerp(midnight_color, t)
		else:
			canvas_modulate.color = midnight_color

	game_time_updated.emit(current_hour, current_minute, Global.current_day)

# Handles mouse input while the player is placing an animal in the game world.
# A left click confirms the placement when the location is valid, while a right click
# cancels the current placement and removes the preview.
func _incorrect_input(event: InputEvent) -> void:
	if ghost == null:
		return

	if event.is_action_pressed("mouse_click"):
		if can_place:
			_place_animal()
	elif event.is_action_pressed("right_click"):
		_cancel_placement()

# Starts the animal placement process by checking that the selected item has a
# corresponding scene and creating a ghost preview that follows the mouse.
# The selected item name is stored so it can later be spawned when placement is confirmed.
func placement(item_name: String, item_texture: Texture2D) -> void:
	_cancel_placement()

	if not ITEMS.has(item_name):
		return

	current_item_name = item_name

	ghost = Sprite2D.new()
	ghost.texture = item_texture
	ghost.z_index = 10
	add_child(ghost)

# Places the selected animal at the mouse position and records its information
# in Global so it can be recreated when the scene is loaded again. The item is
# removed from the inventory after successful placement and the preview is cancelled.
func _place_animal() -> void:
	var spawn_pos = get_global_mouse_position()

	_spawn_animal(current_item_name, spawn_pos)

	var item_data = {
		"name": current_item_name,
		"position": spawn_pos
	}

	Global.placed_animals.append(item_data)
	Global.remove_from_inventory(current_item_name)
	_cancel_placement()

# Creates an instance of the selected animal's scene and places it at the given
# position. The animal is added to the dedicated AnimalContainer when available,
# keeping placed animals organised separately from the rest of the scene.
func _spawn_animal(item_name: String, pos: Vector2) -> void:
	if not ITEMS.has(item_name):
		return

	var scene_to_spawn = ITEMS[item_name]
	var new_item = scene_to_spawn.instantiate()
	new_item.global_position = pos

	if animal_container:
		animal_container.add_child(new_item)
	else:
		add_child(new_item)

# Recreates all animals that were previously placed by reading their saved names
# and positions from Global. This allows animals to remain in the same locations
# when the player returns to the game scene.
func _load_animals() -> void:
	for item_data in Global.placed_animals:
		_spawn_animal(item_data["name"], item_data["position"])

# Cancels the current animal placement by deleting the ghost preview and clearing
# the selected item name. This prevents an unfinished placement from remaining
# active after the player cancels or successfully places an animal.
func _cancel_placement() -> void:
	if ghost != null:
		ghost.queue_free()
		ghost = null

	current_item_name = ""

# Detects when the player enters the boundary area and returns them to the defined
# spawn point before reloading the scene. This prevents the player from remaining
# outside the playable area.
func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position = spawn_point.global_position
		get_tree().reload_current_scene()

# Detects when the player enters the market door and saves their current position
# before changing to the market scene. The saved position allows the player to
# return to the appropriate location after leaving the market.
func _on_market_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
		get_tree().change_scene_to_file("res://scenes/market.tscn")

# Detects when the player leaves the house and saves their current position before
# returning to the main game scene. This allows the player to continue from the
# doorway rather than being placed at the default starting location.
func _on_house_door_outside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
		get_tree().change_scene_to_file("res://scenes/game_with_house.tscn")

# Allows animal placement when the mouse enters the first valid placement zone.
# The can_place variable is used by the placement system to determine whether
# the current mouse position is suitable for placing an animal.
func _on_fence_zone_mouse_entered() -> void:
	can_place = true

# Prevents animal placement when the mouse leaves the first valid placement zone.
# This ensures the player cannot confirm an animal placement outside the allowed area.
func _on_fence_zone_mouse_exited() -> void:
	can_place = false

# Allows animal placement when the mouse enters the second valid placement zone.
# Both placement areas use the same can_place variable so the placement system
# can treat them as valid locations.
func _on_fence_zone_2_mouse_entered() -> void:
	can_place = true

# Prevents animal placement after the mouse leaves the second valid placement zone.
# This updates the placement state so the ghost preview can indicate that placement
# is no longer allowed.
func _on_fence_zone_2_mouse_exited() -> void:
	can_place = false
	
