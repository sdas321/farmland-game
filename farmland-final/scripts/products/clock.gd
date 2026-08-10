extends TextureRect
@export var item_name: String = "clock"
@export var item_cost: int = 150

func _on_purchase_button_pressed() -> void:
	Global.buy_item("clock")
