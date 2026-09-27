extends Node2D

signal game_time_updated(hour: int, minute: int, day: int)

const SECONDS_PER_DAY: float = 86400.0
const STARTING_TIME_SECONDS: float = 21600.0
const PLACEMENT_FURNITURE := "furniture"
const PLACEMENT_ANIMAL := "animal"
const NIGHT_COLOR := Color(0.15, 0.15, 0.4)
const SUNRISE_COLOR := Color(0.9, 0.4, 0.5)
const DAY_COLOR := Color(1.0, 1.0, 1.0)
const SUNSET_COLOR := Color(1.0, 0.6, 0.3)
const FURNITURE_SCENES: Dictionary = {
	Global.ITEM_BED: preload("res://scenes/products/bed.tscn"),
	Global.ITEM_CARPET: preload("res://scenes/products/carpet.tscn"),
	Global.ITEM_CHAIR: preload("res://scenes/products/chair.tscn"),
	Global.ITEM_CLOCK: preload("res://scenes/products/clock.tscn"),
	Global.ITEM_DRAWER: preload("res://scenes/products/drawer.tscn"),
	Global.ITEM_LAMP: preload("res://scenes/products/lamp.tscn"),
	Global.ITEM_PAINTING: preload("res://scenes/products/painting.tscn"),
	Global.ITEM_TABLE: preload("res://scenes/products/table.tscn")
}
const ANIMAL_SCENES: Dictionary = {
	Global.ITEM_CHICKEN: preload("res://scenes/products/chicken.tscn"),
	Global.ITEM_COW: preload("res://scenes/products/cow.tscn")
}

@export var time_speed_multiplier: float = 1500.0
@export var spawn_point: Marker2D
@export var dialogue_resource: Resource
@export var dialogue = preload("res://tutorial.dialogue")

var ghost: Sprite2D = null
var current_item_name: String = ""
var can_place: bool = false
var placement_type: String = ""
var mouse_over_placement_zone: bool = false
var mouse_over_fence_zone: bool = false
var mouse_over_fence_zone_2: bool = false
var transitioning_day: bool = false

@onready var placement: AudioStreamPlayer2D = $placement
@onready var day_transition: CanvasLayer = $DayTransition
@onready var day_fade: ColorRect = $DayTransition/Fade
@onready var day_label: Label = $DayTransition/Fade/DayLabel
@onready var player: CharacterBody2D = %player
@onready var animal_container: Node2D = $AnimalContainer
@onready var furniture_container: Node2D = $FurnitureContainer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var pause_menu: Control = $PauseLayer/PauseMenu
@onready var music_button: TextureButton = $"music/Music button"
@onready var music_player: AudioStreamPlayer2D = $"music/music player"

# Sets up the game when the scene starts.
# It restores the saved game state, loads placed animals and furniture,
# starts the tutorial if necessary, and updates the time of day.
func _ready() -> void:
	canvas_modulate.color = Color(0.2, 0.2, 0.2)
	if Global.game_seconds == 0.0 and Global.current_day == 1:
		Global.game_seconds = STARTING_TIME_SECONDS

	if Global.player_saved_position:
		player.global_position = Global.player_spawn_position + Vector2(0, 20)

	if dialogue and not Global.tutorial_played:
		Global.tutorial_played = true
		DialogueManager.show_dialogue_balloon(dialogue, "start")
	
	_load_animals()
	_load_furniture()
	_process_time()
	music_player.play()

# Updates the game clock and handles pause input every frame.
# It also moves and changes the colour of the placement ghost while an item is being placed.
func _process(delta: float) -> void:
	Global.game_seconds += delta * time_speed_multiplier

	if Global.game_seconds >= SECONDS_PER_DAY:
		Global.game_seconds -= SECONDS_PER_DAY
		Global.current_day += 1
	_process_time()

	if Input.is_action_just_pressed(Global.INPUT_PAUSE):
		_pause()

	if ghost != null:
		ghost.global_position = get_global_mouse_position()

		if can_place:
			ghost.modulate = Color(1.0, 1.0, 1.0, 0.6)
		else:
			ghost.modulate = Color(1.0, 0.3, 0.3, 0.6)

# Pauses or unpauses the game and displays the pause menu.
# The current pause state is reversed whenever the pause input is pressed.
func _pause() -> void:
	var new_pause: bool = not get_tree().paused
	get_tree().paused = new_pause

	if pause_menu:
		pause_menu.visible = new_pause

