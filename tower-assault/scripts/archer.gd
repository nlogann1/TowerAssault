extends StaticBody2D

@export var proj_scene: PackedScene

var parent_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	$AttackTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_attack_timer_timeout():
	# Create a new instance of the Projectile scene.
	var projectile = proj_scene.instantiate()
	
	# Set the projectile's position & rotation.
	projectile.position = Vector2(0,-50)
	
	# Spawn the projectile by adding it to the Main scene.
	add_child(projectile)

func _on_mouse_entered() -> void:
	parent_node.can_build = false

func _on_mouse_exited() -> void:
	parent_node.can_build = true
