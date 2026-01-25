extends Camera3D

@export var mouse_sensitivity := 0.002

@export var zoom_speed := 5.0 
@export var min_fov := 2.0    
@export var max_fov := 90.0    

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity*fov/max_fov)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity*fov/max_fov)
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov = clamp(fov - zoom_speed, min_fov, max_fov)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov = clamp(fov + zoom_speed, min_fov, max_fov)
	
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_capture()
func toggle_mouse_capture():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
