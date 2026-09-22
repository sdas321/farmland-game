extends TextureButton

# Connects the button to its selection function when the scene loads.
func _ready() -> void:
	pressed.connect(self._on_button_pressed)

# Selects the watering can as the player's current item.
func _on_button_pressed() -> void:
	Global.selected_item = "watering_can"
