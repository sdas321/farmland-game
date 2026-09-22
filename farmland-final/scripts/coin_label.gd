extends Label


# Connects the label to the global coin system and displays the current coin amount.
func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_changed)
	text = str(Global.coins) 
	
	
# Updates the label whenever the player's coin amount changes.
func _on_coins_changed(coins: int) -> void:
	text = "Coins:" + str(coins)
