extends CharacterBody2D

signal died
@export var coin_scene: PackedScene
@export var speed = 135.0
@export var health = 200.0
@export var currency_reward = 50
@export var attack_damage = 15.0

var target_position = Vector2.ZERO # This is the main Base
var target_attack_position = Vector2.ZERO # This is our unique "slot"

var is_in_combat = false
var attack_target = null

var paused = false

@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer
@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	anim_sprite.play("walk")

func _physics_process(delta):
	if not paused:
		if is_in_combat:
			velocity = Vector2.ZERO # Stop moving
		else:
			# Move towards our unique attack slot
			var direction = global_position.direction_to(target_attack_position)
			velocity = direction * speed
		
		# Check the direction of movement
			if velocity.x > 0:
				# Moving right, so face right (don't flip)
				anim_sprite.flip_h = false
			elif velocity.x < 0:
				# Moving left, so face left (flip)
				anim_sprite.flip_h = true
		
		move_and_slide()

func damage_taken(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		died.emit()
		spawn_coin() # Call our new function
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# This is a new, central function for starting a fight.
func start_combat(target):
	# If we are already fighting, don't switch targets
	if is_in_combat:
		return
	
	is_in_combat = true
	attack_target = target # Store what we are attacking
	attack_timer.start()

# attack on the base
func _on_attack_range_area_entered(area):
	if area.is_in_group("base"):
		start_combat(area)

# This is the function for detecting Soldiers (which are CharacterBody2D)
func _on_attack_range_body_entered(body):
	if body.is_in_group("soldiers"):
		start_combat(body)

# Mobs attack timer
func _on_attack_timer_timeout():
	if is_instance_valid(attack_target):
		attack_target.take_damage(attack_damage)
		attack_timer.start() # Attack again
	else:
		# Our target is dead, stop fighting and start moving again
		is_in_combat = false
		attack_target = null
		
func spawn_coin():
	if coin_scene == null:
		print("ERROR: Mob is missing its coin_scene")
		return

	var coin = coin_scene.instantiate()
	coin.value = currency_reward # Set the coin's value
	get_parent().add_child(coin) # Add it to the main scene
	coin.global_position = global_position

func pause_me():
	paused = true
	$AttackTimer.paused = true

func unpause_me():
	paused = false
	$AttackTimer.paused = false
