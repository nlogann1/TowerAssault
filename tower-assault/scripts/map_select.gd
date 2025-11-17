extends Control
@onready var background_anim = $AnimatedSprite2D
func _ready():
	# Connect all the button signals to their functions
	$MarginContainer/VBoxContainer/GridContainer/Map1/Map1Button.pressed.connect(_on_map_1_button_pressed)
	$MarginContainer/VBoxContainer/GridContainer/Map2/Map2Button.pressed.connect(_on_map_2_button_pressed)
	$MarginContainer/VBoxContainer/GridContainer/Map3/Map3Button.pressed.connect(_on_map_3_button_pressed)
	$MarginContainer/VBoxContainer/GridContainer/Map4/Map4Button.pressed.connect(_on_map_4_button_pressed)
	$MarginContainer/VBoxContainer/GridContainer/Map5/Map5Button.pressed.connect(_on_map_5_button_pressed)
	$MarginContainer/VBoxContainer/GridContainer/Map6/Map6Button.pressed.connect(_on_map_6_button_pressed)
	$MarginContainer/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	background_anim.play("background")

func _on_map_1_button_pressed():
	# This loads your original map (main.tscn)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	# print("Loading Map 1") # We don't need this line anymore

func _on_map_2_button_pressed():
	# This loads your new map
	get_tree().change_scene_to_file("res://scenes/map_2.tscn")

func _on_map_3_button_pressed():
	# This loads your new map
	get_tree().change_scene_to_file("res://scenes/map_3.tscn")

func _on_map_4_button_pressed():
	# This loads your new map
	get_tree().change_scene_to_file("res://scenes/map_4.tscn")

func _on_map_5_button_pressed():
	# This loads your new map
	get_tree().change_scene_to_file("res://scenes/map_5.tscn")

func _on_map_6_button_pressed():
	# This loads your new map
	get_tree().change_scene_to_file("res://scenes/map_6.tscn")
	
func _on_back_button_pressed():
	# This goes back to the main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
