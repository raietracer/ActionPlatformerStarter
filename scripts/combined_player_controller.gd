extends CharacterBody3D

@export_group("Reference")
@export var animation_tree : AnimationTree
@export var mesh_root : Node3D

@export_group("Environment")
@export var max_air_jump : int = 1
@export var fall_gravity : float = 45
@export var rotation_speed : float = 8

@export_group("Abilities")
@export var jump_states : Dictionary

@onready var yaw_node = $CamRoot/CamYaw
@onready var pitch_node = $CamRoot/CamYaw/CamPitch
@onready var spring_arm = $CamRoot/CamYaw/CamPitch/SpringArm3D
@onready var camera = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D

var stances : Dictionary = {
	"upright": ^"Stances/upright",
	"stealth": ^"Stances/stealth",
	"crouch": ^"Stances/crouch",
	"prone": ^"Stances/prone",
}

var air_jump_counter : int = 0
var movement_direction : Vector3
var current_stance_name : String = "upright"
var current_movement_state_name : String 
var stance_antispam_timer : SceneTreeTimer

var jump_gravity : float = fall_gravity
var direction : Vector3
var p_velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0
var player_init_rotation : float

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 75
var pitch_min : float = -55
var cam_distance : float = 6.0
var tween2 : Tween
var position_offset : Vector3 = Vector3(0, 2.6, 0)
var position_offset_target : Vector3 = Vector3(0, 2.6, 0)

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1
var tween3 : Tween

func _ready():
	stance_antispam_timer = get_tree().create_timer(0.25)
	direction = Vector3.BACK.rotated(Vector3.UP, cam_rotation + player_init_rotation)
	set_movement_state("stand")
	set_stance(current_stance_name)
	player_init_rotation = rotation.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.add_excluded_object(get_rid())
	spring_arm.add_excluded_object(%WallCling.get_rid())
	cam_distance = spring_arm.spring_length

func _input(event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("zoom_in"):
		cam_distance = clampf(cam_distance - 1, 0, 12)
	if Input.is_action_just_pressed("zoom_out"):
		cam_distance = clampf(cam_distance + 1, 0, 12)
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity

	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		movement_direction.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
		movement_direction.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
		
		if (abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0):
			if Input.is_action_pressed("sprint"):
				set_movement_state("sprint")
				if current_stance_name == "stealth":
					set_stance("upright")
			else:
			#	if Input.is_action_pressed("run"):
			#		set_movement_state("run")
				if Input.is_action_pressed("walk") && current_movement_state_name != "walk":
					set_movement_state("walk")
				else:
					set_movement_state("run")
		else:
			set_movement_state("stand")
	
	if event.is_action_pressed("jump") && !is_stance_blocked("upright"):
		set_stance("upright")
		var jump_name = "ground_jump"
		if !is_on_floor():
			if 0 < air_jump_counter && air_jump_counter <= max_air_jump:
				jump_name = "air_jump"
				air_jump_counter += 1
			else:
				return
		jump(jump_name)
	
	if is_on_floor():
		for stance in stances.keys():
			if event.is_action_pressed(stance):
				set_stance(stance)
	
	if Input.is_action_just_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func jump(jump_name: String):
	prints(velocity, p_velocity)
	p_velocity.y = 2 * jump_states[jump_name].jump_height / jump_states[jump_name].apex_duration
	jump_gravity = p_velocity.y / jump_states[jump_name].apex_duration
	animation_tree["parameters/" + jump_states[jump_name].animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _physics_process(delta):
	
	if (abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0):
		direction = movement_direction.rotated(Vector3.UP, cam_rotation + player_init_rotation)
		
	if is_on_floor():
		air_jump_counter = 0
	elif air_jump_counter == 0:
		air_jump_counter = 1
	
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	if not is_on_floor():
		if velocity.y >= 0:
			p_velocity.y -= jump_gravity * delta
		else:
			p_velocity.y -= fall_gravity * delta
	
	velocity = velocity.lerp(p_velocity, acceleration * delta)
	move_and_slide()
	
	var target_rotation = atan2(direction.x, direction.z) - player_init_rotation
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	yaw += 3 * (Input.get_action_strength("look_left") - Input.get_action_strength("look_right"))
	pitch += 3 * (Input.get_action_strength("look_up") - Input.get_action_strength("look_down"))
		
	position_offset = lerp(position_offset, position_offset_target, 4 * delta)
	$CamRoot.global_position = lerp($CamRoot.global_position, global_position + position_offset, 18 * delta)
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)				#yaw_node.rotation_degrees.y = yaw
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)		#pitch_node.rotation_degrees.x = pitch
	spring_arm.spring_length = lerp(spring_arm.spring_length, cam_distance, 10 * delta)
	if spring_arm.spring_length < 0.5:
		mesh_root.visible = false
	else:
		mesh_root.visible = true
	
	cam_rotation = yaw_node.rotation.y
	
	on_floor_blend_target = 1 if is_on_floor() else 0
	on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, 10 * delta)
	animation_tree["parameters/on_floor_blend/blend_amount"] = on_floor_blend

func set_movement_state(state : String):
	var stance = get_node(stances[current_stance_name])
	current_movement_state_name = state
	speed = stance.get_movement_state(state).movement_speed
	acceleration =  stance.get_movement_state(state).acceleration
	if tween2:
		tween2.kill()
	tween2 = create_tween()
	tween2.tween_property(camera, "fov", stance.get_movement_state(state).camera_fov, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if tween3:
		tween3.kill()
	tween3 = create_tween()
	tween3.tween_property(animation_tree, "parameters/" + current_stance_name + "_movement_blend/blend_position", stance.get_movement_state(state).id, 0.25)
	tween3.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", stance.get_movement_state(state).animation_speed, 0.7)

func set_stance(_stance_name : String):
	if (stance_antispam_timer.time_left > 0)\
	|| (current_stance_name == "prone" && is_stance_blocked("crouch"))\
	|| (current_stance_name == "crouch" && _stance_name != "prone" && is_stance_blocked("upright")):
		return
	
	stance_antispam_timer = get_tree().create_timer(0.05)
	
	var next_stance_name : String
	
	if current_stance_name == "prone" && is_stance_blocked("upright"):
		next_stance_name = "crouch"
	elif current_stance_name == _stance_name:
		next_stance_name = "upright"
	else:
		next_stance_name = _stance_name
	
	var current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = true
	
	current_stance_name = next_stance_name
	current_stance = get_node(stances[current_stance_name])
	current_stance.collider.disabled = false
	
	position_offset_target.y = current_stance.camera_height
	animation_tree["parameters/stance_transition/transition_request"] = current_stance.name
	current_stance_name = current_stance.name
	
	set_movement_state(current_movement_state_name)

func is_stance_blocked(_stance_name : String) -> bool:
	var stance = get_node(stances[_stance_name])
	return stance.is_blocked()
