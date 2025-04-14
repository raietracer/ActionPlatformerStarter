extends CSGBox3D
class_name CSGMirrorBox3D
## @experimental: Work in Progress
## Easy Mirror Preset
##
## This node preset turns itself into a mirror using its global position and the CSGBox3D size property.
## The material must have a viewport texture assigned to its albedo texture as it is in the saved preset.

## Must be linked to function
@export var mirror_subviewport: SubViewport
## Must be positioned "outside" the csgbox bounds to function
@export var node3d_camera_root: Node3D

#func angle_mirror_cam(player_camera : Camera3D):
#	node3d_camera_root.global_basis = node3d_camera_root.global_basis.looking_at(player_camera.global_rotation.bounce(Vector3.FORWARD), Vector3.UP)

func should_mirror_cam_update(player_camera : Camera3D) -> bool:
	var _range_checker = player_camera.global_position.distance_to(self.global_position) <= 50
	#return range_checker
	return false

func is_visible_on_camera(player_camera : Camera3D) -> bool:
	if player_camera.global_position.y - get_parent().global_position.y < -10.0:
		return false
	
	var corner_points = [
		get_parent().global_transform * Vector3(-get_parent().size.x/2, get_parent().size.y/2, 0), # top left
		get_parent().global_transform * Vector3(get_parent().size.x/2, get_parent().size.y/2, 0), # top right
		get_parent().global_transform * Vector3(-get_parent().size.x/2, -get_parent().size.y/2, 0), # bottom left
		get_parent().global_transform * Vector3(get_parent().size.x/2, -get_parent().size.y/2, 0) # bottom right
	]
	
	var num_points_outside_frustrum = 0
	for point in corner_points:
		if not player_camera.is_position_in_frustum(point):
			num_points_outside_frustrum += 1
			
	if num_points_outside_frustrum == 4:
		var frustum_planes = player_camera.get_frustum() # near, far, left, top, right, bottom
		# Make sure all corners are on 1 side of frustum
		# This prevents the case when no points are inside the frustum, but the face is covering it
		for plane in frustum_planes:
			var all_points_outside = (
				plane.is_point_over(corner_points[0])
				and plane.is_point_over(corner_points[1])
				and plane.is_point_over(corner_points[2])
				and plane.is_point_over(corner_points[3])
			)
			if all_points_outside:
				return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var cur_camera = get_viewport().get_camera_3d()
	if cur_camera and should_mirror_cam_update(cur_camera):
		print("Turn off mirror cam update until fixed")
#		angle_mirror_cam(cur_camera)
	if cur_camera and is_visible_on_camera(cur_camera) and (cur_camera.global_position - get_parent().global_position).length() < 100:
		mirror_subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		mirror_subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
