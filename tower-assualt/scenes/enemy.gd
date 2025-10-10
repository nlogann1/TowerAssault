#scripts/enemy.gd
extends CharacterBody2D

var health = 100
var speed = 100.0

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free() #Enemy is destroyed
