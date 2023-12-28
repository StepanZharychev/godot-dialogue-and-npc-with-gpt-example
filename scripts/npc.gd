extends Area2D

@export var flip = false
const REACTION_VARIATION_COUNT = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.flip_h = flip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_reaction_text():
	var randomLineNumber = randi() % REACTION_VARIATION_COUNT
	randomLineNumber = 1 if randomLineNumber < 1 else randomLineNumber
	var string = tr("REACTION_S_HIGH_I_LOW_%d" % randomLineNumber)
	
	if (string):
		return string
	
	return tr("STANDARD_REACTION")

func _on_area_entered(area: Area2D):
	if (area.name == 'Player'):
		if !$LabelDispose.is_stopped():
			return
		
		$Label.text = get_reaction_text()
		$AnimationPlayer.queue("fade_in")
		$LabelDispose.start()
		

func _on_label_dispose_timeout():
	$LabelDispose.stop()
	$AnimationPlayer.stop()
