extends CanvasLayer

signal activate_telepoint(Vector3)

@onready var debug_tp_selector = %debug_tp_selector
var debug_tp_current_selection : Dictionary
var debug_telepoints = []
var debug_saved_index_selection : int = 0

func _ready() -> void:
	debug_tp_selector.clear()
	var j = 0
	for i in get_tree().get_nodes_in_group("telepoint"):
		var new_telepoint = {
			"node_name": i.name,
			"node_position": i.global_position,
		}
		debug_telepoints.append(new_telepoint)
		debug_tp_selector.add_item(i.name, j)
		j += 1
	if j != 0: 
		debug_tp_selector.select(0)
		debug_tp_current_selection = debug_telepoints[0]
	else: print("No telepoints :(")
	debug_tp_selector.set_process_unhandled_input(false)

func refresh_list() -> void:
	debug_tp_selector.clear()
	var j = 0
	for i in get_tree().get_nodes_in_group("telepoint"):
		var new_telepoint = {
			"node_name": i.name,
			"node_position": i.global_position,
		}
		debug_telepoints.append(new_telepoint)
		debug_tp_selector.add_item(i.name, j)
		j += 1
	if j != 0:
		debug_tp_selector.select(0)
		debug_tp_current_selection = debug_telepoints[0]
	else: print("No telepoints :(")
	debug_tp_selector.set_process_unhandled_input(false)

func _process(_delta: float) -> void:
	%debug_fps_display.text = "%s FPS VSync %s" % [Engine.get_frames_per_second(), "On" if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED else "Off"]

func _on_select_telepoint(telepoint_index) -> void:
	debug_tp_current_selection = debug_telepoints[telepoint_index]

func _on_telepoint_tp() -> void:
	emit_signal("activate_telepoint", debug_tp_current_selection["node_position"])
