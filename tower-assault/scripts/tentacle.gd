extends CharacterBody2D

signal died
# No coin scene or currency reward for tentacles

@export var speed = 175.0
@export var health = 200.0
@export var attack_damage = 15.0

var target_position = Vector2.ZERO
var target_attack_position = Vector2.ZERO

var is_in_combat = false
var attack_target = null
var paused = false

# --- NEW: Animation states ---
var is_appearing = true
var is_dying = false

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
	attack_timer.stop()
	var start_speed = speed
	speed = 0
	
	anim_sprite.play("appear")
	await anim_sprite.animation_finished
	
	# Animation is done, start the game
	is_appearing = false
	speed = start_speed
	anim_sprite.play("walk")


func _physics_process(delta):
	# Don't do anything if appearing or dying
	if paused or is_appearing or is_dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_in_combat:
		velocity = Vector2.ZERO # Stop moving
	else:
		# Move towards our unique attack slot
		var direction = global_position.direction_to(target_attack_position)
		velocity = direction * speed
		
		if anim_sprite.animation != "walk":
			anim_sprite.play("walk")
	
	if velocity.x > 0:
		anim_sprite.flip_h = false
	elif velocity.x < 0:
		anim_sprite.flip_h = true
		
	move_and_slide()

func damage_taken(amount):
	if is_dying:
		return
		
	health -= amount
	health_bar.value = health
	
	if health <= 0 and not is_dying:
		die() # Call our new death function

# --- NEW: Death Animation Function ---
func die():
	is_dying = true
	is_in_combat = false
	attack_target = null
	attack_timer.stop()
	
	collision_shape.set_disabled(true)
	attack_range.monitoring = false
	health_bar.hide()
	
	died.emit() # Tell the Spawner we died
	
	anim_sprite.play("death")
	await anim_sprite.animation_finished
	
	queue_free()

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
	if is_dying: # Don't attack if dying
		return
		
	if is_instance_valid(attack_target):
		# We don't have an "attack" animation, so just deal damage
		attack_target.take_damage(attack_damage)
		attack_timer.start() # Attack again
	else:
		is_in_combat = false
		attack_target = null
		
		# Rescan for new targets
		for body in attack_range.get_overlapping_bodies():
			if body.is_in_group("soldiers"):
				start_combat(body)
				return
		for area in attack_range.get_overlapping_areas():
			if area.is_in_group("base"):
				start_combat(area)
				return
		
		anim_sprite.play("walk")

func pause_me():
	paused = true
	attack_timer.paused = true

func unpause_me():
	paused = false
	attack_timer.paused = false
