extends CharacterBody3D
# camera movements from youtube tut by bramwell 
class_name InvisiblePlayer
@onready var horizontal_pivot := $HorizontalPivot
@onready var vertical_pivot := $HorizontalPivot/VerticalPivot
@onready var hand_target: Marker3D = $HorizontalPivot/VerticalPivot/HandTarget
@onready var first_person_camera: Camera3D = $HorizontalPivot/VerticalPivot/FirstPerson
@onready var overhead_camera = $HorizontalPivot/VerticalPivot/Overhead
@onready var raycast := $HorizontalPivot/VerticalPivot/FirstPerson/RayCast3D

var camera = first_person_camera
var fpc_min = 1.0
var fpc_max = 5.0

var ohc_min = 12.0
var ohc_max = 42.0

const SPEED = 1.3
const JUMP_VELOCITY = 4.5

var horizontal_speed := 0.01
var vertical_speed := 0.001
var vertical_input := 0.0 # pitch
var horizontal_input := 0.0 #twist

var grid_size = 0.2
var ghost_block: InteractableItem = null

var currentItem: ItemData = null

var first_capture = true

var interaction_distance := 6.0
var interactin_cast_result

var highlightedObject: InteractableItem = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	first_person_camera.make_current()
	camera = first_person_camera
	$UI/Tutorial.visible =  true
	$UI/StartLine.visible = true
func _input(event):
	# mouse movement for camera
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			horizontal_input = - event.relative.x * horizontal_speed
			vertical_input = - event.relative.y * vertical_speed
			# since walking girl is a child, it will also rotate
			# to face the camera
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
	if Input.is_action_just_pressed("mouse_capture"):
		if first_capture:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			first_capture = false
			$UI/Tutorial.visible =  false
			$UI/StartLine.visible = false
		#
	#if Input.is_action_just_pressed("mouse_release"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func move_ghost(delta):
	# move ghost block on imaginary grid
	var snap_pos : Vector3 = snap_to_grid(hand_target.global_position,grid_size)
	ghost_block.global_position = snap_pos
	
	if Input.is_action_just_pressed("Rotate"):
		$UI/UiSounds/furnitureRotated.play()
		ghost_block.rotation.y += deg_to_rad(45)

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
	Globals.InventorySelected = true
	ghost_block = currentItem.ItemModelPrefab.instantiate()
	
	ghost_block.global_position = self.global_position
	ghost_block.global_position.y = 0.5
	get_parent().add_child(ghost_block)
	# the rotation is snapped, but faces the general direction of the player
	ghost_block.rotation_degrees.y = round(self.rotation_degrees.y / 45) * 45
		
# handles signal when new inventory item is selected
func new_build(item: ItemData) -> void:
	if ghost_block:
		ghost_block.destroy()
		Globals.InventorySelected = false
	if item:
		currentItem = item
		spawn_ghost_block()
		
# handles signal from UI when user requests ghost block be placed
# returns if successfull
func place_ghost_block() -> bool:
	if not ghost_block.can_place:
		return false
	ghost_block.destroy()
	await get_tree().create_timer(0.2).timeout
	var block_instance = currentItem.ItemModelPrefab.instantiate()
	get_parent().add_child(block_instance)
	block_instance.place()
	block_instance.global_transform.origin = snap_to_grid(
		ghost_block.global_transform.origin, grid_size)
	block_instance.global_rotation = ghost_block.global_rotation
	
	Globals.InventorySelected = false
	return true
	
func zoom_in() -> void:
	if camera == first_person_camera:
		camera.position.z -= 0.5
		camera.position.y -= 0.5
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, fpc_min, fpc_min),
			Vector3(0.0, fpc_max, fpc_max)
		)
	else:
		camera.position.y -= 1.0
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, ohc_min, 0.0),
			Vector3(0.0, ohc_max, 0.0)
		)
		
