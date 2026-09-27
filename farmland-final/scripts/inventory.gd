extends PanelContainer

@onready var slot: HBoxContainer = %HBoxContainer

var products: Dictionary = {
	Global.ITEM_BED: preload("res://scenes/products/bed.tscn"),
	Global.ITEM_CARPET: preload("res://scenes/products/carpet.tscn"),
	Global.ITEM_CHAIR: preload("res://scenes/products/chair.tscn"),
	Global.ITEM_CHICKEN: preload("res://scenes/products/chicken.tscn"),
	Global.ITEM_CLOCK: preload("res://scenes/products/clock.tscn"),
	Global.ITEM_COW: preload("res://scenes/products/cow.tscn"),
	Global.ITEM_DRAWER: preload("res://scenes/products/drawer.tscn"),
	Global.ITEM_LAMP: preload("res://scenes/products/lamp.tscn"),
	Global.ITEM_PAINTING: preload("res://scenes/products/painting.tscn"),
	Global.ITEM_TABLE: preload("res://scenes/products/table.tscn")
}

var item_textures: Dictionary = {}


# Gets the texture from each product scene so it can be displayed in the inventory.
# The product may use either a Sprite2D or TextureRect, so both types are checked.
func _spawn_items() -> void:
	for item_name in products.keys():
		var scene: PackedScene = products[item_name]

		if scene == null:
			continue

		var instance = scene.instantiate()
		var texture: Texture2D = null

		if instance is Sprite2D:
			texture = instance.texture

		elif instance is TextureRect:
			texture = instance.texture

		else:
			for child in instance.get_children():
				if child is Sprite2D:
					texture = child.texture
					break

				if child is TextureRect:
					texture = child.texture
					break

		if texture:
			item_textures[item_name] = texture

		instance.queue_free()


# Sets up the inventory slot buttons so clicking a slot selects its item.
# The slot index is passed into the click function so the correct inventory item is selected.
func _slot_signals() -> void:
	if slot == null:
		return

	var slots = slot.get_children()

	for i in range(slots.size()):
		var slot_button = slots[i]

		if slot_button is TextureButton:
			if slot_button.pressed.is_connected(_on_inventory_slot_pressed):
				slot_button.pressed.disconnect(_on_inventory_slot_pressed)

			slot_button.pressed.connect(
				_on_inventory_slot_pressed.bind(i)
			)


# Refreshes the visual contents of every inventory slot using Global.inventory.
# Empty slots are cleared, while occupied slots display their corresponding item texture and name.
func _refresh_inventory() -> void:
	if slot == null:
		return

	var slots = slot.get_children()

	for i in range(slots.size()):
		var slot_button = slots[i]

		if not slot_button is TextureButton:
			continue

		if i < Global.inventory.size():
			var item_name: String = str(Global.inventory[i]).to_lower().strip_edges()

			if item_textures.has(item_name):
				slot_button.texture_normal = item_textures[item_name]

			if slot_button.has_node("Label"):
				slot_button.get_node("Label").text = item_name.capitalize()

		else:
			slot_button.texture_normal = null

			if slot_button.has_node("Label"):
				slot_button.get_node("Label").text = ""


# Runs when the inventory changes and redraws the inventory slots.
func _on_inventory_changed() -> void:
	_refresh_inventory()


# Selects an item from the inventory and starts placement in the main game scene.
# Both furniture and animals are handled by the same start_placement function in game.gd.
func _on_inventory_slot_pressed(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= Global.inventory.size():
		return

	var item_name: String = str(Global.inventory[slot_index]).to_lower().strip_edges()
	var item_texture: Texture2D = item_textures.get(item_name)

	if item_texture == null:
		print("No texture found for: ", item_name)
		return

	var main_scene = get_tree().current_scene

	if main_scene.has_method(Global.PLACEMENT_METHOD):
		print("Selecting item: ", item_name)
		main_scene.start_placement(item_name, item_texture)
	else:
		print("start_placement() not found in current scene.")


# Sets up the inventory when the scene starts.
func _ready() -> void:
	_spawn_items()

	if not Global.inventory_updated.is_connected(_on_inventory_changed):
		Global.inventory_updated.connect(_on_inventory_changed)

	_slot_signals()
	_refresh_inventory()
