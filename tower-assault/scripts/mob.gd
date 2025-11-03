extends CharacterBody2D

signal died(reward)
var speed = 100.0
var health = 200.0
var currency_reward = 10
var target_position = Vector2.ZERO # This is the main Base

var attack_damage = 5.0
var is_in_combat = false
var attack_target = null

@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta):

	if is_in_combat:
		velocity = Vector2.ZERO # Stop moving
	else:
		# Move towards the base
		var direction = global_position.direction_to(target_position)
		velocity = direction * speed
	
	move_and_slide()

func damage_taken(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		died.emit(currency_reward)
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
