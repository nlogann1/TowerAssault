extends StaticBody2D

@export var health = 200.0

func _ready():
	# Add catapult to the "soldiers" group so mobs can attack it
	add_to_group("soldiers")

# This function is called by the mob's attack
func take_damage(amount):
	health -= amount
	print("Catapult took damage! Health: ", health)
	
	# Check if the catapult is destroyed
	if health <= 0:
		queue_free() 
