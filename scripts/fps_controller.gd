#fps_controller.gd
extends CharacterBody3D
## @experimental: WORK IN PROGRESS
## This custom character controller is based on a YouTube tutorial series by Majikayo Games (links below)
##
## As [url=https://www.youtube.com/@MajikayoGames]Majikayo[/url] said in the
## [url=https://www.youtube.com/playlist?list=PLbuK0gG93AsHID1DDD1nt4YHcdOmJvWW1]Sourcelike movement tutorial series[/url],
## certain quirks of the way that the Source engine handles input for player have become well known and desirable.
## [br]The aim of this script is to make each distinct mechanic modular.  My hope is that future indie devs can use this
## script as a starting point, remove excess functionality, then branch out and hone the focus of their gamefeel.
## [br][color=red]WARNING: Script is plug-and-play but code is not yet modular; any changes may cause total failure.[/color]
##
## @tutorial(Majikayo Games Source-like Movement YouTube Tutorial Playlist): https://www.youtube.com/playlist?list=PLbuK0gG93AsHID1DDD1nt4YHcdOmJvWW1


#region Properties

@export_category("Fundamental")
@export_group("Jumping")
const TERMINAL_VELOCITY = 98
## Upward force applied once to engage the jump[br]
## [color=yellow]NOTE:[/color] Inspector display is rounded but it remains internally snapped to
## increments of [code]0.25[/code]
@export_range(0.0, 30.0, 0.25, "or_greater") var jump_velocity := 10.0
## If [code]true[/code], [method CharacterBody3D.jump] executes [i][b]every[/i][/b]
## physics frame in which [method CharacterBody3D.is_on_floor] returns [code]true[/code]
@export var auto_jump_when_grounded := true
## [code]0[/code] air jumps means [code]1[/code] ground jump
@export_range(0, 9, 1, "or_greater") var max_air_jumps : int = 1
@export var gravity_buffer := 0.3
var jumps_remaining : int = 2
var grav_buf_settler := 0.0
## Keeps track of [method CharacterBody3D.is_on_floor] to save calls
var grounded : bool
## Tracks the positive / negative state of velocity.y
var rising = false

@export_group("Speed")
@export var walk_speed := 8.5
@export var sprint_speed := 15.0
## Ground acceleration before pivot 
@export var base_acceleration := 240
## How fast (meters / second) to trigger the fov increase
@export var fov_speed_breakpoint := 30.0

@export_group("Momentum")
@export var ground_accel := 24.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0

@export_group("Air Surf")
@export var surf_air_cap := 0.85
@export var surf_air_accel := 800.0
@export var surf_air_move_speed := 500.0

@export_group("Camera")
## How long the camera takes to slide between zoom levels
@export var zoom_speed := 0.8
## How long to wait after detecting a zoom input before queuing another zoom input
@export var anti_zoom_queue := 0.0
## Maximum distance in meters the camera may zoom out from the player via input
@export var max_zoom := 10.0
## 3rd person camera field of view
@export var base_fov := 90.0
## 1st person camera field of view
@export var fps_fov := 110.0
## How much the field of view expands (in degrees) upon reaching fov_speed_breakpoint
@export var fov_increase_amount := 10.0
@export var stick_look_sensitivity := 2.5
@export var mouse_look_sensitivity := 0.2
## Godot's Engine default is 0.5
@export var custom_gamepad_deadzone := 0.2
var gamepad_look_vector := Vector2.ZERO
var spin_root = self
var first_person := true
var zoom_tween : Tween
var zoom_input := 0.0
var target_spring_length := 0.0
var saved_camera_global_pos = null

@export_category("Extensions")
@export_group("Experimental")
@export var cam_while_clicked := true
var use_mesh_forward = false

@export_group("Noclip")
@export var noclip_base_speed_mult := 3.0
var cam_aligned_wish_dir := Vector3.ZERO
var noclip := false

@export_group("Stair Handling")
@export var max_step_height := 0.54
@export var cam_smooth_on_stairs_margin := 0.7
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

@export_group("Crouch Jump")
@export var crouch_translate := 0.7
@export var crouch_jump_add = crouch_translate * 0.9
var is_crouched
var crouch_jump_cam_smoother := 7.0
@onready var original_capsule_height = $CollisionShape3D.shape.height

