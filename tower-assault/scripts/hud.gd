extends CanvasLayer

signal start_game
signal spawn_soldier
signal upgrade_base
signal build_archer
signal build_catapult

var soldier_cost = 25
var tower_cost = 50
var base_upgrade_cost = 100
var paused = false

var countdown_timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PauseButton.hide()
	$SpawnArcherButton.hide()
	$FreeGoldButton.hide()
	$SpawnSoldierIconButton.hide()
	$SpawnCatapultIconButton.hide()
	$UpgradeBaseButton.hide()
	$UpgradeCostLabel.hide()
	$WaveCountdownLabel.hide()
	$Inventory.hide()

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
	$StartButton.show()
	
	$Message.text = "Try again?"
	$Message.show()

func update_score(score):
	$ScoreLabel.text = ("Score: " + str(score))

func update_health(current_health, max_health):
	$BaseHealthBar.max_value = max_health
	$BaseHealthBar.value = current_health

func _on_start_button_pressed():
	$StartButton.hide()
	$Message.hide()
	$PauseButton.show()
	$SpawnArcherButton.show()
	$SpawnSoldierIconButton.show()
	$UpgradeBaseButton.show()
	$UpgradeCostLabel.show()
	$FreeGoldButton.show()
	$Inventory.show()
	$SpawnSoldierIconButton.show()
	$SpawnCatapultIconButton.show()
	paused = false
	start_game.emit()

func _on_build_tower_pressed() -> void:
	if not paused:
		build_archer.emit()

func cancel_build_tower():
	$SpawnArcherButton.button_pressed = false
	$SpawnArcherButton.release_focus()

func cancel_build_catapult():
	$SpawnCatapultIconButton.button_pressed = false
	$SpawnCatapultIconButton.release_focus()

func _on_message_timer_timeout():
	$Message.hide()

func _on_spawn_soldier_button_pressed() -> void:
	if not paused:
		spawn_soldier.emit()

func update_currency(amount):
	$CurrencyLabel.text = "Gold: " + str(amount)

func check_button_costs(current_currency):
	# --- Check Soldier Button ---
	if current_currency >= soldier_cost:
		$SpawnSoldierIconButton.disabled = false
	else:
		$SpawnSoldierIconButton.disabled = true
		
	# --- Check Tower Button ---
	if current_currency >= tower_cost:
		$SpawnArcherButton.disabled = false
	else:
		$SpawnArcherButton.disabled = true
		
	if current_currency >= base_upgrade_cost:
		$UpgradeBaseButton.disabled = false
	else:
		$UpgradeBaseButton.disabled = true
	
	$UpgradeCostLabel.text = "$" + str(base_upgrade_cost)

func start_wave_countdown(timer_node):
	countdown_timer = timer_node
	$WaveCountdownLabel.show()

func stop_wave_countdown():
	countdown_timer = null
	$WaveCountdownLabel.hide()

func update_upgrade_cost(new_cost):
	base_upgrade_cost = new_cost
	if new_cost >= 99999: # A high number to show it's maxed out
		$UpgradeCostLabel.text = "MAXED"
		$UpgradeBaseButton.disabled = true
	else:
		$UpgradeCostLabel.text = "Upgrade: $" + str(new_cost)

func _on_upgrade_base_button_pressed() -> void:
	if not paused:
		upgrade_base.emit()

func pause(state):
	paused = state
	if paused:
		$PauseMenu.show()
		paused = true
		$PauseButton.text = "Play"
		get_tree().call_group("enemies", "pause_me")
		get_tree().call_group("main", "pause_me")
		get_tree().call_group("soldiers", "pause_me")
	else:
		$PauseMenu.hide()
		paused = false
		$PauseButton.text = "Pause"
		$PauseMenu.unpause()
		get_tree().call_group("enemies", "unpause_me")
		get_tree().call_group("main", "unpause_me")
		get_tree().call_group("soldiers", "unpause_me")

func hide_buttons():
	$PauseButton.hide()
	
func show_buttons():
	$PauseButton.show()

func _on_pause_button_pressed():
	if paused:
		pause(false)
	else:
		pause(true)

func _on_free_gold_button_pressed() -> void:
	get_tree().call_group("main", "free_gold")


func _on_build_archer_button_pressed() -> void:
	pass # Replace with function body.

func _on_spawn_catapult_icon_button_pressed() -> void:
	if not paused:
		build_catapult.emit()