# Toggles the gameplay music on or off when the music button is pressed.
# The button changes its icon so the player can see whether music is currently enabled.
func _on_music_button_pressed() -> void:
	if music_player.playing:
		music_player.stop()
		music_button.texture_normal = preload("res://extra/off_icon.png")
	else:
		music_player.play()
		music_button.texture_normal = preload("res://extra/on_icon.png")

# Fades the screen to black, advances to the next day, resets the clock to 6 AM,
# displays the new day number, and then gradually fades the game back in.
func _start_next_day() -> void:
	if transitioning_day:
		return

	transitioning_day = true

	var fade_out := create_tween()
	fade_out.tween_property(day_fade, "color:a", 1.0, 1.5)
	await fade_out.finished

	Global.current_day += 1
	Global.game_seconds = STARTING_TIME_SECONDS

	day_label.text = "Day " + str(Global.current_day)

	await get_tree().create_timer(1.0).timeout

	var fade_in := create_tween()
	fade_in.tween_property(day_fade, "color:a", 0.0, 1.5)
	await fade_in.finished

	day_label.text = ""
	transitioning_day = false

func _on_sleep_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group(Global.PLAYER_GROUP):
		return

	if Global.game_seconds / 3600.0 >= 20.0:
		_start_next_day()
	
# Updates the clock and smoothly changes the screen tint throughout the day.
# The colour is interpolated between night, sunrise, daytime and sunset instead of switching abruptly.
func _process_time() -> void:
	var current_hour: int = int(Global.game_seconds / 3600.0) % 24
	var current_minute: int = int(fmod(Global.game_seconds, 3600.0) / 60.0)
	var time_in_hours: float = Global.game_seconds / 3600.0

	if canvas_modulate:
		if time_in_hours < 4.0:
			canvas_modulate.color = NIGHT_COLOR

		elif time_in_hours < 6.0:
			var t: float = (time_in_hours - 4.0) / 2.0
			canvas_modulate.color = NIGHT_COLOR.lerp(DAY_COLOR, t)

		elif time_in_hours < 17.0:
			canvas_modulate.color = DAY_COLOR

		elif time_in_hours < 20.0:
			var t: float = (time_in_hours - 17.0) / 3.0
			canvas_modulate.color = DAY_COLOR.lerp(SUNSET_COLOR, t)

		elif time_in_hours < 22.0:
			var t: float = (time_in_hours - 20.0) / 2.0
			canvas_modulate.color = SUNSET_COLOR.lerp(NIGHT_COLOR, t)

		else:
			canvas_modulate.color = NIGHT_COLOR

	game_time_updated.emit(current_hour, current_minute, Global.current_day)

# Starts the placement preview for a selected furniture item or animal.
# The item type determines which areas of the map will allow it to be placed.
func start_placement(item_name: String, item_texture: Texture2D) -> void:
	_cancel_placement()

	if FURNITURE_SCENES.has(item_name):
		placement_type = PLACEMENT_FURNITURE

	elif ANIMAL_SCENES.has(item_name):
		placement_type = PLACEMENT_ANIMAL

		return

	current_item_name = item_name

	ghost = Sprite2D.new()
	ghost.texture = item_texture
	ghost.z_index = 10
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.6)

	add_child(ghost)

	_update_can_place()

# Handles mouse input while an item is being placed.
# A left click places the item if the mouse is inside a valid zone,
# while a right click cancels the current placement.
func _unhandled_input(event: InputEvent) -> void:
	if ghost == null:
		return

	if event.is_action_pressed(Global.INPUT_MOUSE_CLICK):
		

		if can_place:
			_place_item()


	elif event.is_action_pressed(Global.INPUT_RIGHT_CLICK):
		_cancel_placement()

# Determines whether the selected item can currently be placed.
# Furniture uses the house placement zone, while animals use either fence zone.
func _update_can_place() -> void:
	if placement_type == PLACEMENT_FURNITURE:
		can_place = mouse_over_placement_zone
	elif placement_type == PLACEMENT_ANIMAL:
		can_place = true
	else:
		can_place = false


