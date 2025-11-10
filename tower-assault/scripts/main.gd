extends Node

@export var mob_scene: PackedScene
@export var tower_scene: PackedScene
@export var soldier_scene: PackedScene
var score
var lives
var build_tower_display
var currency = 0
var soldier_cost = 25
var tower_cost = 50
var mouse_pos
var can_build = true

var current_wave = 0
var mobs_spawned_in_wave = 0
var mobs_remaining_in_wave = 0
var wave_clear_bonus = 50

var mob_attack_slot_radius = 150.0

# The "recipe book" for waves
var wave_data = [
	{ "mob_count": 5, "mob_delay": 2.0 },  # Wave 1
	{ "mob_count": 8, "mob_delay": 1.5 },  # Wave 2
	{ "mob_count": 12, "mob_delay": 1.0 }, # Wave 3
	{ "mob_count": 15, "mob_delay": 0.8 }  # Wave 4
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.spawn_soldier.connect(_on_hud_spawn_soldier)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if Input.is_action_just_pressed(&"left_click") and build_tower_display:
		mouse_pos = get_viewport().get_mouse_position()
		if can_build:
			build_tower(mouse_pos)
			can_build = false
	if Input.is_action_just_pressed(&"escape") and build_tower_display:
		build_tower_display = false
		$HUD.cancel_build_tower()

func new_game():
	score = 0
	lives = 10
	build_tower_display = false
	currency = 500
	
	current_wave = 0 # Reset wave count
	

	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_currency(currency)
	$HUD.check_button_costs(currency)
	$HUD.show_message("Get Ready!")
	get_tree().call_group("mobs", "queue_free")
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$NextWaveTimer.stop() # Stop the countdown timer
	$HUD.show_game_over()

# --- Wave Spawning Functions ---

func start_next_wave():
	# Stop if we've run out of waves
	if current_wave >= wave_data.size():
		print("YOU WIN!")
		$MobTimer.stop()
		game_over() # Or show a "You Win" screen
		return

	# Get the "recipe" for the current wave
	var wave = wave_data[current_wave]
	
	mobs_spawned_in_wave = 0
	mobs_remaining_in_wave = wave.mob_count
	
	# Configure the MobTimer based on the recipe
	$MobTimer.wait_time = wave.mob_delay
	$MobTimer.start()
	
	$HUD.show_message("Wave " + str(current_wave + 1))
	
	current_wave += 1


func _on_mob_timer_timeout():
	# Get the "recipe" for the *last* wave we started
	var wave = wave_data[current_wave - 1] 

	# Check if we're done spawning this wave
	if mobs_spawned_in_wave >= wave.mob_count:
		$MobTimer.stop() # Wave is fully spawned, stop this timer
		return
	
	# If not done, spawn a mob
	mobs_spawned_in_wave += 1
	
	var mob = mob_scene.instantiate()
	var spawn_points = $SpawnPoints.get_children()
	var random_spawn_point = spawn_points.pick_random()
	mob.global_position = random_spawn_point.global_position
	mob.target_position = $Base.global_position
	
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, mob_attack_slot_radius)
	mob.target_attack_position = $Base.global_position + offset
	
	

	add_child(mob)
	mob.died.connect(_on_mob_died)

func build_tower(position):
# Check if we have enough money
	if currency >= tower_cost:
		# If so, subtract the cost and update the HUD
		currency -= tower_cost
		$HUD.update_currency(currency)
		$HUD.check_button_costs(currency)

		# And build the tower
		var tower = tower_scene.instantiate()
		tower.position = position
		tower.scale /= 2
		add_child(tower)
	else:
		# Not enough money
		print("Not enough gold for a tower!")
	
func tower_button_pressed():
	build_tower_display = true
	# However we want the display to work


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	start_next_wave() # Start the first wave
	
# This runs after the 15-second build phase
func _on_next_wave_timer_timeout():
	$HUD.stop_wave_countdown()
	start_next_wave()

func _on_build_zone_mouse_entered() -> void:
	can_build = true

func _on_build_zone_mouse_exited() -> void:
	can_build = false

func _on_hud_spawn_soldier():
# Check if we have enough money
	if currency >= soldier_cost:
		# If so, subtract the cost and update the HUD
		currency -= soldier_cost
		$HUD.update_currency(currency)
		$HUD.check_button_costs(currency)

		# And spawn the soldier
		var soldier = soldier_scene.instantiate()
		soldier.global_position = $Base.global_position + Vector2(100, 0)
		add_child(soldier)
	else:
		# Not enough money (you can add a "buzz" sound here later)
		print("Not enough gold for a soldier!")
	
func _on_mob_died(reward):
	currency += reward
	$HUD.update_currency(currency)
	$HUD.check_button_costs(currency)
	
	mobs_remaining_in_wave -= 1
	
	# Check if all spawned mobs are dead
	if mobs_remaining_in_wave <= 0:
		print("WAVE CLEARED!")
		
		# Give bonus, update HUD, and start the countdown
		currency += wave_clear_bonus
		$HUD.update_currency(currency)
		$HUD.check_button_costs(currency)
		$HUD.show_message("Wave Cleared! +$" + str(wave_clear_bonus))
		
		$HUD.start_wave_countdown($NextWaveTimer)
		$NextWaveTimer.start()
		
		
