extends PanelContainer

@onready var slot_container: HBoxContainer = %HBoxContainer


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

func _ready() -> void:
	_extract_textures_from_scenes()
	
	if not Global.inventory_updated.is_connected(self._on_inventory_changed):
		Global.inventory_updated.connect(self._on_inventory_changed)
		
	_refresh_inventory()

func _extract_textures_from_scenes() -> void:
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

func _on_inventory_changed() -> void:
	_refresh_inventory()

func _refresh_inventory() -> void:
	if slot_container == null:
		return

	var physical_slots = slot_container.get_children()

	for i in range(physical_slots.size()):
		var slot_button = physical_slots[i]

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
