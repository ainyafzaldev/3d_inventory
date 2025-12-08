extends CharacterBody3D
# camera movements from youtube tut by bramwell 

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity := 0.001
var vertical_input := 0.0 # pitch
var horizontal_input := 0.0 #twist

@onready var horizontal_pivot := $HorizontalPivot
@onready var vertical_pivot := $HorizontalPivot/VerticalPivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			horizontal_input = - event.relative.x * mouse_sensitivity
			vertical_input = - event.relative.y * mouse_sensitivity
			horizontal_pivot.rotate_y(horizontal_input)
			rotate_y(deg_to_rad(-event.relative.x) * 0.5)
			vertical_pivot.rotate_x(vertical_input)
			vertical_pivot.rotation.x = clamp(
				vertical_pivot.rotation.x,
				deg_to_rad(-30),
				deg_to_rad(30)
			)
		vertical_input = 0.0
		horizontal_input = 0.0
		
func _physics_process(delta: float) -> void:
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
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
