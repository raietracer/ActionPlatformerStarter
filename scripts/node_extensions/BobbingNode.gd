extends Node
class_name BobbingNode
## @experimental: Untested
## This extension to [class]StaticBody3D[/class] adds simple bobbing and spinning without the need for animation nodes
##

## Attach the the collisionshape child of this node for physics collisions
@export var physics_collider: CollisionShape3D
## Attach a node3d parent for all meshes
@export var node3d_mesh_root : Node3D
## Multiplies the sin waveform amplitude for height bobbing.  0 is off
@export var bob_height : float = 0.0
## Multiplied by delta and accumulated on y position. 0 is off
@export var bob_speed : float = 0.0
## Multiplied by delta and accumulated on y rotation. 0 is off
@export var spin_speed : float = 0.0
var _position_accumulator : float = deg_to_rad(0.0)

func _process(delta: float) -> void:
	if node3d_mesh_root == null: return
	node3d_mesh_root.rotation.y += delta * spin_speed
	_position_accumulator += delta * bob_speed
	node3d_mesh_root.global_position.y = node3d_mesh_root.global_position.y + bob_height * sin(_position_accumulator)
	if physics_collider != null:
		physics_collider.global_position.y = node3d_mesh_root.global_position.y
		physics_collider.rotation.y = node3d_mesh_root.rotation.y
