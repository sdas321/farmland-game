extends Node2D

@onready var furniture_container = $FurnitureContainer

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

var ghost: Sprite2D = null
var current_item_name: String = ""
var can_place: bool = false

# Loads the furniture that was previously placed by the player when the house scene starts. 
# This restores saved furniture so it remains in the house between scene changes.
func _ready() -> void:
	_load_furniture()

# Updates the position and appearance of the furniture preview every frame.
# The ghost follows the mouse and changes colour to show whether the current location is valid for
# placing the selected item.
func _process(_delta: float) -> void:
	if ghost != null:
		ghost.global_position = get_global_mouse_position()

		if can_place:
			ghost.modulate = Color(1.0, 1.0, 1.0, 0.6)
		else:
			ghost.modulate = Color(1.0, 0.3, 0.3, 0.6)

# Loops through the furniture saved in Global and recreates each item using its stored name and 
# position. This ensures furniture remains where the player originally placed it after returning 
# to the house.
func _load_furniture() -> void:
	for item_data in Global.placed_furniture:
		var item_name = item_data["name"]
		var pos = item_data["position"]
		_spawn_furniture(item_name, pos)

# Creates the selected furniture scene and places it at the supplied position.
# The item is added to the FurnitureContainer when available so all placed furniture is kept 
# organised within the house scene.
func _spawn_furniture(item_name: String, pos: Vector2) -> void:
	if not ITEMS.has(item_name):
		return

	var scene_to_spawn = ITEMS[item_name]
	var new_item = scene_to_spawn.instantiate()
	new_item.global_position = pos

	if furniture_container:
		furniture_container.add_child(new_item)
	else:
		add_child(new_item)

# Detects when the player enters the inside house door and returns them to the main game scene. 
# This provides the transition from the house back to the outside area.
func _on_house_door_inside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")

# Receives input events from the house door area. The function is currently empty
# because the actual door transition is handled by the body_entered signal instead.
func _on_house_door_inside_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass

# Handles mouse input while furniture is being placed. A left click confirms the
# placement if the location is valid, while a right click cancels the placement.
# A message is printed when the player attempts to place furniture in an invalid area.
func _incorrect_input(event: InputEvent) -> void:
	if ghost == null:
		return

	if event.is_action_pressed("mouse_click"):
		if can_place:
			_place_item()
		else:
			print("Cannot place item here!")

	elif event.is_action_pressed("right_click"):
		_cancel_placement()

# Begins the furniture placement process by checking that the selected item exists
# and creating a visual ghost using its texture. The preview follows the mouse until
# the player confirms or cancels the placement.
func start_placement(item_name: String, item_texture: Texture2D) -> void:
	_cancel_placement()

	if not ITEMS.has(item_name):
		return

	current_item_name = item_name

	ghost = Sprite2D.new()
	ghost.texture = item_texture
	ghost.z_index = 10
	add_child(ghost)

# Places the selected furniture item at the mouse position and saves its name and
# position in Global. The item is then removed from the player's inventory because
# it has been used, and the temporary placement preview is cleared.
func _place_item() -> void:
	var spawn_pos = get_global_mouse_position()

	_spawn_furniture(current_item_name, spawn_pos)

	var item_data = {
		"name": current_item_name,
		"position": spawn_pos
	}

	Global.placed_furniture.append(item_data)

	Global.remove_from_inventory(current_item_name)
	_cancel_placement()

# Cancels the current furniture placement by removing the temporary ghost sprite
# and clearing the selected item. This returns the placement system to an inactive state.
func _cancel_placement() -> void:
	if ghost != null:
		ghost.queue_free()
		ghost = null

	current_item_name = ""

# Marks the current position as valid when the mouse enters the designated
# furniture placement zone. The placement preview uses this value to change its appearance.
func _on_placement_zone_mouse_entered() -> void:
	can_place = true

# Marks the current position as invalid when the mouse leaves the designated
# furniture placement zone, preventing the player from placing furniture there.
func _on_placement_zone_mouse_exited() -> void:
	can_place = false
