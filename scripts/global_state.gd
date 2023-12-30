extends Node

var vampire_status = "threatening"
var decisions = {}

func _set_decision(dialogue_name, decision):
	if !decisions.has(dialogue_name):
		decisions[dialogue_name] = []
		
	decisions[dialogue_name].push_back(decision)

func _get_decisions(dialogue_name):
	if decisions.has(dialogue_name):
		return decisions[dialogue_name]
	
	return []

func _has_decision(dialogue_name, decision):
	return decisions.has(dialogue_name) && decisions[dialogue_name].has(decision)
