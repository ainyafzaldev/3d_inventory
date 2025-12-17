
extends Node3D

@export var width := 20
@export var height := 20
@export var margin := 0.0
@export var cellSize := 1.6

func _ready() -> void:
	_create_grid()
	#scale = Vector3(0.2, 0.2, 0.2)
	
func _create_grid():
	for height in range(height):
		for width in range(width):
			var mesh = MeshInstance3D.new()
			mesh.mesh = PlaneMesh.new()
			mesh.mesh.size = Vector2(cellSize, cellSize)
			
			add_child(mesh)
			
			mesh.global_position = global_position + Vector3(
				width * (mesh.mesh.size.x + margin),
				0.2,
				height * (mesh.mesh.size.y + margin),
				
			)
