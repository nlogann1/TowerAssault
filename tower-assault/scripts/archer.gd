extends StaticBody2D

@export var health = 100.0

func _ready():
	# Add archer to the "soldiers" group so mobs can attack it
	add_to_group("soldiers")

# This function is called by the mob's attack
func take_damage(amount):
	health -= amount
	print("Archer took damage! Health: ", health)
	
	# Check if the archer is destroyed
	if health <= 0:
		queue_free() # Destroy the archer
