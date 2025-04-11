extends Area3D

func _process(delta: float) -> void:
	%Meshes.rotation.y += delta * 0.5
	%Meshes.position.y = 1.5 + sin(%Meshes.rotation.y)
