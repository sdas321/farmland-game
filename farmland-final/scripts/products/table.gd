extends TextureRect
@export var item_name: String = "table"
@export var item_cost: int = 250

func _on_purchase_button_pressed() -> void:
	Global.buy_item("table")
	
