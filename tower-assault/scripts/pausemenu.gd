extends CanvasLayer
var levels = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_button_pressed() -> void:
	get_tree().call_group("HUD", "pause", false)
	unpause()

func _on_levels_button_pressed() -> void:
	if levels:
		levels = false
		$Map1Button.hide()
		$Map2Button.hide()
		$Map3Button.hide()
		$Map4Button.hide()
		$Map5Button.hide()
		$Map6Button.hide()
	else:
		levels = true
		$Map1Button.show()
		$Map2Button.show()
		$Map3Button.show()
		$Map4Button.show()
		$Map5Button.show()
		$Map6Button.show()

func unpause():
	levels = false
	$Map1Button.hide()
	$Map2Button.hide()
	$Map3Button.hide()
	$Map4Button.hide()
	$Map5Button.hide()
	$Map6Button.hide()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_restart_button_pressed() -> void:
	get_tree().call_group("main", "new_game")
	get_tree().call_group("HUD", "pause", false)
	unpause()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_map_1_button_pressed():
	get_tree().call_group("main", "change_map", 0)

func _on_map_2_button_pressed():
	get_tree().call_group("main", "change_map", 1)

func _on_map_3_button_pressed():
	get_tree().call_group("main", "change_map", 2)

func _on_map_4_button_pressed():
	get_tree().call_group("main", "change_map", 3)

func _on_map_5_button_pressed():
	get_tree().call_group("main", "change_map", 4)

func _on_map_6_button_pressed():
	get_tree().call_group("main", "change_map", 5)