func zoom_out() -> void:
	if camera == first_person_camera:
		camera.position.z += 0.5
		camera.position.y += 0.5
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, fpc_min, fpc_min),
			Vector3(0.0, fpc_max, fpc_max)
		)
	else:
		camera.position.y += 1.0
		camera.position =  clamp(
			camera.position,
			Vector3(0.0, ohc_min, 0.0),
			Vector3(0.0, ohc_max, 0.0)
		)
func change_camera() -> void:
	if camera == first_person_camera:
		first_person_camera.clear_current()
		overhead_camera.make_current()
		camera = overhead_camera
	elif camera == overhead_camera:
		overhead_camera.clear_current()
		first_person_camera.make_current()
		camera = first_person_camera

	
func _physics_process(delta: float) -> void:
	# allow mouse to excape to quit
	if Input.is_action_just_pressed("Exit"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# extra check because of itch io escape
	if $UI/Tutorial.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		move_and_slide()
		return
	
	# set highlighted object using raycast
	if raycast.is_colliding():
		if raycast.get_collider() is InteractableItem:
			if highlightedObject and raycast.get_collider() != highlightedObject:
				highlightedObject.unfocus()
				highlightedObject = null
			else:
				highlightedObject = raycast.get_collider()
	elif highlightedObject:
		highlightedObject.unfocus()
		highlightedObject = null
		
	# highlihght object based on build mode
	if highlightedObject:
		highlightedObject.unfocus()
		if Globals.Mode == Globals.buildMode:
			highlightedObject.focus()
	if (Input.is_action_pressed("Delete") and Globals.buildMode ==  Globals.buildMode):
		if highlightedObject:
			$UI/UiSounds/cancel.play()
			highlightedObject.destroy()
			highlightedObject = null
		
	if ghost_block:
		move_ghost(delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ZoomIn"):
		zoom_in()
	if Input.is_action_just_released("ZoomOut"):
		zoom_out()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom 
	# gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	# make character turn to direction they are walking in
	# if up pressed, face up
	if input_dir == Vector2(0.0, 1.0):
		$WalkingGirl.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	# if right pressed, face right
	if input_dir == Vector2(1.0, 0.0):
		$WalkingGirl.rotation_degrees = Vector3(0.0, 90.0, 0.0)
	# if down pressed face down
	elif input_dir == Vector2(0.0, -1.0):
		$WalkingGirl.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	# if left pressed face left
	elif input_dir == Vector2(-1.0, 0.0):
		$WalkingGirl.rotation_degrees = Vector3(0.0, 270.0, 0.0)
	else:
		# diagonals
		if input_dir.x > 0 and input_dir.y > 0:
			# top right
			$WalkingGirl.rotation_degrees = Vector3(0.0, 45.0, 0.0)
		elif input_dir.x > 0 and input_dir.y < 0:
			# bottom right
			$WalkingGirl.rotation_degrees = Vector3(0.0, 135.0, 0.0)

		elif input_dir.x < 0 and input_dir.y < 0:
			# bottom left
			$WalkingGirl.rotation_degrees = Vector3(0.0, 225.0, 0.0)
		elif input_dir.x < 0 and input_dir.y > 0:
			# top left
			$WalkingGirl.rotation_degrees = Vector3(0.0, 315.0, 0.0)
	var move_direction = (
		transform.basis * Vector3(input_dir.x, 
		0, 
		input_dir.y)).normalized()

	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		$WalkingGirl.startWalking()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$WalkingGirl.stopWalking()
	move_and_slide()

	
#func HighlightNearestItem():
	#if Globals.Mode == Globals.viewMode:
		#return
	#var nearestItem: InteractableItem = FindNearestItem()
	#if highlightedObject != null:
		#highlightedObject.unfocus()
		#Globals.FurnitureHighlighted = false
	#if nearestItem != null:
		#highlightedObject = nearestItem
		#nearestItem.focus()	
		#Globals.FurnitureHighlighted = true
	#
#func PickupNearestItem():
	#var nearestItem: InteractableItem = FindNearestItem()
	## remove item from view
	#if (nearestItem != null):
		#nearestItem.destroy()
		#NearbyBodies.remove_at(NearbyBodies.find(nearestItem))
		#var itemPrefab = nearestItem.scene_file_path
	
