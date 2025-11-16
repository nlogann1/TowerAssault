extends Node

@export var mob_scene: PackedScene
@export var tower_scene: PackedScene
@export var soldier_scene: PackedScene
@export var ghoul_mob_scene: PackedScene
@export var catapult_scene: PackedScene
@export var boss_scene: PackedScene
@export var toxic_hound_scene : PackedScene
@export var boss2_scene: PackedScene

# --- UNIT COSTS ---
@export var soldier_cost = 25
@export var tower_cost = 50 # This is the Archer
@export var catapult_cost = 250

@onready var map1 = preload("res://assets/maps/game_background_4.png")
@onready var map2 = preload("res://assets/maps/terrace.png")
@onready var map3 = preload("res://assets/maps/dead forest.png")
@onready var map4 = preload("res://assets/maps/game_background_1.png")
@onready var map5 = preload("res://assets/maps/castle.png")
@onready var map6 = preload("res://assets/maps/throne room.png")
@onready var maps = [map1, map2, map3, map4, map5, map6]

var score
var health
var max_health = 10
var paused = false
var first_game = true

var currency = 0
var soldier_spawn_offset = 0
var mouse_pos
var can_build = true
var unit_to_build_type = "" # <-- REPLACES build_tower_display

var current_wave = 0
var mobs_spawned_in_wave = 0
var mobs_remaining_in_wave = 0
var wave_clear_bonus = 50

var mob_attack_slot_radius = 150.0

var castle_level = 0
var current_cost = 150
var base_upgrade_costs = [150, 400, 99999]

var wave_data = [ 
	{ "mob_type": "boss2", "mob_count": 1, "mob_delay": 2.0 },
	{ "mob_type": "normal", "mob_count": 8, "mob_delay": 1.5 },
	{ "mob_type": "toxic_hound", "mob_count": 8, "mob_delay": 0.8 },
	{ "mob_type": "ghoul", "mob_count": 5, "mob_delay": 2.0 },
	{ "mob_type": "boss", "mob_count": 1, "mob_delay": 1.0 },
	{ "mob_type": "normal", "mob_count": 8, "mob_delay": 1.5 },
	{ "mob_type": "ghoul", "mob_count": 3, "mob_delay": 3.0 },
	{ "mob_type": "normal", "mob_count": 15, "mob_delay": 0.8 },
]

func _ready() -> void:
	$HUD.spawn_soldier.connect(_on_hud_spawn_soldier)
	$HUD.upgrade_base.connect(_on_hud_upgrade_base_pressed)
	# --- NEW CONNECTIONS ---
	$HUD.build_catapult.connect(_on_hud_build_catapult)
	$HUD.build_archer.connect(_on_hud_build_archer)


func _process(delta: float):
	# --- THIS IS THE NEW BUILD LOGIC ---
	if Input.is_action_just_pressed(&"left_click") and unit_to_build_type != "":
		mouse_pos = get_viewport().get_mouse_position()
		if can_build:
			build_unit(unit_to_build_type, mouse_pos) # Call the new master function
			unit_to_build_type = "" # Clear build mode
			can_build = false
	
	if Input.is_action_just_pressed(&"escape"):
		if unit_to_build_type != "":
			unit_to_build_type = ""
			$HUD.cancel_build_tower() # This function name is fine for now
		else:
			if paused:
				$HUD.pause(false)
			else:
				$HUD.pause(true)

func new_game():
	if not first_game:
		$ScoreTimer.stop()
		$MobTimer.stop()
		$NextWaveTimer.stop()
	score = 0
	max_health = 10
	health = max_health
	unit_to_build_type = "" # Reset build mode
	paused = false
	currency = 500
	
	current_wave = 0
	mobs_spawned_in_wave = 0
	current_cost = 150
	castle_level = 0
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_health(health, max_health)
	$HUD.update_currency(currency)
	$HUD.update_upgrade_cost(base_upgrade_costs[0])
	$HUD.check_button_costs(currency) # This will now check all 3 units
	$HUD.show_buttons()
	$HUD.show_message("Get Ready!")
	$Base.update_visuals(castle_level, health, max_health)
	$Base.reset()
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("soldiers", "queue_free")
	
	first_game = false

# --- THIS IS THE NEW MASTER BUILD FUNCTION ---
func build_unit(unit_type, position):
	var scene_to_spawn = null
	var cost = 0
	
	# 1. Figure out what we're building and what it costs
	if unit_type == "archer":
		scene_to_spawn = tower_scene
		cost = tower_cost
	elif unit_type == "soldier":
		scene_to_spawn = soldier_scene
		cost = soldier_cost
	elif unit_type == "catapult":
		scene_to_spawn = catapult_scene
		cost = catapult_cost
	
	# 2. Check if we can afford it
	if currency >= cost:
		# 3. Spend currency and update HUD
		currency -= cost
		$HUD.update_currency(currency)
		$HUD.check_button_costs(currency)
		
		# 4. Create the unit
		var unit = scene_to_spawn.instantiate()
		unit.global_position = position
		add_child(unit)
		
		# 5. (Optional) Special logic for each unit
		if unit_type == "archer" or unit_type == "catapult":
			unit.scale /= 2 # Your original scaling
			unit_to_build_type = "" # We've placed the unit
		
		if unit_type == "soldier":
			soldier_spawn_offset += 20
			if (soldier_spawn_offset >= 200):
				soldier_spawn_offset -= 300
	else:
		# Not enough money
		print("Not enough gold for " + unit_type)
		unit_to_build_type = "" # Cancel build mode
		$HUD.cancel_build_tower() # Deselect the button
		$HUD.cancel_build_catapult() # Deselect the button


