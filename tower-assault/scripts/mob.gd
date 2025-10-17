extends RigidBody2D

@onready var path_follow : PathFollow2D = $EnemyPath/EnemyFollowPath
@export var speed = 100
@onready var health_bar: ProgressBar = $HealthBar

var type = "enemy"
var hp = 10
var parent_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	health_bar.value = hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func damage_taken(amount):
	hp -= amount
	health_bar.value = hp
	if hp <= 0:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	parent_node.lose_life(1)
	queue_free()
