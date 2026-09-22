extends PanelContainer

@onready var slot: HBoxContainer = %HBoxContainer

var products: Dictionary = {
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

var item_textures: Dictionary = {}

# Initialises the inventory interface when the scene loads by collecting item
# textures, connecting the Global inventory signal, setting up slot buttons and
# refreshing the visible inventory so it matches the player's current items.
func _ready() -> void:
	_spawn_items()

	if not Global.inventory_updated.is_connected(self._on_inventory_changed):
		Global.inventory_updated.connect(self._on_inventory_changed)

	_slot_signals()
	_refresh_inventory()

# Temporarily creates each product scene to find the texture used by that item.
# The textures are stored in a dictionary for later use by the inventory slots,
# and the temporary instances are freed afterwards to avoid unnecessary objects.
func _spawn_items() -> void:
	for item_name in products.keys():
		var scene: PackedScene = products[item_name]

		if scene:
			var instance = scene.instantiate()
			var texture: Texture2D = null

			if instance is Sprite2D:
				texture = instance.texture
			elif instance is TextureRect:
				texture = instance.texture
			else:
				for child in instance.get_children():
					if child is Sprite2D or child is TextureRect:
						texture = child.texture
						break

			if texture:
				item_textures[item_name] = texture

			instance.queue_free()

# Refreshes the inventory display whenever Global signals that the player's
# inventory has changed. Keeping this as a separate function allows purchases
# and item placement to update the interface automatically.
func _on_inventory_changed() -> void:
	_refresh_inventory()

# Connects each inventory TextureButton to the same input function while passing
# its individual slot index. Existing connections are removed first to prevent
# the same button from triggering the function multiple times.
func _slot_signals() -> void:
	if slot == null:
		return

	var p_slots = slot.get_children()

	for i in range(p_slots.size()):
		var slot_button = p_slots[i]

		if slot_button is TextureButton:
			if slot_button.pressed.is_connected(self._on_inventory_slot_pressed):
				slot_button.pressed.disconnect(self._on_inventory_slot_pressed)

			slot_button.pressed.connect(self._on_inventory_slot_pressed.bind(i))

# Updates every inventory slot to match the items stored in Global.inventory.
# Occupied slots receive the correct texture and item name, while unused slots
# are cleared so that old items are not displayed after they have been removed.
func _refresh_inventory() -> void:
	if slot == null:
		return

	var p_slots = slot.get_children()

	for i in range(p_slots.size()):
		var slot_button = p_slots[i]

		if slot_button is TextureButton:
			if i < Global.inventory.size():
				var item_name = str(Global.inventory[i]).to_lower().strip_edges()

				if item_textures.has(item_name):
					slot_button.texture_normal = item_textures[item_name]

				if slot_button.has_node("Label"):
					slot_button.get_node("Label").text = item_name.capitalize()
			else:
				slot_button.texture_normal = null

				if slot_button.has_node("Label"):
					slot_button.get_node("Label").text = ""

# Handles the player selecting an item from an inventory slot. It checks that the
# slot contains an item and that its texture is available before asking the current
# game scene to begin the appropriate placement process.
func _on_inventory_slot_pressed(slot_index: int) -> void:
	if slot_index >= Global.inventory.size():
		return

	var slot_item_name = str(Global.inventory[slot_index]).to_lower().strip_edges()

	var slot_texture = item_textures.get(slot_item_name)

	if slot_texture == null:
		return

	var main_scene = get_tree().current_scene

	if main_scene.has_method("start_placement"):
		main_scene.start_placement(slot_item_name, slot_texture)
