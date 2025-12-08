extends Node3D
class_name InteractableItem

@export var ItemHighlightMesh: MeshInstance3D


# allows object to be highlighted when player is near

func GainFocus():
	ItemHighlightMesh.visible = true
	
func LoseFocus():
	ItemHighlightMesh.visible = false
