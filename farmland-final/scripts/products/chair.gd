extends TextureRect

@export var item_name: String = "chair"
@export var item_cost: int = 180

func _on_purchase_button_pressed() -> void:
	Global.buy_item("chair")
