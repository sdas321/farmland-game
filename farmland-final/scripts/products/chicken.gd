extends TextureRect

@export var item_name: String = "chicken"
@export var item_cost: int = 2000

func _on_purchase_button_pressed() -> void:
	Global.buy_item("chicken")
