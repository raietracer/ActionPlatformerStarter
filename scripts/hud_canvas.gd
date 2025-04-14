extends CanvasLayer

signal activate_telepoint(Vector3)

var pickup_trackers = {
	"dust": {
		"count": 0
	},
	"coin": {
		"count": 0#: set on_coin_pickup()
	}
}

@onready var debug_tp_selector : OptionButton = %debug_tp_selector
var debug_tp_current_selection : Dictionary
var debug_telepoints = []
var debug_saved_index_selection : int = 0

@onready var music_player_selector : OptionButton = %music_list
var music_player_current_selection : String
var detected_songs = []
var saved_song_selection : int = 0

func _ready() -> void:
	# Populates the teleport selection pool
	refresh_teleporter_list()
	# Populates the music player selection pool
	refresh_music_player_list()
	# Ensures no children can take focus
	force_remove_focus()

func _process(_delta: float) -> void:
	%debug_fps_display.text = "%s FPS VSync %s" % [Engine.get_frames_per_second(), "On" if DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED else "Off"]

func _on_select_telepoint(telepoint_index) -> void:
	debug_tp_current_selection = debug_telepoints[telepoint_index]

func _on_telepoint_tp() -> void:
	emit_signal("activate_telepoint", debug_tp_current_selection["node_position"])

func refresh_teleporter_list() -> void:
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

func _on_select_song(song_index) -> void:
	music_player_current_selection = detected_songs[song_index]

func _on_music_player_play_button_pressed() -> void:
	AudioManager.play(music_player_current_selection, "Music", 0.6)

func refresh_music_player_list() -> void:
	music_player_selector.clear()
	var j = 0
	for new_song_file in DirAccess.get_files_at("res://assets/audio/music/"):
		if new_song_file.ends_with(".import"): continue
		detected_songs.append(new_song_file)
		music_player_selector.add_item(new_song_file, j)
		j += 1
	if j != 0:
		music_player_selector.select(0)
		music_player_current_selection = detected_songs[0]
	else: print("No Music :(")
	music_player_selector.set_process_unhandled_input(false)

func force_remove_focus(child_control: Control = null) -> bool:
	if child_control != null:
		child_control.release_focus()
		child_control.focus_mode = Control.FOCUS_NONE
		return true
	else:
		for c: Control in get_children():
			c.focus_mode = Control.FOCUS_NONE
		return true

func update_debug_tracker(tracker_name: String, updated_value):
	match tracker_name:
		"afk_timer":
			%afk_timer_tracker.text = str(updated_value)
		"velocity":
			%velocity_transverse_tracker.text = "%5.2f" % Vector3(updated_value.x,0.0,updated_value.z).length()
			%velocity_length_tracker.text = "%5.2f" % updated_value.length()
			%velocity_x_tracker.text = "%.1f" % updated_value.x
			%velocity_y_tracker.text = "%.1f" % updated_value.y
			%velocity_z_tracker.text = "%.1f" % updated_value.z

func track_player_pickup(pickup_name: String = "dust", count: int = 1) -> bool:
	if !pickup_trackers.has(pickup_name):
		return false
	else:
		match pickup_name:
			"dust":
				%dust_tracker.text = str(int(%dust_tracker.text) + count)
			"coin":
				%coin_tracker.text = str(int(%coin_tracker.text) + count)
		return true

func _on_toggle_trackers_display(toggled_on: bool) -> void:
	%Trackers.visible = toggled_on
	%trackers_title_button.text = "[ %s Trackers ]" % ("Show" if !toggled_on else "Hide")

func _on_global_vol_slider_changed(new_val: float) -> void:
	AudioManager.global_volume = new_val

func toggle_debug_menu() -> void:
	%DebugPanel.visible = !%DebugPanel.visible