# --- OLD FUNCTIONS ARE NOW SIMPLER ---

# This function is now just for soldiers
func _on_hud_spawn_soldier():
	var spawn_pos = $Base.global_position + Vector2(200, soldier_spawn_offset)
	build_unit("soldier", spawn_pos) # Call the master function

# These functions just set the "build mode"
func _on_hud_build_archer():
	unit_to_build_type = "archer"

func _on_hud_build_catapult():
	unit_to_build_type = "catapult"

# --- ALL OTHER FUNCTIONS BELOW ARE UNCHANGED ---
# (Your original code for game_over, _on_base_base_hit, _on_hud_upgrade_base_pressed, etc.)

func _on_hud_upgrade_base_pressed():
	current_cost = base_upgrade_costs[castle_level]
	
	if currency >= current_cost and castle_level < base_upgrade_costs.size() - 1:
		currency -= current_cost
		castle_level += 1
		health = max_health
		var next_cost = base_upgrade_costs[castle_level]
		
		$HUD.update_currency(currency)
		$HUD.update_health(health, max_health)
		$HUD.update_upgrade_cost(next_cost)
		$HUD.check_button_costs(currency)
		$Base.update_visuals(castle_level, health, max_health)

func _on_base_base_hit():
	if not paused:
		health -= 1
		$HUD.update_health(health, max_health)
		$Base.update_visuals(castle_level, health, max_health)
		if health <= 0:
			paused = true
			$HUD.pause(true)
			game_over()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$NextWaveTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_buttons()

func start_next_wave():
	if current_wave >= wave_data.size():
		print("YOU WIN!")
		$MobTimer.stop()
		game_over()
		return

	var wave = wave_data[current_wave]
	mobs_spawned_in_wave = 0
	mobs_remaining_in_wave = wave.mob_count
	
	$MobTimer.wait_time = wave.mob_delay
	$MobTimer.start()
	$HUD.show_message("Wave " + str(current_wave + 1))
	current_wave += 1

func _on_mob_timer_timeout():
	# 1. Get wave data and check if we're done
	var wave = wave_data[current_wave - 1]
	if mobs_spawned_in_wave >= wave.mob_count:
		$MobTimer.stop()
		return
	
	# 2. Increment counter
	mobs_spawned_in_wave += 1
	
	# 3. Figure out which scene to spawn
	var mob_to_spawn = mob_scene # Default
	if wave.mob_type == "ghoul":
		mob_to_spawn = ghoul_mob_scene
	elif wave.mob_type == "toxic_hound":
		mob_to_spawn = toxic_hound_scene
	elif wave.mob_type == "boss":
		mob_to_spawn = boss_scene
	elif wave.mob_type == "boss2":
		mob_to_spawn = boss2_scene
	
	# 4. NOW we create the mob
	var mob = mob_to_spawn.instantiate() 
	
	# 5. Figure out where to spawn it
	if wave.mob_type == "boss" or wave.mob_type == "boss2":
		# It's a boss, spawn it at the special point
		mob.global_position = $BossSpawnPoint.global_position
	else:
		# It's a regular mob, use the random spawner
		var spawn_points = $SpawnPoints.get_children()
		var random_spawn_point = spawn_points.pick_random()
		mob.global_position = random_spawn_point.global_position
	
	# 6. Set target positions
	mob.target_position = $Base.global_position
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, mob_attack_slot_radius)
	mob.target_attack_position = $Base.global_position + offset

	# 7. Add to scene and connect
	add_child(mob)
	mob.died.connect(_on_mob_died)

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	start_next_wave()

func _on_next_wave_timer_timeout():
	$HUD.stop_wave_countdown()
	start_next_wave()

func _on_build_zone_mouse_entered() -> void:
	can_build = true

func _on_build_zone_mouse_exited() -> void:
	can_build = false

func _on_mob_died():
	mobs_remaining_in_wave -= 1
	if mobs_remaining_in_wave <= 0:
		print("WAVE CLEARED!")
		
		currency += wave_clear_bonus
		$HUD.update_currency(currency)
		$HUD.check_button_costs(currency)
		$HUD.show_message("Wave Cleared! +$" + str(wave_clear_bonus))
		
		$HUD.start_wave_countdown($NextWaveTimer)
		$NextWaveTimer.start()

func add_currency(amount):
	currency += amount
	$HUD.update_currency(currency)
	$HUD.check_button_costs(currency)

func pause_me():
	paused = true
	$NextWaveTimer.paused = true
	$MobTimer.paused = true
	$ScoreTimer.paused = true
	$StartTimer.paused = true

func unpause_me():
	paused = false
	$NextWaveTimer.paused = false
	$MobTimer.paused = false
	$ScoreTimer.paused = false
	$StartTimer.paused = false
	
func free_gold():
	currency += 100
	$HUD.update_currency(currency)
	$HUD.check_button_costs(currency)

func change_map(choice):
	$Background.texture = maps[choice]
