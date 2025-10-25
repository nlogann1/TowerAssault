extends CharacterBody2D

var speed = 50.0
var health = 100.0
var attack_damage = 10.0

var target_monster = null

enum {IDLE, WALK, ATTACK}
var state = IDLE

@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var health_bar = $HealthBar
@onready var detection_range = $DetectionRange

func _ready():
	health_bar.max_value = health
	health_bar.value = health


func _physics_process(_delta):
	
	if not is_instance_valid(target_monster):
		find_nearest_target()
		state = IDLE
	else:
		var distance = global_position.distance_to(target_monster.global_position)
		if distance > 65:
			state = WALK
		else:
			# Target is in range.
			if state != ATTACK:
				# If we aren't already attacking, start our first attack NOW.
				state = ATTACK
				do_attack()
	
	match state:
		IDLE:
			velocity = Vector2.ZERO
			anim_sprite.play("idle")
			
		WALK:
			velocity = global_position.direction_to(target_monster.global_position) * speed
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
	
	target_monster = nearest_mob


func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()

func do_attack():
	if is_instance_valid(target_monster):
		state = ATTACK 
		anim_sprite.play("attack")
		target_monster.damage_taken(attack_damage)
		attack_timer.start() # Start the timer after attacking
	else:
		# Target died before we could attack
		state = IDLE


func _on_attack_timer_timeout():
	# Timer is done, so we attack again.
	do_attack()

func _on_animated_sprite_2d_animation_finished():
	if anim_sprite.animation == "attack":
		# Attack animation is done, just go to idle.
		anim_sprite.play("idle")
