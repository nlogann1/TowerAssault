# In base.gd
extends Area2D

var health = 100.0

@onready var health_bar = $HealthBar

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func take_damage(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		# Tell the main scene the game is over
		get_parent().game_over()
		queue_free() # The base is destroyed
