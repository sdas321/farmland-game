extends TextureRect

@export var item_name: String = "painting"
@export var item_cost: int = 1200


func _on_purchase_button_pressed() -> void:
	Global.buy_item("painting")
