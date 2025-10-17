extends Control

# Get a reference to the nodes we need to control.
@onready var scroll_animation = $ScrollButtonAnimation
@onready var start_button = $"VBoxContainer/Button (Start Game)"

func _ready():
	
	start_button.modulate.a = 0
	start_button.disabled = true
	
	scroll_animation.play()

func _on_button_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_2_quit_pressed():
	get_tree().quit()

func _on_scroll_button_animation_animation_finished() -> void:

	start_button.modulate.a = 1
	start_button.disabled = false
