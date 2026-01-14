extends StaticBody3D
class_name InteractableItem
@onready var model : MeshInstance3D = %Model
#@onready var collision_shape : CollisionShape3D = $ModelCollision
@onready var collision_shape : CollisionShape3D = %ModelCollision
@onready var clipping_hitbox : Area3D = $ClippingHitBox
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var outline: MeshInstance3D = %Outline

@export var isDecoration : bool = false

var red_material: Material = load("res://Textures/red.tres")
var blue_material: Material = load("res://Textures/blue.tres")

var can_place = true
var first_place_hit = false

func _ready() -> void:
	unfocus()
	scale = Vector3(1.0, 1.0, 1.0)
	
	collision_shape.set_deferred("disabled", true)
	# uncomment for testing
	#clipping_hitbox.queue_free()

func _process(delta: float) -> void:#
	if clipping_hitbox:
		model.transparency = 0.6
		var bodies = clipping_hitbox.get_overlapping_bodies()
		#can_place = bodies.is_empty() or (bodies.size() == 1 and bodies[0] is InvisiblePlayer)
		can_place = bodies.is_empty()

		if can_place:
			set_material(blue_material)
		else:
			#print(clipping_hitbox.get_overlapping_bodies())
			set_material(red_material)
func focus():
	outline.visible = true
	
func unfocus():
	outline.visible = false
func set_material(material: Material):
	model.material_override = material
	for child in model.get_children():
		if child.name != "Outline":
			child.material_override = material
			child.transparency = 0.6
func place():
	
	clipping_hitbox.queue_free()
	model.material_override = null
	model.transparency = 0.0
	collision_shape.set_deferred("disabled", false)
	anim.play("Place")
	
func destroy():
	anim.play("Destroy")
	
func delete():
	queue_free()