@export_group("Pivot Speed Boost")
## Max dot product against current velocity that triggers pivot speed boost
@export var pivot_ratio := -0.25
## Speed multiplier for pivoting
@export var pivot_accel_mult := 2.0
## Higher values make the player snap to a stop faster, effectively a "grip" or "friction"
@export var stopping_accel_mult := 4.0

var input_dir := Vector2.ZERO
var wish_dir := Vector3.ZERO

@onready var DEBUG_MENU_DISPLAY = preload("res://scenes/hud_canvas.tscn")
var debug_menu_display = null

#endregion
#region Overrides

func _ready() -> void:
	%PlayerCam.fov = base_fov
	for child in %Meshes.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(6, true)

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("quit_game"): get_tree().quit()
	
	if Input.is_action_just_pressed("left_click") || Input.is_action_just_pressed("right_click"): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if cam_while_clicked && ((Input.is_action_just_released("left_click") && ! Input.is_action_pressed("right_click")) || (Input.is_action_just_released("right_click")) && !Input.is_action_pressed("left_click")): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_menu"): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# testing features
	if OS.has_feature("debug"):
		if Input.is_action_just_pressed("noclip"): noclip = !noclip
		if Input.is_action_just_pressed("testing_reset"):
			if !debug_menu_display:
				debug_menu_display = DEBUG_MENU_DISPLAY.instantiate()
				add_child(debug_menu_display)
				debug_menu_display.show()
				debug_menu_display.connect("activate_telepoint", on_telepoint_activated)
			elif debug_menu_display.visible == true: debug_menu_display.hide()
			else:
				debug_menu_display.show()
				debug_menu_display.refresh_list()

	# camera mouse control
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			use_mesh_forward = cam_while_clicked && event.button_mask == MOUSE_BUTTON_LEFT
			spin_root.rotate_y(-event.relative.x * mouse_look_sensitivity * 0.01)
			%SpringArm3D.rotate_x(-event.relative.y * mouse_look_sensitivity * 0.01)
			%SpringArm3D.rotation.x = clampf(%SpringArm3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			if (%Head.global_transform.basis.z).dot(%Meshes.global_transform.basis.z) > 0.2:
				%Headspin.rotate_x(-event.relative.y * mouse_look_sensitivity * 0.01)
				%Headspin.rotation.x = clampf(%Headspin.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			else: %Headspin.rotation = Vector3.ZERO
			spin_root.rotation.y = wrapf(spin_root.rotation.y, deg_to_rad(0), deg_to_rad(360))

func _process(delta: float) -> void:
	# First / Third Person autodetecter
	var was_first_person = first_person
	first_person = (zoom_input <= 0.0 && %SpringArm3D.spring_length <= 0.6)
	%PlayerCam.set_cull_mask_value(6,!first_person)
	%CamSprite.visible = !first_person
	spin_root = %Head if !first_person else self
	if first_person && !was_first_person:
		rotate_y(wrapf(%Head.rotation.y, deg_to_rad(0), deg_to_rad(360)))
		%Head.rotation.y = 0
		%Meshes.rotation.y = 0
	change_cam_perspective(delta)
	look_and_rotate(delta)
	# Early drop mid jump
	if grav_buf_settler != 0.0:
		if rising and ! Input.is_action_pressed("jump"):
			rising = false
			grav_buf_settler = 0
	if Input.is_action_just_pressed("speed_up"): noclip_base_speed_mult = min(100.0, noclip_base_speed_mult * 1.1)
	if Input.is_action_just_pressed("slow_down"): noclip_base_speed_mult = max(0.1, noclip_base_speed_mult * 0.9)
	if noclip && Input.is_action_pressed("jump"):
		self.velocity.y = get_move_speed() * noclip_base_speed_mult
		global_position.y += self.velocity.y * delta
	elif noclip && Input.is_action_pressed("crouch"):
		self.velocity.y = - get_move_speed() * noclip_base_speed_mult
		global_position.y += self.velocity.y * delta
	if %MeshHead.global_rotation.y != %Head.global_rotation.y && (%Head.global_transform.basis.z).dot(%Meshes.global_transform.basis.z) > 0.2: %MeshHead.global_rotation.y = %Head.global_rotation.y
	if %Headspin.global_rotation.x != %SpringArm3D.global_rotation.x && (%Head.global_transform.basis.z).dot(%Meshes.global_transform.basis.z) > 0.2: %Headspin.global_rotation.x = %SpringArm3D.global_rotation.x

func _physics_process(delta: float) -> void:
	if is_on_floor() or _snapped_to_stairs_last_frame:
		_last_frame_was_on_floor = Engine.get_physics_frames()
		if !grounded: jumps_remaining = max_air_jumps
	grounded = is_on_floor() or _snapped_to_stairs_last_frame
	input_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward")).normalized()
	
	# Handles look-around without turning
	if !use_mesh_forward:
		wish_dir = spin_root.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
		cam_aligned_wish_dir = %PlayerCam.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	elif spin_root.global_rotation.y != %Meshes.global_rotation.y && !Input.is_action_pressed("right_click"):
		wish_dir = %Meshes.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
		cam_aligned_wish_dir = %Meshes.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	# OLD PIVOT CODE
#	var target_ground_accel = base_acceleration
#	ground_accel *= stopping_accel_mult if input_dir == Vector2.ZERO else (1.0 if wish_dir.dot(velocity) > pivot_ratio else pivot_accel_mult)

	handle_crouch(delta)
	if not handle_noclip(delta):
		if grounded:
			# Momentum
			var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
			var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
			if add_speed_till_cap > 0:
				var accel_speed = ground_accel * delta * get_move_speed()
				accel_speed = min(accel_speed, add_speed_till_cap)
				self.velocity += accel_speed * wish_dir
			# Friction
			var control = max(self.velocity.length(), ground_decel)
			var drop = control * ground_friction * delta
			var new_speed = max(self.velocity.length() - drop, 0.0)
			if self.velocity.length() > 0: new_speed /= self.velocity.length()
			self.velocity *= new_speed
	#		velocity.x = lerp(velocity.x, wish_dir.x * get_move_speed(), delta * (ground_accel)) #if grounded else acceleration / 4))
	#		velocity.z = lerp(velocity.z, wish_dir.z * get_move_speed(), delta * (ground_accel)) #if grounded else air_acceleration))
			if Input.is_action_just_pressed("jump") || (Input.is_action_pressed("jump") && auto_jump_when_grounded): jump()
		else:
			
			# Multi Jump
			if jumps_remaining > 0 && Input.is_action_just_pressed("jump"): jump()
			
			# grav_buffer helps jumps reach higher while maintaining a strong gravitational pull for game feel.
			if grav_buf_settler != 0.0 && Input.is_action_pressed("jump"):
				velocity.y = clampf(velocity.y - (8 * ProjectSettings.get_setting("physics/3d/default_gravity") * delta) * clampf((0.01 / (grav_buf_settler / gravity_buffer)),0.001, 1.0), -TERMINAL_VELOCITY, velocity.y)
			else:
				velocity.y = clampf(velocity.y - (8 * ProjectSettings.get_setting("physics/3d/default_gravity") * delta), -TERMINAL_VELOCITY, velocity.y)
			grav_buf_settler = clampf(grav_buf_settler - delta, 0, grav_buf_settler)
			rising = velocity.y > 0
			
			# CS Surf
			var cur_speed_in_wish_dir = velocity.dot(wish_dir)
			var capped_speed = min((surf_air_move_speed * wish_dir).length(), surf_air_cap)
			var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
			if add_speed_till_cap > 0:
				var accel_speed = surf_air_accel * surf_air_move_speed * delta
				accel_speed = min(accel_speed, add_speed_till_cap)
				velocity += accel_speed * wish_dir
			if is_on_wall():
				if !is_surface_too_steep(get_wall_normal()): self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
				else: self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
				clip_velocity(get_wall_normal(), 1.0, delta)

		if not snap_up_stairs_check(delta):
			push_away_rigid_bodies()
			move_and_slide()
			snap_down_to_stairs_check()
	slide_camera_smooth_back_to_origin(delta)

	# Dont turn mesh forward if only looking around
	if !use_mesh_forward && !first_person:#(!first_person && (velocity.x != 0.0 || velocity.z != 0.0)):
		%Meshes.rotation.y = lerp_angle(%Meshes.rotation.y, spin_root.rotation.y, delta * 3 )
		%Meshes.rotation.y = wrapf(%Meshes.rotation.y, deg_to_rad(0), deg_to_rad(360))

#endregion
#region Camera Methods

func change_cam_perspective(delta: float) -> void:
	if anti_zoom_queue != 0.0:
		anti_zoom_queue = clampf(anti_zoom_queue-delta,0,anti_zoom_queue)
		return
	var new_fov = base_fov if velocity.length() <= fov_speed_breakpoint else base_fov + 15.0
	%PlayerCam.fov = lerp(%PlayerCam.fov, new_fov, delta * 3.0)
	zoom_input = 0
	zoom_input = float(Input.is_action_just_pressed("mouse_zoom_out")) - float(Input.is_action_just_pressed("mouse_zoom_in"))
	if zoom_input == 0.0:
		zoom_input = Input.get_axis("zoom_in", "zoom_out")
	if zoom_input != 0.0:
		anti_zoom_queue += 0.02
		target_spring_length = clampf(target_spring_length + zoom_input * (0.5 if !Input.is_action_pressed("sprint") else 1.0), 0, max_zoom)
		if target_spring_length != %SpringArm3D.spring_length:
			if zoom_tween:
				zoom_tween.kill()
			zoom_tween = get_tree().create_tween()
			zoom_tween.tween_property(%SpringArm3D, "spring_length", target_spring_length, zoom_speed )

func look_and_rotate(delta: float) -> void:
	var gamepad_look_target = Input.get_vector("look_left", "look_right", "look_up", "look_down", custom_gamepad_deadzone).normalized()
	
#	if gamepad_look_target.length() < gamepad_look_vector.length():
#		gamepad_look_vector = gamepad_look_target
#	else:
	gamepad_look_vector = gamepad_look_vector.lerp(gamepad_look_vector, 5.0 * delta)
	
	if gamepad_look_target != Vector2.ZERO:
		spin_root.rotate_y(-gamepad_look_target.x * stick_look_sensitivity * delta)
		%SpringArm3D.rotate_x(-gamepad_look_target.y * stick_look_sensitivity * delta)
		%SpringArm3D.rotation.x = clampf(%SpringArm3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		spin_root.rotation.y = wrapf(spin_root.rotation.y, deg_to_rad(0), deg_to_rad(360))
		if (%Head.global_transform.basis.z).dot(%Meshes.global_transform.basis.z) > 0.2:
			%Headspin.rotate_x(-gamepad_look_target.y * stick_look_sensitivity * delta)
			%Headspin.rotation.x = clampf(%Headspin.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		else:
			%Headspin.rotation = Vector3.ZERO

func save_camera_pos_for_smoothing():
	if saved_camera_global_pos == null:
		saved_camera_global_pos = %CameraSmooth.position

func slide_camera_smooth_back_to_origin(delta: float):
	if saved_camera_global_pos == null: return
	%CameraSmooth.position.y = saved_camera_global_pos.y
	%CameraSmooth.position.y = clampf(%CameraSmooth.position.y, -cam_smooth_on_stairs_margin, cam_smooth_on_stairs_margin)
	var move_amount = min(self.velocity.length() * delta, walk_speed / 2.0 * delta)
	%CameraSmooth.position.y = move_toward(%CameraSmooth.position.y, 0.0, move_amount)
	saved_camera_global_pos = %CameraSmooth.position
	if %CameraSmooth.position.y == 0:
		saved_camera_global_pos = null

#endregion
#region Movement

func get_move_speed() -> float:
	var final_speed = walk_speed
	if Input.is_action_pressed("sprint"):
		final_speed = sprint_speed
	if Input.is_action_pressed("crouch"):
		final_speed *= 0.8
	if !grounded:
		final_speed *= 1.05
	return final_speed

func jump():
	rising = true
	if !grounded: jumps_remaining -= 1
	grounded = false
	velocity.y = jump_velocity * (1 + gravity_buffer) #= clampf(self.velocity.y + jump_velocity, 0., 20.)
	grav_buf_settler = gravity_buffer

func clip_velocity(normal: Vector3, overbounce: float, _delta: float) -> void:
	var backoff := self.velocity.dot(normal) * overbounce
	if backoff >= 0: return
	var change := normal * backoff
	self.velocity -= change
	
	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust

func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params =  PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func snap_down_to_stairs_check() -> void:
	var did_snap := false
	%StairsBelowRayCast.force_raycast_update()
	var floor_below: bool = %StairsBelowRayCast.is_colliding() and not is_surface_too_steep(%StairsBelowRayCast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(self.global_transform, Vector3(0.0, -max_step_height, 0.0), body_test_result):
			save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1.0,1.0,1.0) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0.0, max_step_height, 0.0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(step_pos_with_clearance, Vector3(0.0, -max_step_height * 2.0, 0.0), down_check_result))\
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D")):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > max_step_height: return false
		%StairsAheadRayCast.global_position = down_check_result.get_collision_point() + Vector3(0.0, max_step_height, 0.0) + expected_move_motion.normalized() * 0.1
		%StairsAheadRayCast.force_raycast_update()
		if %StairsAheadRayCast.is_colliding() and not is_surface_too_steep(%StairsAheadRayCast.get_collision_normal()):
			save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

func handle_crouch(delta: float) -> void:
	var was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("crouch"):
		is_crouched = true
	elif is_crouched and not self.test_move(self.global_transform, Vector3(0.0, crouch_translate, 0.0)):
		is_crouched = false
	
	var translate_y_if_possible := 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor() and not _snapped_to_stairs_last_frame:
		translate_y_if_possible = crouch_jump_add if is_crouched else - crouch_jump_add
	
	# Prevent the mid-air un-crouch from collision clipping
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.global_transform, Vector3(0.0, translate_y_if_possible, 0.0), result)
		self.position.y += result.get_travel().y
		%Head.position.y -= result.get_travel().y
		%Head.position.y = clampf(%Head.position.y, -crouch_translate, 0.0)
	
	%Head.position.y = move_toward(%Head.position.y, (-crouch_translate if is_crouched else 0.0), crouch_jump_cam_smoother * delta)
#	%Head.position = Vector3(0.0, (-crouch_translate if is_crouched else 0.0), 0.0)
	$CollisionShape3D.shape.height = original_capsule_height - crouch_translate if is_crouched else original_capsule_height
	$CollisionShape3D.position.y = $CollisionShape3D.shape.height / 2.0

func push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var pushbox_detect = false
		for j in %pushbox.get_child_count():
			if c.get_local_shape(i) == %pushbox || c.get_local_shape(i) == %pushbox.get_child(j):
				pushbox_detect = true
				break
		if !pushbox_detect: return
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_in_push_dir = max(0.0, velocity_diff_in_push_dir)
			var MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1.0, MY_APPROX_MASS_KG / c.get_collider().mass)
			push_dir.y = 0
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)


#endregion
#region Debugging

func handle_noclip(delta) -> bool:
	$CollisionShape3D.disabled = noclip
	if not noclip:
		return false
	
	var speed = get_move_speed() * noclip_base_speed_mult
	if Input.is_action_pressed("sprint"):
		speed *= 3.0
	
	self.velocity = cam_aligned_wish_dir * speed
	global_position += self.velocity * delta
	
	return true

func on_telepoint_activated(telepoint_position) -> void:
	velocity = Vector3.ZERO
	global_position = telepoint_position

#endregion

# Something is causing massive frame drops.  Find and eradicate.
# Re-implement Pivot Boost (halt, then gain a boost in speed when making tight turns)
# Add modular head-bob
# Stair Control: [url=https://github.com/kelpysama/Godot-Stair-Step-Demo]give this a shot[/url]
# Glide
# Air dive
# Fall damage
# Long jump
# Wall jump
# Triple jump
# Super jump
# Wall run
# Wall grab
# Ladder climb
# Ladder slide
# Coyote time
# Slide
# Slide jump
# Strafe
# Dodge
# Crawl
# Sneak
# Swim
# Sprint swim
# Water dive
# Third person implementation, planned to overhaul using Majikayo's design.
