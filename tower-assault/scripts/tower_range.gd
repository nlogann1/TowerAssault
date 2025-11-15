extends Area2D

@export var projectile_scene: PackedScene

var inRange = []
var canAttack = true
var paused = false

# This line finds the 'ArcherSprite' node, which is a sibling
@onready var anim_sprite = get_parent().get_node("ArcherSprite")

# This function is the "hard-coded" fix.
# It runs once when the archer is created.
func _ready() -> void:
	anim_sprite.play("idle")

func _process(_delta: float):
	inRange = inRange.filter(func(mob): return is_instance_valid(mob))
	
	if canAttack and not inRange.is_empty():
		attack()
		canAttack = false
		$AttackTimer.start()

func attack():
	if inRange.is_empty():
		return 

	var target = inRange[0]
	
	# Play the attack animation
	anim_sprite.play("attack")

	# Spawn the projectile
	var proj = projectile_scene.instantiate()
	get_parent().get_parent().add_child(proj) # Add proj to the Main scene
	
	# Start it at the archer's position
	proj.global_position = anim_sprite.global_position
	
	# Aim it
	proj.aim_at(target.global_position)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		inRange.append(body)

func _on_body_exited(body:Node2D) -> void:
	if body.is_in_group("enemies"):
		inRange.erase(body)

func _on_attack_timer_timeout() -> void:
	canAttack = true
	anim_sprite.play("idle")

func pause_me():
	paused = true
	$AttackTimer.paused = true

func unpause_me():
	paused = false
	$AttackTimer.paused = false
