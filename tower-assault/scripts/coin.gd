extends Area2D

@onready var anim_sprite = $CoinSprite

var value = 50 
var is_collected = false

func _ready():
	anim_sprite.play("spin") 

# This is the function for mouse collection
func _on_mouse_entered():
	if is_collected:
		return
	
	is_collected = true 
	
	get_tree().get_root().get_node("Main").add_currency(value)
	
	queue_free()

# This is for the DespawnTimer
func _on_despawn_timer_timeout():
	queue_free()
