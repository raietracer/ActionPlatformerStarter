extends CSGBox3D


func is_visible_on_camera(camera : Camera3D) -> bool:
	if camera.global_position.y - self.global_position.y < -10.0:
		return false
	
	var corner_points = [
		global_transform * Vector3(-size.x/2, size.y/2, 0), # top left
		global_transform * Vector3(size.x/2, size.y/2, 0), # top right
		global_transform * Vector3(-size.x/2, -size.y/2, 0), # bottom left
		global_transform * Vector3(size.x/2, -size.y/2, 0) # bottom right
	]
	
	var num_points_outside_frustrum = 0
	for point in corner_points:
		if not camera.is_position_in_frustum(point):
			num_points_outside_frustrum += 1
			
	if num_points_outside_frustrum == 4:
		var frustum_planes = camera.get_frustum() # near, far, left, top, right, bottom
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
	if cur_camera and is_visible_on_camera(cur_camera) and (cur_camera.global_position - self.global_position).length() < 100:
		$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		$SubViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
