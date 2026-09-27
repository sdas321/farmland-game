extends Label

# Connects the label to the Global coin signal and displays the current number of coins
# when the scene loads, ensuring the starting value is shown immediately.
func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_updated)
	text = "Coins: " + str(Global.coins)

# Refreshes the displayed coin total whenever the Global script emits a new coin value.
# This keeps the player's currency information updated after purchases or rewards.
func _on_coins_updated(coins: int) -> void:
	text = "Coins: " + str(coins)
