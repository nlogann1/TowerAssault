extends Node2D

@onready var path_follow : PathFollow2D = $EnemyPath/EnemyFollowPath
@export var speed = 100

var type = "enemy"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path_follow.progress += speed * delta
