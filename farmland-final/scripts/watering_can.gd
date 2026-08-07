extends TextureButton

func _ready() -> void:
	pressed.connect(self._on_button_pressed)

func _on_button_pressed() -> void:
	Global.selected_item = "watering_can"
	print("Watering can selected!")
	
