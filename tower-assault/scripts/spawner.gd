extends CharacterBody2D

signal died
@export var coin_scene: PackedScene
@export var currency_reward = 250 # Reward for killing the spawner

@export var tentacle_scene: PackedScene # Slot for your tentacle.tscn
@export var num_tentacles_to_spawn = 5

var tentacles_alive = 0
var tentacles_spawned = 0
var paused = false
var is_dying = false

@onready var anim_sprite = $AnimatedSprite2D
@onready var spawn_timer = $SpawnTimer
@onready var attack_range = $AttackRange
@onready var collision_shape = $CollisionShape2D
@onready var health_bar = $HealthBar

# These are set by main.gd
var target_position = Vector2.ZERO
var target_attack_position = Vector2.ZERO

func _ready():
	health_bar.max_value = 1 # We don't use health
	health_bar.value = 1
	health_bar.hide()
	
	is_dying = false
	tentacles_alive = 0
	tentacles_spawned = 0
	
	anim_sprite.play("appear")
	await anim_sprite.animation_finished
	anim_sprite.play("idle")
	
	spawn_timer.start() # Start spawning

func _physics_process(delta):
	# This mob does not move
	velocity = Vector2.ZERO
	move_and_slide()

# --- This mob is INVULNERABLE ---
func damage_taken(_amount):
	pass # It can't be hurt

func _on_spawn_timer_timeout():
	if tentacles_spawned >= num_tentacles_to_spawn:
		spawn_timer.stop() # We've spawned all our tentacles
		return
	
	# Spawn a tentacle
	tentacles_spawned += 1
	tentacles_alive += 1
	
	var tentacle = tentacle_scene.instantiate()
	
	# Add it to the main scene
	get_parent().add_child(tentacle)
	
	# Spawn it at our location and set its targets
	tentacle.global_position = global_position
	tentacle.target_position = target_position
	tentacle.target_attack_position = target_attack_position
	
	# --- MOST IMPORTANT STEP ---
	# Connect to the tentacle's "died" signal
	tentacle.died.connect(_on_tentacle_died)
	
	spawn_timer.start() # Wait for the next spawn

# This is called by the tentacle's "died" signal
func _on_tentacle_died():
	tentacles_alive -= 1
	
	# If we've spawned all tentacles AND they are all dead, we die
	if tentacles_spawned >= num_tentacles_to_spawn and tentacles_alive == 0:
		die()

func die():
	is_dying = true
	spawn_timer.stop()
	collision_shape.set_disabled(true)
	attack_range.monitoring = false
	
	anim_sprite.play("death")
	await anim_sprite.animation_finished
	
	spawn_coin() # Drop the loot
	died.emit()   # Tell main.gd the wave is clear
	queue_free()

func spawn_coin():
	if coin_scene == null: return
	var coin = coin_scene.instantiate()
	coin.value = currency_reward
	get_parent().add_child(coin)
	coin.global_position = global_position

# --- (Other functions from boss.gd, no changes needed) ---
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func start_combat(_target):
	pass # This mob doesn't fight

func _on_attack_range_area_entered(_area):
	pass # This mob doesn't fight

func _on_attack_range_body_entered(_body):
	pass # This mob doesn't fight

func pause_me():
	paused = true
	spawn_timer.paused = true

func unpause_me():
	paused = false
	spawn_timer.paused = false
