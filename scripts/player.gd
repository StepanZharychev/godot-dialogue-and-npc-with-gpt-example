extends Area2D

@export var speed = 400
const STATS: Dictionary = {
	Strength = 9,
	Dexterity = 16,
	Constitution = 10,
	Intelligence = 10,
	Wisdom = 10,
	Charisma = 10
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_startIdle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement = Vector2.ZERO
	if Input.is_action_pressed('move-right'):
		movement.x += 1
	if Input.is_action_pressed('move-left'):
		movement.x -= 1
	if Input.is_action_pressed('move-up'):
		movement.y -= 1
	if Input.is_action_pressed('move-down'):
		movement.y += 1
	
	if movement.length() > 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = movement.x < 0
		movement = movement.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		_startIdle()
		
	position += movement * delta

func _startIdle():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	
func get_stats():
	return STATS
