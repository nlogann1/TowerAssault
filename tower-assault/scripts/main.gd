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
	currency = 100
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_currency(currency)
	$HUD.show_message("Get Ready!")
	get_tree().call_group("mobs", "queue_free")
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()

	var spawn_points = $SpawnPoints.get_children()
	var random_spawn_point = spawn_points.pick_random()
	# Set the mob's starting position
	mob.global_position = random_spawn_point.global_position
	# We tell the mob where to go.
	mob.target_position = $Base.global_position

	add_child(mob)

func build_tower(position):
	var tower = tower_scene.instantiate()
	tower.position = position
	tower.scale /= 2
	add_child(tower)
	
func tower_button_pressed():
	build_tower_display = true
	# However we want the display to work


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_build_zone_mouse_entered() -> void:
	can_build = true

func _on_build_zone_mouse_exited() -> void:
	can_build = false

func _on_hud_spawn_soldier():
	var soldier = soldier_scene.instantiate()
	soldier.global_position = $Base.global_position + Vector2(100, 0)
	add_child(soldier)
