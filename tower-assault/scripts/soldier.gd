extends CharacterBody2D

var speed = 50.0
var health = 100.0
var attack_damage = 10.0

var target_monster = null
# This stores the unique "slot" this soldier will run to
var target_attack_position = Vector2.ZERO

enum {IDLE, WALK, ATTACK}
var state = IDLE
var paused = false

# Attack range here
@export var attack_range: float = 60.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var health_bar = $HealthBar
@onready var detection_range = $DetectionRange

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(_delta):
	if not paused:
		if not is_instance_valid(target_monster):
			find_nearest_target()
			state = IDLE
		else:
			# We check the distance to the mob
			var distance_to_mob = global_position.distance_to(target_monster.global_position)
			
			if distance_to_mob > attack_range:
				# We are not in attack range, so we walk to our slot
				state = WALK
			else:
				# We are in attack range
				if state != ATTACK:
					state = ATTACK
					do_attack()
		
		match state:
			IDLE:
				velocity = Vector2.ZERO
				anim_sprite.play("idle")
				
			WALK:
				# We walk towards our unique slot, not the mob's center
				velocity = global_position.direction_to(target_attack_position) * speed
				anim_sprite.play("walk")
				anim_sprite.flip_h = (velocity.x < 0)
				
			ATTACK:
				velocity = Vector2.ZERO
				
		move_and_slide()

func find_nearest_target():
	var nearest_mob = null
	var min_distance = INF 
	var nearby_bodies = detection_range.get_overlapping_bodies()
	
	for body in nearby_bodies:
		if body.is_in_group("enemies"):
			var distance = global_position.distance_to(body.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_mob = body
	
	# When we find a new target, pick a random attack slot around it
	if nearest_mob != target_monster:
		target_monster = nearest_mob
		
		if is_instance_valid(target_monster):
			# Pick a random spot in a circle *within* our attack range
			var offset_distance = randf_range(attack_range * 0.5, attack_range * 0.8)
			var offset = Vector2.RIGHT.rotated(randf() * TAU) * offset_distance
			target_attack_position = target_monster.global_position + offset
		else:
			target_attack_position = Vector2.ZERO # No target, no position
			
	elif not is_instance_valid(target_monster):
		# Our old target is dead, clear it
		target_monster = null
		target_attack_position = Vector2.ZERO

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()

func do_attack():
	if is_instance_valid(target_monster):
		var mob_distance = global_position.distance_to(target_monster.global_position)
		
		if mob_distance > attack_range + 10:
			# The mob moved out of range, go back to walking
			state = WALK
			target_monster = null # Retarget
			return

		state = ATTACK
		anim_sprite.play("attack")
		target_monster.damage_taken(attack_damage)
		attack_timer.start()
	else:
		state = IDLE

func _on_attack_timer_timeout():
	do_attack()

func _on_animated_sprite_2d_animation_finished():
	if anim_sprite.animation == "attack":
		# Go to idle while waiting for the timer
		anim_sprite.play("idle")

func pause_me():
	paused = true
	$AttackTimer.paused = true

func unpause_me():
	paused = false
	$AttackTimer.paused = false