# Places the selected item at the mouse position and saves its position globally.
# The item is removed from the inventory after it has been successfully placed.
func _place_item() -> void:
	if ghost == null:
		return

	var spawn_position: Vector2 = get_global_mouse_position()

	if placement_type == PLACEMENT_FURNITURE:
		_spawn_furniture(current_item_name, spawn_position)

		Global.placed_furniture.append({
			Global.DATA_NAME: current_item_name,
			Global.DATA_POSITION: spawn_position
		})
		placement.play()

	elif placement_type == PLACEMENT_ANIMAL:
		_spawn_animal(current_item_name, spawn_position)

		Global.placed_animals.append({
			Global.DATA_NAME: current_item_name,
			Global.DATA_POSITION: spawn_position
		})
		placement.play()

	else:
		return

	Global.remove_from_inventory(current_item_name)
	_cancel_placement()

# Creates a furniture scene at the specified position.
# The furniture is added to FurnitureContainer so all placed furniture stays organised.
func _spawn_furniture(item_name: String, position: Vector2) -> void:
	if not FURNITURE_SCENES.has(item_name):
		return

	var furniture_scene: PackedScene = FURNITURE_SCENES[item_name]
	var furniture = furniture_scene.instantiate()

	furniture.global_position = position

	if furniture_container:
		furniture_container.add_child(furniture)
	else:
		add_child(furniture)

# Creates an animal scene at the specified position.
# The animal is added to AnimalContainer so all placed animals stay organised.
func _spawn_animal(item_name: String, position: Vector2) -> void:
	if not ANIMAL_SCENES.has(item_name):
		return

	var animal_scene: PackedScene = ANIMAL_SCENES[item_name]
	var animal = animal_scene.instantiate()

	animal.global_position = position

	if animal_container:
		animal_container.add_child(animal)
	else:
		add_child(animal)

# Loads all animals that were previously placed in the game.
# Their saved names and positions are used to recreate them when the scene starts.
func _load_animals() -> void:
	for item_data in Global.placed_animals:
		var item_name: String = item_data[Global.DATA_NAME]
		var position: Vector2 = item_data[Global.DATA_POSITION]

		_spawn_animal(item_name, position)

# Loads all furniture that was previously placed in the game.
# Their saved names and positions are used to recreate them when the scene starts.
func _load_furniture() -> void:
	for item_data in Global.placed_furniture:
		var item_name: String = item_data[Global.DATA_NAME]
		var position: Vector2 = item_data[Global.DATA_POSITION]

		_spawn_furniture(item_name, position)

# Cancels the current placement and removes the ghost.
# It also clears the selected item and resets the placement state.
func _cancel_placement() -> void:
	if ghost != null:
		ghost.queue_free()
		ghost = null

	current_item_name = ""
	placement_type = ""
	can_place = false

# Handles the player leaving the playable map boundaries.
# The player is returned to the spawn point and the current scene is reloaded.
func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group(Global.PLAYER_GROUP):
		body.global_position = spawn_point.global_position
		get_tree().reload_current_scene()

# Handles the player entering the market door.
# The player's position is saved before changing to the separate market scene.
func _on_market_door_body_entered(body: Node2D) -> void:
	if body.is_in_group(Global.PLAYER_GROUP):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true

		get_tree().change_scene_to_file(Global.MARKET_SCENE)

# Records that the mouse has entered the furniture placement area.
# The placement state is recalculated so furniture can immediately become placeable.
func _on_house_2_mouse_entered() -> void:
	mouse_over_placement_zone = true
	_update_can_place()

# Records that the mouse has left the furniture placement area.
# The placement state is recalculated so furniture can no longer be placed there.
func _on_house_2_mouse_exited() -> void:
	mouse_over_placement_zone = false
	_update_can_place()

# Records that the mouse has entered the first animal fence.
# The placement state is recalculated so animals can be placed inside the fence.
func _on_fence_zone_mouse_entered() -> void:
	mouse_over_fence_zone = true
	_update_can_place()

# Records that the mouse has left the first animal fence.
# The placement state is recalculated so animals cannot be placed outside the fence.
func _on_fence_zone_mouse_exited() -> void:
	mouse_over_fence_zone = false
	_update_can_place()

# Records that the mouse has entered the second animal fence.
# The placement state is recalculated so animals can be placed inside the fence.
func _on_fence_zone_2_mouse_entered() -> void:
	mouse_over_fence_zone_2 = true
	_update_can_place()

# Records that the mouse has left the second animal fence.
# The placement state is recalculated so animals cannot be placed outside the fence.
func _on_fence_zone_2_mouse_exited() -> void:
	mouse_over_fence_zone_2 = false
	_update_can_place()
