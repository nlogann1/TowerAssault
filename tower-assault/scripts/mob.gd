# In mob.gd
extends CharacterBody2D

var speed = 100.0
var health = 10.0
var target_position = Vector2.ZERO # This is set by main.gd

@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta):
	# Move towards the target
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	move_and_slide()

func damage_taken(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()

# This is the old "lose life" function.
# We change it to just clean up the mob.
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
