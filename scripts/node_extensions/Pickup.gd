extends Node
class_name Pickup

@export var type_name = "coin"
@export var amount = 1

func _on_body_entered(body: Node3D) -> void:
	if !body.get_parent().has_signal("collect_pickup"): print("collecting body needs collect_pickup signal!")
	else: body.get_parent().emit_signal("collect_pickup", type_name, amount)
	get_parent().queue_free()

func on_pickup_input_event(camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		var clicking_player = get_cached_character_body(camera)
#		var cur_cam = get_viewport().get_camera_3d() if get_viewport() else null
		if clicking_player != null:
			clicking_player.emit_signal("collect_pickup", type_name, amount)
			get_parent().queue_free()
		else:
			print("Click owner not found")

func get_cached_character_body(node: Node) -> CharacterBody3D:
	if node.has_meta("cached_character_body"):
		return node.get_meta("cached_character_body") as CharacterBody3D
	var current = node
	while current:
		if current is CharacterBody3D:
			node.set_meta("cached_character_body", current)
			return current
		current = current.get_parent()
	return null
