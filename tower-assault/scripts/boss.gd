extends CharacterBody2D

signal died
@export var coin_scene: PackedScene
@export var speed = 50.0  # Boss speed
@export var health = 1000.0 # Boss health
@export var currency_reward = 250 # Boss reward
@export var attack_damage = 25.0 # Boss damage

var target_position = Vector2.ZERO
var target_attack_position = Vector2.ZERO

var is_in_combat = false
var attack_target = null
var paused = false

# --- Animation states ---
var is_appearing = true
var is_dying = false

# --- Corrected Node Paths ---
@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer
@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var collision_shape = $CollisionShape2D

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	
	# --- Appear Animation Logic ---
	is_appearing = true
	attack_timer.stop() # Don't attack yet
	
	var start_speed = speed
	speed = 0 
	
	anim_sprite.play("appear")
	await anim_sprite.animation_finished
	
	# Animation is done, start the game
	is_appearing = false
	speed = start_speed # Restore speed
	anim_sprite.play("walk") # Use your "walk" animation


func _physics_process(delta):
	# --- Don't do anything if appearing or dying ---
	if paused or is_appearing or is_dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_in_combat:
		# --- IN COMBAT: Stop moving. ---
		# The attack timer will handle all animations.
		velocity = Vector2.ZERO
	else:
		# --- NOT IN COMBAT: Move and play walk animation ---
		var direction = global_position.direction_to(target_attack_position)
		velocity = direction * speed
		
		# Only play "walk" if it's not already playing
		if anim_sprite.animation != "walk":
			anim_sprite.play("walk")
	
	# Check the direction of movement
	if velocity.x > 0:
		anim_sprite.flip_h = false
	elif velocity.x < 0:
		anim_sprite.flip_h = true
		
	move_and_slide()

# --- This is the function your SOLDIER calls on the boss ---
func damage_taken(amount):
	if is_dying: # Don't take damage while dying
		return
		
	health -= amount
	health_bar.value = health
	
	if health <= 0 and not is_dying: # Check not is_dying to prevent calling die() twice
		died.emit()
		spawn_coin()
		die() # Call our new death function

# --- Death Animation Function ---
func die():
	is_dying = true
	is_in_combat = false
	attack_target = null
	attack_timer.stop() # <-- Stop timer
	
	collision_shape.set_disabled(true) # <-- Use the setter function
	attack_range.monitoring = false
	health_bar.hide()
	
	anim_sprite.play("death")
	await anim_sprite.animation_finished
	
	queue_free() # Now we finally despawn

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func start_combat(target):
	if is_in_combat:
		return
	
	is_in_combat = true
	attack_target = target
	attack_timer.start()

func _on_attack_range_area_entered(area):
	if area.is_in_group("base"):
		start_combat(area)

func _on_attack_range_body_entered(body):
	if body.is_in_group("soldiers"):
		start_combat(body)

func _on_attack_timer_timeout():
	# --- Stop attack if dying ---
	if is_dying:
		return
		
	if is_instance_valid(attack_target):
		anim_sprite.play("attack") # <-- Plays attack animation
		# --- This is the function the BOSS calls on your UNITS ---
		attack_target.take_damage(attack_damage)
		attack_timer.start() # Attack again
	else:
		# --- Rescan for targets ---
		is_in_combat = false
		attack_target = null
		
		# First, check for soldiers
		for body in attack_range.get_overlapping_bodies():
			if body.is_in_group("soldiers"):
				start_combat(body) # Found one!
				return # Exit, we have a new target
				
		# If no soldiers, check for the base
		for area in attack_range.get_overlapping_areas():
			if area.is_in_group("base"):
				start_combat(area) # Found the base!
				return # Exit, we have a new target
		
		# If we found nothing, go back to walking
		anim_sprite.play("walk")
		
func spawn_coin():
	if coin_scene == null:
		print("ERROR: Boss is missing its coin_scene")
		return

	var coin = coin_scene.instantiate()
	coin.value = currency_reward
	get_parent().add_child(coin)
	coin.global_position = global_position

# --- Corrected Pause Functions ---
func pause_me():
	paused = true
	attack_timer.paused = true

func unpause_me():
	paused = false
	attack_timer.paused = false
