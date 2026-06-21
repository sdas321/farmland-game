extends Label

func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_updated)
	text = "Coins: " + str(Global.coins)

func _on_coins_updated(new_amount: int) -> void:
	text = "Coins: " + str(new_amount)
