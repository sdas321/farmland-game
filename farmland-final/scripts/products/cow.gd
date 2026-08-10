extends TextureRect
@export var item_name: String = "cow"
@export var item_cost: int = 2200

func _on_purchase_button_pressed() -> void:
	Global.buy_item("cow")
