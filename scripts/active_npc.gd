extends Area2D

@export var flip = false
@export var generateWithGpt = false
@export var dialogue_resource: DialogueResource
@export var dialogue_start = "start"
@export var npc_name = ""

var is_actionable = false
var dialogueResult = ""

const current_dialogue = "
~ start

Tav

=> END
"
const system_prompt = "
You're an NPC in a fantasy game. Specifically you're a %s.
You meet a hero named Tav.

Using information above generate a dialogue between you and a hero using their name. Have branching in dialogue and dramatic turns. Baseline of dialogue is: \"Hero entered your castle and wants to stop grim ritual\"
%s.

You have the following representation of dialogue line:
enum DialogueLineType {
	text = 'text',
	choice = 'choice'
}
interface DialogueLine {
	character: string; // Name of character who says given text
	type: DialogueLineType; // Represents type of line, enum
	text?: string; // Text of dialogue line in the case of text or choice type
	action?: string; // Applicable only to \"choice\" type, short description of choice being made to be saved, e.g. \"Used force to stop vampire\"
	childLines?: DialogueLine[]; // Set of nested lines, related to new section of dialogue, not applicable to \"text\" type
}

Example structure with explanation of choices, don't use it for generation directly, it's just an example:
[{type: \"text\"}, {type: \"choice\", text: \"Choice A\", childLines: [/* All lines related to Choice A go here */]}, {type: \"choice\", text: \"Choice B\", childLines: [/* All lines related to Choice B go here */]}]

Generate JSON array with lines to represent dialogue. You must follow rules:
1. \"text\" type can't have any \"childLines\"
2. JSON must be in a correct format with no commas missing
3. \"choice\" can have only hero as a \"character\"

Dialogue must have at least 15 lines.

Dialogue text should be in Russian.
"
const error_dialogue = "
~ start

System: Something went wrong with your GPT generation
System: %s

=> END
"

func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.flip_h = flip

func _generate_tabs(count):
	var tab = "	"
	var res = ""
	for n in count:
		res += tab
	
	return res

func _process_lines(lines, level = 0, defaultRes = null):
	var res = defaultRes if defaultRes != null else "~ %s\n" % dialogue_start
	for line in lines:
		if line.type == "text":
			res += "%s%s: %s\n" % [_generate_tabs(level), line.character, line.text]
		elif line.type == "choice":
			res += "%s- %s\n" % [_generate_tabs(level), line.text]
			if line.has("action"):
				res += "%sdo State._set_decision(\"%s\", \"%s\")\n" % [_generate_tabs(level + 1), npc_name, line.action]
			if line.has("childLines") && line.childLines.size() > 0:
				res += _process_lines(line.childLines, level + 1, "")

	return res

func _request_dialogue_data():
	var file = FileAccess.open("res://tokens/openai", FileAccess.READ)
	var token = file.get_as_text()
	
	var choices = State._get_decisions(npc_name);
	var data = {
		"model": "gpt-3.5-turbo",
		"messages": [
	  		{
				"role": "user",
				"content": system_prompt % [npc_name, "Notice that you've met the hero before. And they did the following in a dialogue: %s" % str(choices) if choices.size() > 0 else ""]
	  		}
		]
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json", "Authorization: Bearer %s" % token]
	print("request sent")
	$GPTRequest.request("https://api.openai.com/v1/chat/completions", headers, HTTPClient.METHOD_POST, json)

func _on_gpt_request_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(response_code, body.get_string_from_utf8(), json)
	if json.has('choices'):
		var text = _process_lines(JSON.parse_string(json.choices[0].message.content))
		text += "=> END\n"
		dialogueResult = text
	elif json.has('error'):
		dialogueResult = error_dialogue % str(json.error)

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
		$DialogueBubble.visible = true


func _on_area_exited(area):
	if (area.name == 'Player'):
		is_actionable = false
		$DialogueBubble.visible = false
