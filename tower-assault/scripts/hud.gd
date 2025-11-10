extends CanvasLayer

signal start_game
signal build_tower
signal spawn_soldier

var soldier_cost = 25
var tower_cost = 50

var countdown_timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BuildTower.hide()
	$WaveCountdownLabel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if countdown_timer:
		var time_left = ceil(countdown_timer.time_left)
		$WaveCountdownLabel.text = "Next Wave in: " + str(time_left)

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


func _on_spawn_soldier_button_pressed() -> void:
	spawn_soldier.emit()

func update_currency(amount):
	$CurrencyLabel.text = "Gold: " + str(amount)

func check_button_costs(current_currency):
	# --- Check Soldier Button ---
	if current_currency >= soldier_cost:
		$SpawnSoldierButton.disabled = false
	else:
		$SpawnSoldierButton.disabled = true
		
	# --- Check Tower Button ---
	if current_currency >= tower_cost:
		$BuildTower.disabled = false
	else:
		$BuildTower.disabled = true

func start_wave_countdown(timer_node):
	countdown_timer = timer_node
	$WaveCountdownLabel.show()

func stop_wave_countdown():
	countdown_timer = null
	$WaveCountdownLabel.hide()
