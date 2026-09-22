extends Area2D

@export var sprite: AnimatedSprite2D
@export var progress_bar: ProgressBar
@export var crop_name: String = "Wheat"
@export var coins: int = 10000
@export var max_water: float = 100.0
@export var water_speed: float = 50.0

var crop_id: String = ""
var current_water: float = 0.0
var is_grown: bool = false
var is_mouse_inside: bool = false


# Initialises the crop when it is created by checking that its sprite exists,
# generating a unique ID from its position, and connecting the signals needed
# for player interaction and mouse detection. It also checks Global.plant_data
# to restore the crop's previous watering and growth progress, or starts a new
# crop in its default state if no saved data exists.
func _ready() -> void:
	if sprite == null:
		return

	crop_id = "crop_" + str(int(round(global_position.x))) + "_" + str(int(round(global_position.y)))

	body_entered.connect(self._on_body_entered)
	mouse_entered.connect(self._on_mouse_entered)
	mouse_exited.connect(self._on_mouse_exited)

	if Global.plant_data.has(crop_id):
		current_water = Global.plant_data[crop_id].get("current_water", 0.0)
		is_grown = Global.plant_data[crop_id].get("is_grown", false)
		growing()
	else:
		default()


# Resets the crop to its starting state by removing all stored watering progress
# and marking it as not fully grown. The progress bar is reset to zero and made
# visible, while the animated sprite is stopped and returned to its first frame
# to visually show that the crop needs to be watered again.
func default() -> void:
	is_grown = false
	current_water = 0.0
	
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = max_water
		progress_bar.visible = true

	if sprite:
		sprite.stop()
		sprite.frame = 0


# Updates the crop's visual growth state using its current amount of water.
# The progress bar displays how much water has been added, while the sprite frame
# changes according to the watering ratio so the crop visually develops as it grows.
# Once the crop is fully grown, the progress bar is hidden because no more watering
# is required until the crop is collected and reset.
func growing() -> void:
	if progress_bar:
		progress_bar.max_value = max_water
		progress_bar.value = current_water
		progress_bar.visible = not is_grown

	var ratio: float = current_water / max_water

	if sprite:
		if is_grown:
			sprite.frame = 3
		else:
			sprite.frame = int(ratio * 4.0)


# Stores the crop's current watering amount and growth state in Global.plant_data.
# The crop ID is used as the dictionary key so that each individual crop can have
# its own saved progress and return to the same state after changing scenes.
func save_crop_state() -> void:
	Global.plant_data[crop_id] = {
		"current_water": current_water,
		"is_grown": is_grown
	}


# Resets the crop back to its starting state and immediately saves those changes
# to Global. This ensures that after a fully grown crop is collected, its reset
# state is remembered instead of returning to its previous grown state.
func reset_crop() -> void:
	default()
	save_crop_state()


# Checks every frame whether the player is currently interacting with the crop.
# Watering is only allowed while the mouse is inside the crop's interaction area,
# the player is holding the left mouse button, and the watering can is selected
# as the current item in Global.
func _process(delta: float) -> void:
	if is_grown:
		return

	if is_mouse_inside and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Global.selected_item == "watering_can":
			water_crop(delta)


# Increases the crop's water level according to the watering speed and the amount
# of time that has passed since the previous frame. The water level is limited to
# the maximum value, then the progress bar and sprite are updated to represent the
# current growth stage. When the water reaches the maximum, the crop is marked as
# fully grown, its final sprite frame is displayed, and the progress bar is hidden.
# The updated state is saved so the crop keeps its progress when the scene changes.
func water_crop(delta: float) -> void:
	current_water += water_speed * delta
	current_water = min(current_water, max_water)

	if progress_bar:
		progress_bar.value = current_water

	var ratio: float = current_water / max_water

	if ratio < 1.0:
		if sprite:
			sprite.frame = int(ratio * 4.0)
	else:
		if sprite:
			sprite.frame = 3

		is_grown = true

		if progress_bar:
			progress_bar.visible = false

	save_crop_state()


# Detects when another body enters the crop's Area2D and checks whether the crop
# is fully grown and the entering body is the player. If both conditions are met,
# the collection function is called so the player receives the crop's reward.
func _on_body_entered(body: Node2D) -> void:
	if is_grown and "player" in body.name.to_lower():
		collection()


# Rewards the player with the number of coins assigned to the crop through Global.
# After the reward is given, the crop is reset and its new state is saved so it can
# be watered and grown again as part of the game's farming cycle.
func collection() -> void:
	Global.add_coins(coins)
	reset_crop()


# Records that the mouse has entered the crop's interaction area. This allows the
# _process function to recognise that the player is currently pointing at the crop
# and can begin watering it if the correct tool is selected.
func _on_mouse_entered() -> void:
	is_mouse_inside = true


# Records that the mouse has left the crop's interaction area. This prevents the
# crop from continuing to receive watering input when the player's cursor is no
# longer positioned over the crop.
func _on_mouse_exited() -> void:
	is_mouse_inside = false
