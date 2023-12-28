extends Node

func _ready():
	_set_signals()

func _process(delta):
	pass

func _set_signals():
	var passiveNpcs = get_tree().get_nodes_in_group("passive_npc")
	for passiveNpc in passiveNpcs:
		passiveNpc.connect("saw_player", _on_saw_player.bind(passiveNpc))

func _on_saw_player(npc):
	npc.react_on_player_stats($Player.get_stats())
