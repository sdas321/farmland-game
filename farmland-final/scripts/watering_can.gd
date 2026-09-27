extends TextureButton


# Connects the button's pressed signal to the watering-can selection function
# when the scene loads, allowing the button to respond to player interaction.
func _ready() -> void:
	pressed.connect(self._on_button_pressed)


# Sets the watering can as the currently selected item in Global.
# The crop script checks this value before allowing the player to water crops,
# linking the inventory/tool selection system with crop interaction.
func _on_button_pressed() -> void:
	Global.selected_item = Global.ITEM_WATERING_CAN
