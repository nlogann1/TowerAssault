extends CharacterBody2D

var speed = 100.0
var health = 10.0
var target_position = Vector2.ZERO # This is set by main.gd

# --- Attack Variables (from Step 5) ---
var attack_damage = 5.0
var is_attacking = false
var target_base = null
# -----------------------------------

@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer # Added in Step 5

func _ready():
	health_bar.max_value = health
	health_bar.value = health

# --- Modified _physics_process (from Step 5) ---
func _physics_process(delta):
	if is_attacking:
		velocity = Vector2.ZERO # Stop moving
	else:
		# Move towards the target
		var direction = global_position.direction_to(target_position)
		velocity = direction * speed
	
	move_and_slide()
# -------------------------------------------

func damage_taken(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_attack_range_area_entered(area):
	# Check if the area we entered is the Base
	if area.name == "Base":
		is_attacking = true
		target_base = area # Store the base
		attack_timer.start()


func _on_attack_timer_timeout():
	if is_instance_valid(target_base):
		# Call the take_damage function on the base's script
		target_base.take_damage(attack_damage)
		attack_timer.start() # Attack again
	else:
		# Base is destroyed, stop attacking
		is_attacking = false
