extends CharacterBody3D
# camera movements from youtube tut by bramwell 

signal BuildModeChange(new_build_mode: bool)

@onready var horizontal_pivot := $HorizontalPivot
@onready var vertical_pivot := $HorizontalPivot/VerticalPivot
@onready var hand_target: Marker3D = $HorizontalPivot/VerticalPivot/HandTarget
@onready var build_mode = $InteractionArea.build_mode


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var horizontal_speed := 0.01
var vertical_speed := 0.001
var vertical_input := 0.0 # pitch
var horizontal_input := 0.0 #twist

var grid_size = 0.25
var ghost_block: InteractableItem = null

var currentObject: ItemData = null

func _ready() -> void:
	change_build_mode(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func building(delta):
	var snap_pos : Vector3 = snap_to_grid(hand_target.global_position, grid_size)
	# slowly move from a to be based on speed c
	ghost_block.global_position = lerp(ghost_block.position, snap_pos, 0.1)
	if Input.is_action_just_pressed("Rotate"):
		ghost_block.rotation.y += deg_to_rad(90)
		
		
	if Input.is_action_just_pressed("Interact") and ghost_block.can_place:
		var block_instance = currentObject.ItemModelPrefab.instantiate()
		get_parent().add_child(block_instance)
		block_instance.place()
		block_instance.global_transform.origin = snap_to_grid(ghost_block.global_transform.origin, grid_size)
		block_instance.global_rotation = ghost_block.global_rotation

func snap_to_grid(position: Vector3, grid_snap: float) -> Vector3:
	var x = round(position.x / grid_snap) * grid_snap
	#var y = 0
	var y = round(position.y / grid_snap) * grid_snap
	var z = round(position.z / grid_snap) * grid_snap
	return Vector3(x, y, z)
	
func spawn_ghost_block() -> void:
	ghost_block = currentObject.ItemModelPrefab.instantiate()
	get_parent().add_child(ghost_block)
	ghost_block.global_position = self.global_position
	ghost_block.global_position.y = 0.5
	
	
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
		
func new_build(item: ItemData) -> void:
	# TODO: show different ghost object when changing
	# TODO set build status based on item selected
	# signal handler from Inventory Handler
	change_build_mode(true)
	currentObject = item
	if ghost_block:
		ghost_block.destroy()
	spawn_ghost_block()
func exit_build() -> void:
	change_build_mode(false)
	if ghost_block:
		ghost_block.destroy()
func change_build_mode(new_build_mode: bool) -> void:
	BuildModeChange.emit(new_build_mode)
	build_mode = new_build_mode
func _physics_process(delta: float) -> void:
		
	if ghost_block:
		building(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# allow mouse to excape to quit
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	
	var move_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
