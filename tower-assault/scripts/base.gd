extends Area2D

signal base_hit

var health = 10 # Let's assume this is the starting health for level 1
var bumped = false

# --- PRELOAD ALL 9 CASTLE IMAGES ---
# (Make sure to drag your images from the FileSystem into these slots)

# Castle 1 (Level 0)
@export var castle_1_full: Texture2D
@export var castle_1_damaged: Texture2D
@export var castle_1_broken: Texture2D

# Castle 2 (Level 1)
@export var castle_2_full: Texture2D
@export var castle_2_damaged: Texture2D
@export var castle_2_broken: Texture2D

# Castle 3 (Level 2)
@export var castle_3_full: Texture2D
@export var castle_3_damaged: Texture2D
@export var castle_3_broken: Texture2D
# ------------------------------------

# We'll store them in a 2D array for easy access
var castle_textures = []
var bump_amount = [40, 30, 30]

@onready var sprite = $CastleSprite

func _ready():
	add_to_group("base")
	
	# Build our 2D array
	castle_textures = [
		[castle_1_full, castle_1_damaged, castle_1_broken], # Level 0
		[castle_2_full, castle_2_damaged, castle_2_broken], # Level 1
		[castle_3_full, castle_3_damaged, castle_3_broken]  # Level 2
	]
	
	# Initial sprite
	sprite.texture = castle_textures[0][0]

func take_damage(amount):
	# Don't track health here. main.gd will do it.
	print("Base took damage!")
	base_hit.emit()
	
	# We don't check for <= 0 here. main.gd will handle it.

# This is the new function main.gd will call
func update_visuals(level, current_health, max_health):
	# 1. Determine which damage state to show
	var health_percent = float(current_health) / float(max_health)
	var damage_index = 0 # Default to full health
	
	if health_percent < 0.66 and health_percent > 0.33:
		damage_index = 1 # Damaged
	elif health_percent <= 0.33:
		damage_index = 2 # Broken
	
	# 2. Set the sprite
	# level = 0, 1, or 2
	# damage_index = 0, 1, or 2
	sprite.texture = castle_textures[level][damage_index]
	if bumped and (damage_index != 2):
		sprite.position = Vector2(0, 0)
		bumped = false
	if not bumped and (damage_index == 2):
		sprite.position += Vector2(0, bump_amount[level])
		bumped = true

func reset():
	health = 10
	sprite.texture = castle_textures[0][0]
