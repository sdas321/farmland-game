extends Node2D
@export var spawn_point: Marker2D
@export var dialogue_resource: Resource
@export var dialogue = preload("res://tutorial.dialogue")
var balloon_scene = preload("res://scenes/balloon.tscn")
@onready var player: CharacterBody2D = %player
@onready var animal_container = $AnimalContainer
var current_ghost: Sprite2D = null
var current_item_name: String = ""
var can_place: bool = false
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


func _ready() -> void:
	if Global.player_saved_position:
		player.global_position = Global.player_spawn_position+ Vector2(0, 20)
	if dialogue and not Global.tutorial_played:
		Global.tutorial_played = true
		DialogueManager.show_dialogue_balloon(dialogue, "start")
	_load_placed_animals()
	

func _process(delta: float) -> void: 
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/pause_menu.tscn")
	if current_ghost != null:
		current_ghost.global_position = get_global_mouse_position()
		if can_place:
			current_ghost.modulate = Color(1.0, 1.0, 1.0, 0.6)
		else:
			current_ghost.modulate = Color(1.0, 0.3, 0.3, 0.6)

func _unhandled_input(event: InputEvent) -> void:
	if current_ghost == null: return
	
	if event.is_action_pressed("mouse_click"): 
		if can_place:
			_place_animal()
		else:
			print("Cannot place item outside the designated farm area!")
	elif event.is_action_pressed("right_click"): 
		_cancel_placement()


func start_placement(item_name: String, item_texture: Texture2D) -> void:
	_cancel_placement() 
	if not ITEM_SCENES.has(item_name): return
	current_item_name = item_name
	
	current_ghost = Sprite2D.new()
	current_ghost.texture = item_texture
	current_ghost.z_index = 10 
	add_child(current_ghost)

func _place_animal() -> void:
	var spawn_pos = get_global_mouse_position()
	

	_spawn_animal_node(current_item_name, spawn_pos)
	
	
	var item_data = {
		"name": current_item_name,
		"position": spawn_pos
	}
	Global.placed_animals.append(item_data)
	

	Global.remove_from_inventory(current_item_name)
	_cancel_placement()

func _spawn_animal_node(item_name: String, pos: Vector2) -> void:
	if not ITEM_SCENES.has(item_name): return
	
	var scene_to_spawn = ITEM_SCENES[item_name]
	var new_item = scene_to_spawn.instantiate()
	new_item.global_position = pos
	
	if animal_container:
		animal_container.add_child(new_item)
	else:
		add_child(new_item)

func _load_placed_animals() -> void:
	for item_data in Global.placed_animals:
		_spawn_animal_node(item_data["name"], item_data["position"])

func _cancel_placement() -> void:
	if current_ghost != null:
		current_ghost.queue_free()
		current_ghost = null
	current_item_name = ""
	

func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position= spawn_point.global_position
		get_tree().reload_current_scene() 


func _on_market_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
		get_tree().change_scene_to_file("res://scenes/market.tscn")


func _on_house_door_outside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
	
		get_tree().change_scene_to_file("res://scenes/game_with_house.tscn")
		
func _on_fence_zone_mouse_entered() -> void:
	can_place = true

func _on_fence_zone_mouse_exited() -> void:
	can_place = false



func _on_fence_zone_2_mouse_entered() -> void:
	can_place = true


func _on_fence_zone_2_mouse_exited() -> void:
	can_place = false
