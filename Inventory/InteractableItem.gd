extends StaticBody3D
class_name InteractableItem
@onready var model : MeshInstance3D = %Model
#@onready var collision_shape : CollisionShape3D = $ModelCollision
@onready var collision_shape : CollisionShape3D = %ModelCollision
@onready var clipping_hitbox : Area3D = $ClippingHitBox
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var outline: MeshInstance3D = %Outline

var red_material: Material = load("res://Textures/red.tres")
var blue_material: Material = load("res://Textures/blue.tres")

var can_place = true

func _ready() -> void:
	unfocus()
	collision_shape.set_deferred("disabled", true)
	scale = Vector3(1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	if clipping_hitbox:
		model.transparency = 0.6
		can_place = clipping_hitbox.get_overlapping_bodies().is_empty()
		if can_place:
			model.material_override = blue_material
		else:
			model.material_override = red_material 
func focus():
	outline.visible = true
	
func unfocus():
	outline.visible = false
	
func place():
	anim.play("Place")
	clipping_hitbox.queue_free()
	model.material_override = null
	model.transparency = 0.0
	collision_shape.set_deferred("disabled", false)
	
func destroy():
	anim.play("Destroy")
	
func delete():
	queue_free()
