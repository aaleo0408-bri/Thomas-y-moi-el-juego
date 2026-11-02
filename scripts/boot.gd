extends Node

func _ready() -> void:
	var session := Node.new()
	session.name = "GameSession"
	session.set_script(load("res://scripts/game_session.gd"))
	get_tree().root.add_child.call_deferred(session)
	var ui := CanvasLayer.new()
	ui.name = "GameUI"
	ui.set_script(load("res://scripts/ui.gd"))
	get_tree().root.add_child.call_deferred(ui)
