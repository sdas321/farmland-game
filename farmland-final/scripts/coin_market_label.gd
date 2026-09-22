extends Label


# Connects the label to the global coin system and displays the current coin amount.
func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_updated)
	text = "Coins: " + str(Global.coins)


# Updates the displayed coin amount when the global coin value changes.
func _on_coins_updated(coins: int) -> void:
	text = "Coins: " + str(coins)
