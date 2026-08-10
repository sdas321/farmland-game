extends Label

func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_changed)
	text = str(Global.coins) 

func _on_coins_changed(new_amount: int) -> void:
	text = str(new_amount)
