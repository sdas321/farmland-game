extends Node2D
@onready var furniture_container= $FurnitureContainer
const ITEM_SCENES: Dictionary = {
	"bed": preload("res://scenes/products/bed.tscn"),
	"carpet": preload("res://scenes/products/carpet.tscn"),
	"chair": preload("res://scenes/products/chair.tscn"),
	"chicken": preload("res://scenes/products/chicken.tscn"),
	"clock": preload("res://scenes/products/clock.tscn"),
	"cow": preload("res://scenes/products/cow.tscn"),
	"drawer": preload("res://scenes/products/drawer.tscn"),
	"lamp": preload("res://scenes/products/lamp.tscn"),
	"painting": preload("res://scenes/products/painting.tscn"),
	"table": preload("res://scenes/products/table.tscn")
}
var current_ghost: Sprite2D = null
var current_item_name: String = ""
var can_place: bool = false



func _ready() -> void:
	_load_placed_furniture()


func _process(_delta: float) -> void:
	
	if current_ghost != null:
		current_ghost.global_position = get_global_mouse_position()
		if can_place:
			current_ghost.modulate = Color(1.0, 1.0, 1.0, 0.6) # Translucent normal
		else:
			current_ghost.modulate = Color(1.0, 0.3, 0.3, 0.6)
			

func _load_placed_furniture() -> void:
	for item_data in Global.placed_furniture:
		var item_name = item_data["name"]
		var pos = item_data["position"]
		_spawn_furniture_node(item_name, pos)


func _spawn_furniture_node(item_name: String, pos: Vector2) -> void:
	if not ITEM_SCENES.has(item_name): return
	
	var scene_to_spawn = ITEM_SCENES[item_name]
	var new_item = scene_to_spawn.instantiate()
	new_item.global_position = pos
	
	
	if furniture_container:
		furniture_container.add_child(new_item)
	else:
		add_child(new_item)
		

func _on_house_door_inside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_house_door_inside_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass
		



func _unhandled_input(event: InputEvent) -> void:
	if current_ghost == null: return
	
	
	if event.is_action_pressed("mouse_click"): 
		if can_place:
			_place_item()
		else:
			print("Cannot place item here!")
			
	
	elif event.is_action_pressed("right_click"):
		_cancel_placement()


func start_placement(item_name: String, item_texture: Texture2D) -> void:
	_cancel_placement() 
	
	if not ITEM_SCENES.has(item_name):
		return
		
	current_item_name = item_name
	
	
	current_ghost = Sprite2D.new()
	current_ghost.texture = item_texture
	current_ghost.z_index = 10 
	add_child(current_ghost)

func _place_item() -> void:
	var spawn_pos = get_global_mouse_position()
	
	
	_spawn_furniture_node(current_item_name, spawn_pos)
	
	#
	var item_data = {
		"name": current_item_name,
		"position": spawn_pos
	}
	Global.placed_furniture.append(item_data)
	

	Global.remove_from_inventory(current_item_name)
	_cancel_placement()

func _cancel_placement() -> void:
	if current_ghost != null:
		current_ghost.queue_free()
		current_ghost = null
	current_item_name = ""


func _on_placement_zone_mouse_entered() -> void:
	can_place = true

func _on_placement_zone_mouse_exited() -> void:
	can_place = false
