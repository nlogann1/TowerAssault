extends Area2D

var speed = 400
var damage = 5
var passthrough = false
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not paused:
		position.x += speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.damage_taken(damage)
		if passthrough == false:
			queue_free()
		else:
			passthrough = false

func pause_me():
	paused = true

func unpause_me():
	paused = false
