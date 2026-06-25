extends PanelContainer



@onready var slot_container = $Inventory/MarginContainer/HBoxContainer 

func _ready() -> void:
	Global.inventory_updated.connect(self._on_inventory_changed)
	_refresh_inventory_ui()

func _on_inventory_changed() -> void:
	_refresh_inventory_ui()

func _refresh_inventory_ui() -> void:
	if slot_container == null:
		push_error("Cannot find HBoxContainer! Double-check your node path.")
		return
		
	var physical_slots = slot_container.get_children()
	
	for i in range(physical_slots.size()):
		var slot_node = physical_slots[i]
		
		if i < Global.inventory.size():
			var item_name = Global.inventory[i]
			
			slot_node.visible = true # Ensure the slot is active
			print("Filled slot index ", i, " with item: ", item_name)
			
		else:
			# If the player doesn't own enough items to reach this slot, keep it empty
			if slot_node.has_node("Label"):
				slot_node.get_node("Label").text = ""
			
			
