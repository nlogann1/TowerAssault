extends CharacterBody2D

var speed = 50.0
var health = 100.0
var attack_damage = 10.0

var target_monster = null

@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var health_bar = $HealthBar
@onready var detection_range = $DetectionRange

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta):
	# Only look for a new and closer target if our attack timer is stopped.
	# but locks it onto a target once it starts attacking.
	if attack_timer.is_stopped():
		find_nearest_target() # This function updates target_monster
	
	if is_instance_valid(target_monster):
		var distance = global_position.distance_to(target_monster.global_position)
		
		# Attack range is 30 pixels.
		if distance > 30:
			# Seek Behavior
			attack_timer.stop() 
			velocity = global_position.direction_to(target_monster.global_position) * speed
			anim_sprite.play("walk")
			anim_sprite.flip_h = (velocity.x < 0)
		else:
			# Attack Behavior 
			velocity = Vector2.ZERO # Stop moving
			
			# Start the attack timer if it's not already running
			if attack_timer.is_stopped():
				anim_sprite.play("idle")
				attack_timer.start()
	else:
		velocity = Vector2.ZERO
		anim_sprite.play("idle")
		
	move_and_slide()

func find_nearest_target():
	var nearest_mob = null
	var min_distance = INF 
	
	# Get all enemies in our detection range
	var nearby_bodies = detection_range.get_overlapping_bodies()
	
	for body in nearby_bodies:
		if body.is_in_group("enemies"):
			# Check its distance
			var distance = global_position.distance_to(body.global_position)
			
			# If this one is closer than the last one, it's our new target
			if distance < min_distance:
				min_distance = distance
				nearest_mob = body
	
	# This will either set the nearest mob, or set 'null' if none are in range
	target_monster = nearest_mob

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()

func _on_attack_timer_timeout():
	if is_instance_valid(target_monster):
		anim_sprite.play("attack")
		target_monster.damage_taken(attack_damage)
		attack_timer.start() # Restart timer for the next attack
	else:
		attack_timer.stop()

func _on_animated_sprite_2d_animation_finished():
	if anim_sprite.animation == "attack":
		anim_sprite.play("idle")
