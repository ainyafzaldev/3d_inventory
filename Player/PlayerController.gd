extends CharacterBody3D
# camera movements from youtube tut by bramwell 
class_name InvisiblePlayer
@onready var horizontal_pivot := $HorizontalPivot
@onready var vertical_pivot := $HorizontalPivot/VerticalPivot
@onready var hand_target: Marker3D = $HorizontalPivot/VerticalPivot/HandTarget
@onready var camera = $HorizontalPivot/VerticalPivot/Camera3D

const SPEED = 1.0
const JUMP_VELOCITY = 4.5

var horizontal_speed := 0.01
var vertical_speed := 0.001
var vertical_input := 0.0 # pitch
var horizontal_input := 0.0 #twist

var grid_size = 0.2
var ghost_block: InteractableItem = null

var currentItem: ItemData = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.position =  Vector3(0.0, 3.0, 3.0)
	
func move_ghost(delta):
	
	# move ghost block on imaginary grid
	var snap_pos : Vector3 = snap_to_grid(hand_target.global_position,grid_size)
	
	# slowly move:
	# ghost_block.global_position = lerp(ghost_block.position, snap_pos, 0.1)
	# instant move:
	ghost_block.global_position = snap_pos
	
	if Input.is_action_just_pressed("Rotate"):
		#instantly rotate:
		ghost_block.rotation.y += deg_to_rad(45)
		# slowly rotate:
		#ghost_block.rotation_degrees = lerp(ghost_block.rotation_degrees, 
		#ghost_block.rotation_degrees + Vector3(0, 90, 0), 0.5)

	if Input.is_action_just_pressed("Interact") and ghost_block.can_place:
		var block_instance = currentItem.ItemModelPrefab.instantiate()
		get_parent().add_child(block_instance)
		block_instance.place()
		block_instance.global_transform.origin = snap_to_grid(
			ghost_block.global_transform.origin, grid_size)
		block_instance.global_rotation = ghost_block.global_rotation

func snap_to_grid(position: Vector3, grid_snap: float) -> Vector3:
	# decorations have more fine tuned placements
	# just follow the hand target
	if ghost_block.isDecoration:
		return position
	# only  able to place furniture on floor
	var y = 0
	var x = round(position.x / grid_snap) * grid_snap
	var z = round(position.z / grid_snap) * grid_snap
	
	return Vector3(x, y, z)
	
func spawn_ghost_block() -> void:
	ghost_block = currentItem.ItemModelPrefab.instantiate()
	get_parent().add_child(ghost_block)
	ghost_block.global_position = self.global_position
	ghost_block.global_position.y = 0.5
	# the rotation is snapped, but faces the general direction of the player
	ghost_block.rotation_degrees.y = round(self.rotation_degrees.y / 45) * 45
		
# handles signal when new inventory item is selected
func new_build(item: ItemData) -> void:
	if ghost_block:
		ghost_block.destroy()
	if item:
		currentItem = item
		spawn_ghost_block()

func _physics_process(delta: float) -> void:
		
	if ghost_block:
		move_ghost(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# allow mouse to excape to quit
	if Input.is_action_just_pressed("ui_cancel"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ZoomIn"):
		camera.position.z -= 0.5
		camera.position.y -= 0.5
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, 0.0, 0.0),
			Vector3(0.0, 5.0, 5.0)
		)
	if Input.is_action_just_released("ZoomOut"):
		camera.position.z += 0.5
		camera.position.y += 0.5
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, 0.0, 0.0),
			Vector3(0.0, 5.0, 5.0)
		)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom 
	# gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	
	var move_direction = (
		transform.basis * Vector3(input_dir.x, 
		0, 
		input_dir.y)).normalized()
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	# mouse movement for camera
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			horizontal_input = - event.relative.x * horizontal_speed
			vertical_input = - event.relative.y * vertical_speed
			rotate_y(horizontal_input)
			vertical_pivot.rotate_x(vertical_input)
			vertical_pivot.rotation.x = clamp(
				vertical_pivot.rotation.x,
				deg_to_rad(-60),
				deg_to_rad(30)
			)
		vertical_input = 0.0
		horizontal_input = 0.0
		if hand_target.global_position.y < 0:
			hand_target.global_position.y = 0
