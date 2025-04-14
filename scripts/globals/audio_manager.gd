extends Node

# JOB: Take a wild guess

var global_volume = 1.0:
	set(new_val):
		global_volume = new_val
		change_all_volume()
var stored_bgm_linear_vol = 1.0


var sfx_players = 12
var flex_players = 1
var flex_player_cap = 20

var bus_names = ["Master", "Music", "SFX", "Flex"]

var audio_channels = {}
var audio_players = {}
var track_queues = {}

# static reference to the permanent bgm player
var master_audio_player
var bgm_main

var play_in_background

func _ready():
	var n
	for i in bus_names:
		n = Node.new()
		n.set_name(i+"_bus_players")
		audio_channels[i] = n
		audio_players[i] = []
		track_queues[i] = []
		add_child(n)
	master_audio_player = add_audio_players("Master")[0]
	bgm_main = add_audio_players("Music")[0]
	var _junk = add_audio_players("SFX", sfx_players)
	_junk.append_array(add_audio_players("Flex", flex_players))

func change_all_volume():
	var store_bgm = global_volume == 0.0
	for ch in audio_channels:
		for i in audio_channels[ch].get_children():
			if ch == "Music" && store_bgm:stored_bgm_linear_vol = i.volume_linear
			i.volume_linear = global_volume

func add_audio_players(channel:String="Flex",count:int=1) -> Array:
	var new_audio_players = []
	if channel == "Flex":
		if flex_players >= flex_player_cap:
			return [null]
		else:
			flex_players += count
	for i in count:
		var add_player = AudioStreamPlayer.new()
		audio_channels[channel].add_child(add_player)
		audio_players[channel].append(add_player)
		new_audio_players.append(add_player)
		add_player.finished.connect(_on_track_finished.bind(add_player))
		add_player.bus = channel
	return new_audio_players

func _on_track_finished(a_p: AudioStreamPlayer):
	audio_players[a_p.bus].append(a_p)
	if audio_players[a_p.bus].size() < 2:
		print("bus %s has %s players left" % [a_p.bus, audio_players[a_p.bus].size()])

func _process(_delta):
	for i in bus_names:
		if !track_queues[i].is_empty() and !audio_players[i].is_empty():
			var info = track_queues[i].pop_front()
			play(info[0], i, info[1], info[2], info[3])
	if !track_queues.Flex.is_empty() && audio_players.Flex.is_empty():
		add_audio_players()

func fadeout_audio_player(a_p:AudioStreamPlayer, fade_duration: float = 0.0):
	var tween = get_tree().create_tween()
	tween.tween_property(a_p, "volume_linear", 0, fade_duration)
	tween.tween_callback(a_p.stop)
	tween.tween_callback(audio_players[a_p.bus].append.bind(a_p))

func stop_all():
	var a = []
	a.append_array(audio_channels["Master"].get_children())
	a.append_array(audio_channels["Music"].get_children())
	a.append_array(audio_channels["SFX"].get_children())
	a.append_array(audio_channels["Flex"].get_children())
	for i in a:
		i.stop()

## volume is between 0 [muted] and 100 [full volume]
func play(path:String, channel:String="Flex", vol:float=100.0, fade_in:float=0, pos:float=0) -> AudioStreamPlayer:
	if global_volume == 0: return null
	var fixed_path = path
	if channel == "Music":
		fixed_path = str("music/") + path
	if !FileAccess.file_exists("res://assets/audio/"+fixed_path):
		prints("AudioManager: No file found @",fixed_path)
		return null
	var a_p: AudioStreamPlayer
	if audio_players[channel].is_empty():
		if channel == "Flex":
			a_p = add_audio_players()[0]
		elif channel == "Music":
			a_p = add_audio_players("Music")[0]
			fadeout_audio_player(bgm_main, 3.0)
			bgm_main = a_p
		else: 
			track_queues[channel].append([fixed_path, vol, fade_in, pos])
	else:
		a_p = audio_players[channel].pop_front()
	if a_p == null:
		print("Bus limit reached: %s skipping audio" % channel)
		return
	a_p.stream = load("res://assets/audio/%s"% fixed_path)
	var new_vol = global_volume * ( vol / 100.0 )
	if fade_in > 0:
		var tween = get_tree().create_tween()
		a_p.volume_linear = 0
		a_p.play(pos)
		tween.tween_property(a_p, "volume_linear", new_vol, fade_in)
	else:
		a_p.volume_linear = new_vol
		a_p.play(pos)
	return a_p

func _notification(what: int) -> void:
	if play_in_background: return
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
