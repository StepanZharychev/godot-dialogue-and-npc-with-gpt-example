extends Area2D
signal saw_player

@export var flip = false
const REACTION_VARIATION_COUNT = 5
const LOW_STATS_THRESHOLD = 10
const HIGH_STATS_THRESHOLD = 15

func _ready():
	$AnimatedSprite2D.flip_h = flip

func _process(_delta):
	pass

func _generate_stat_string(stats: Dictionary):
	var lowStats: Array = []
	var highStats: Array = []
	for stat in stats:
		if stats[stat] < LOW_STATS_THRESHOLD:
			lowStats.push_back(stat)
		elif stats[stat] > HIGH_STATS_THRESHOLD:
			highStats.push_back(stat)
	
	if (highStats.size() == 0 && lowStats.size() == 0):
		return ""
	
	var resultStrings: Array = []
	if (highStats.size() > 0):
		var stat = highStats[randi() % highStats.size()]
		if stat:
			resultStrings.push_back("%s_HIGH" % [stat.substr(0, 3).to_upper()])
	if (lowStats.size() > 0):
		var stat = lowStats[randi() % lowStats.size()]
		if stat:
			resultStrings.push_back("%s_LOW" % [stat.substr(0, 3).to_upper()])
	
	# Adds little bit of random selection only one stat or combination sometimes
	var randomSelector = randi() % 3
	return "%s_%s" % resultStrings if resultStrings.size() == 2 && randomSelector == 2 else resultStrings[randomSelector]

func _get_reaction_text(stats: Dictionary):
	var statString = _generate_stat_string(stats)
	var randomLineNumber = randi() % REACTION_VARIATION_COUNT + 1
	randomLineNumber = 1 if randomLineNumber < 1 else randomLineNumber
	
	var key = "REACTION_%s_%d" % [statString, randomLineNumber]
	var string = tr(key)
	
	if (string && string != key):
		return string
	
	return tr("STANDARD_REACTION")

func _on_area_entered(area: Area2D):
	if (area.name == 'Player'):
		if !$LabelDispose.is_stopped():
			return
		
		saw_player.emit()

func _on_label_dispose_timeout():
	$LabelDispose.stop()
	$AnimationPlayer.stop()

func react_on_player_stats(stats: Dictionary):
	$Label.text = _get_reaction_text(stats)
	$AnimationPlayer.queue("fade_in")
	$LabelDispose.start()
