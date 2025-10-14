extends Area2D

var inRange = []
var canAttack = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if canAttack and inRange.is_empty() == false:
		attack()
		canAttack = false
		$Sprite2D.hide()
		$AttackTimer.start()

func attack():
	var target = inRange[0]
	target.queue_free()
	inRange.remove_at(0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		inRange.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		inRange.erase(body)

func _on_attack_timer_timeout() -> void:
	canAttack = true
	$Sprite2D.show()
