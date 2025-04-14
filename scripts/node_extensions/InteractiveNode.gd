class_name InteractiveNode
extends Node

var players_hovering = {}

signal interacted()

func interact_with():
	interacted.emit()

func hover_cursor(character_body : CharacterBody3D):
	players_hovering[character_body] = Engine.get_process_frames()

func get_player_hovered_by_cur_cam() -> CharacterBody3D:
	for p in players_hovering.keys():
		var cur_cam = get_viewport().get_camera_3d() if get_viewport() else null
		if cur_cam in p.find_children("*", "Camera3D"):
			return p
	return null

func _process(_delta):
	for p in players_hovering.keys():
		if Engine.get_process_frames() - players_hovering[p] > 1:
			players_hovering.erase(p)
