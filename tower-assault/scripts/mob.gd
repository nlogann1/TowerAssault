extends RigidBody2D

@onready var path_follow : PathFollow2D = $EnemyPath/EnemyFollowPath
@export var speed = 100
@onready var health_bar: ProgressBar = $HealthBar

var type = "enemy"
var hp = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	var parent_node = get_parent()
	parent_node.lose_life(1)
	queue_free()
