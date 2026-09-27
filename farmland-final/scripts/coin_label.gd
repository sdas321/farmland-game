extends Label

# Connects the label to the Global coin system when the scene starts and displays
# the player's current coin total so the UI is correct as soon as it appears.
func _ready() -> void:
	Global.coins_changed.connect(self._on_coins_changed)
	text = str(Global.coins)

# Updates the coin display whenever the player's coin total changes.
# The new value is received through the coins_changed signal from the Global script,
# keeping the label synchronised with the player's current amount.
func _on_coins_changed(coins: int) -> void:
	text = "Coins:" + str(coins)
