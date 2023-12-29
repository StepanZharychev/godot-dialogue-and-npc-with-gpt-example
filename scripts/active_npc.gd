extends Area2D

@export var flip = false
@export var generateWithGpt = false
@export var dialogue_resource: DialogueResource
@export var dialogue_start = "start"

var is_actionable = false
var dialogueResult = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.flip_h = flip

func _request_dialogue_data():
	var file = FileAccess.open("res://tokens/openai", FileAccess.READ)
	var token = file.get_as_text()
	
	var data = {
		"model": "gpt-3.5-turbo",
		"messages": [
	  		{
				"role": "system",
				"content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
	  		},
	  		{
				"role": "user",
				"content": "Compose a poem that explains the concept of recursion in programming."
	  		}
		]
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json", "Authorization: Bearer %s" % token]
	$GPTRequest.request("https://api.openai.com/v1/chat/completions", headers, HTTPClient.METHOD_POST, json)

func _on_gpt_request_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json.has('choices'):
		dialogueResult = ""
	elif json.has('error'):
		dialogueResult = "
~ start

System: Something went wrong with your GPT generation
System: %s
=> END
" % str(json.error)

func _init_dialogue():
	if !generateWithGpt:
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	else:
		_request_dialogue_data()
		await $GPTRequest.request_completed
		print(dialogueResult)
		var resource = DialogueManager.create_resource_from_text(dialogueResult)
		DialogueManager.show_example_dialogue_balloon(resource, dialogue_start)

func _input(_event):
	if is_actionable && Input.is_action_pressed('use'):
		_init_dialogue()

func _on_area_entered(area):
	if (area.name == 'Player'):
		is_actionable = true


func _on_area_exited(area):
	if (area.name == 'Player'):
		is_actionable = false
