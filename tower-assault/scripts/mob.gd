extends RigidBody2D

@onready var path_follow : PathFollow2D = $EnemyPath/EnemyFollowPath
@export var speed = 100

var type = "enemy"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	var parent_node = get_parent()
	parent_node.lose_life(1)
	queue_free()
