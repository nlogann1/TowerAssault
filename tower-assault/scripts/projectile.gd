extends Area2D

var speed = 400
var damage = 25
var direction = Vector2.RIGHT # This will be set by the archer

func _process(delta: float):
	# Move in the set direction
	global_position += direction * speed * delta

# This is the function your tower_range script is looking for
func aim_at(target_pos):
	direction = (global_position.direction_to(target_pos))
	rotation = direction.angle() # This makes the sprite face the target

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies"):
		body.damage_taken(damage)
		queue_free() # Destroy the projectile on hit
