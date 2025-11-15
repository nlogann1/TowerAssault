extends Control

func _ready():
	$VBoxContainer/Map1Button.pressed.connect(_on_map_1_button_pressed)
	$VBoxContainer/Map2Button.pressed.connect(_on_map_2_button_pressed)
	$VBoxContainer/Map3Button.pressed.connect(_on_map_3_button_pressed)
	$VBoxContainer/Map4Button.pressed.connect(_on_map_4_button_pressed)
	$VBoxContainer/Map5Button.pressed.connect(_on_map_5_button_pressed)
	$VBoxContainer/Map6Button.pressed.connect(_on_map_6_button_pressed)
	$BackButton.pressed.connect(_on_back_button_pressed)

func _on_map_1_button_pressed():
	# This loads your original map
	get_tree().change_scene_to_file("res://scenes/main.tscn")

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
