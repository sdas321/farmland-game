extends Control

@onready var object_container: HBoxContainer = %objects
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var name_label: Label = %ItemNameLabel
@onready var price_label: Label = %ItemPriceLabel
@onready var toast = $Toast
@onready var close: AudioStreamPlayer2D = $close
@onready var scroll: AudioStreamPlayer2D = $scroll
@onready var success: AudioStreamPlayer2D = $success
@onready var error: AudioStreamPlayer2D = $error
@onready var musiccc: AudioStreamPlayer2D = $musiccc


# Controls the current market selection and scrolling position.
# Keeping these values separately allows the selected product and its visual
# position in the ScrollContainer to remain synchronised.
var target_scroll: float = 0.0
var index: int = 0


# Starts the market selection system when the scene loads.
# The short delay allows the product containers to finish their layout before
# the first product is highlighted.
func _ready() -> void:
	_selection()
	musiccc.play()


# Waits for the market interface to finish laying out its children before
# highlighting the first available product. This prevents the initial highlight
# from being calculated using incomplete UI dimensions.
func _selection() -> void:
	await get_tree().create_timer(0.01).timeout
	_highlight()


# Moves the selected product one position backwards when the first product
# has not already been reached. The selection and scroll position are updated
# together so the visual interface remains synchronised.
func _on_previous_pressed() -> void:
	if index <= 0:
		return

	var scroll_value := target_scroll - _scroll(-1)

	index -= 1
	_highlight()

	await _tween_scroll(scroll_value)
	scroll.play()


# Moves the selected product one position forwards when the final product has
# not already been reached. The selected product is highlighted before the
# ScrollContainer smoothly moves to its new position.
func _on_next_pressed() -> void:
	if index >= object_container.get_child_count() - 1:
		return

	var scroll_value := target_scroll + _scroll(1)

	index += 1
	_highlight()

	await _tween_scroll(scroll_value)
	scroll.play()


# Calculates the horizontal distance required to move from the current product
# to the neighbouring product. The calculation uses both product widths and the
# container separation so the selected product is positioned correctly.
func _scroll(direction: int) -> float:
	var separation = object_container.get_theme_constant("separation")
	var children = object_container.get_children()
	var current_obj = children[index]
	var current_half_width = current_obj.size.x / 2.0
	var next_item_index = index + direction
	var next_obj = children[next_item_index]
	var next_half_width = next_obj.size.x / 2.0

	return current_half_width + separation + next_half_width
	

# Calculates the space occupied by the currently selected product and the
# container separation. It returns zero when the container does not contain
# enough children for the calculation.
func _get_space_between() -> int:
	if object_container.get_child_count() < 2:
		return 0

	var distance_size := object_container.get_theme_constant("separation")
	var object_size :float = object_container.get_children()[index].size.x

	return distance_size + object_size


# Highlights the currently selected product and darkens the other products.
# This provides clear visual feedback about which item will be purchased when
# the player presses the purchase button.
func _highlight() -> void:
	var children := object_container.get_children()

	for i in range(children.size()):
		var object = children[i]

		if not object is TextureRect:
			continue

		if i == index:
			object.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			object.modulate = Color(0.0, 0.0, 0.0, 1.0)


# Smoothly moves the ScrollContainer towards the requested horizontal position.
# Waiting for the tween and the next process frame allows the animation to finish
# cleanly before another market selection is processed.
func _tween_scroll(scroll_value: float) -> void:
	target_scroll = scroll_value

	var tween := get_tree().create_tween()

	tween.tween_property(scroll_container,"scroll_horizontal",scroll_value,0.25)

	await tween.finished
	await get_tree().process_frame


# Checks the currently selected product and attempts to purchase it.
# The player's coins are only changed after confirming that the product is valid
# and affordable, and the success notification is only displayed after purchase.
func _on_purchase_pressed() -> void:
	var children := object_container.get_children()


	if children.size() == 0:
		return

	var valid_items: Array = []

	for child in children:
		if child is VBoxContainer:
			valid_items.append(child)
		else:
			continue

	if valid_items.size() == 0 or index >= valid_items.size():
		return

	var active_node = valid_items[index]
	var active_product = active_node

	if active_node.get_child_count() > 0:
		active_product = active_node.get_child(0)

	var cost = active_product.get("item_cost")
	var item_name = active_product.get("item_name")

	if item_name == null:
		item_name = active_product.name.to_lower()
	if cost == null:
		return

	if Global.coins >= cost:
		Global.purchase(cost)
		Global.add_to_inventory(item_name)

		Toast.show_toast(Global.PURCHASE_SUCCESS_MESSAGE, 2.0)
		success.play()

	else:
		Toast.show_toast(Global.NOT_ENOUGH_COINS_MESSAGE,2.0)
		error.play()



# Returns the player from the market to the main game scene.
# Inventory and purchased items remain stored in Global, so returning to the
# main scene does not remove any progress made inside the market.
func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.GAME_SCENE)
