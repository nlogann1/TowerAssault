extends CanvasLayer

signal start_game
signal build_tower

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BuildTower.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	
	$Message.text = "Don't let them escape!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = ("Score: " + str(score))

func update_lives(lives):
	$LivesLabel.text = ("Lives: " + str(lives))

func _on_start_button_pressed():
	$StartButton.hide()
	$BuildTower.show()
	start_game.emit()
	
func _on_build_tower_pressed() -> void:
	build_tower.emit()

func cancel_build_tower():
	$BuildTower.button_pressed = true
	$BuildTower.release_focus()

func _on_message_timer_timeout():
	$Message.hide()
