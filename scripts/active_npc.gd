extends Area2D

@export var flip = false
@export var dialogue_resource: DialogueResource
@export var dialogue_start = "start"

var is_actionable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.flip_h = flip

func _input(_event):
	if is_actionable && Input.is_action_pressed('use'):
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)

func _on_area_entered(area):
	if (area.name == 'Player'):
		is_actionable = true


func _on_area_exited(area):
	if (area.name == 'Player'):
		is_actionable = false
