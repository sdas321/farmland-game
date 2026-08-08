extends PanelContainer

@onready var slot_container = $Inventory/MarginContainer/HBoxContainer 

func _ready() -> void:
	Global.inventory_updated.connect(self._on_inventory_changed)
	_refresh_inventory()

func _on_inventory_changed() -> void:
	_refresh_inventory()

func _refresh_inventory() -> void:
	if slot_container == null:
		return
		
	var physical_slots = slot_container.get_children()
	
	for i in range(physical_slots.size()):
		var slot_node = physical_slots[i]
		
		if i < Global.inventory.size():
			var item_name = Global.inventory[i]
			slot_node.visible = true
			if slot_node.has_node("Label"):
				slot_node.get_node("Label").text = str(item_name)
		else:
			if slot_node.has_node("Label"):
				slot_node.get_node("Label").text = ""
