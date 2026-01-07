extends CharacterBody3D

@export var max_speed: float = 185.0
@export var turn_speed: float = 70.0  
@export var acceleration: float = 200.0
@export var gravity: float = 9.8
@export var substeps: int = 4



var pitch_angle: float = 0.0  
var yaw_angle: float = 0.0  
var time: float = 0.0
var start: bool = false

func _ready():
	rotation_degrees.x = 45.0
	rotation_degrees.y = 0.0
	pitch_angle = 45.0 
	add_to_group("rocket")  

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		start = !start
		if not start:
			reset_rocket()
	
	if Input.is_action_pressed("ui_left"): 
		yaw_angle += turn_speed * delta
	
	elif Input.is_action_pressed("ui_right"):  
		yaw_angle -= turn_speed * delta
	
	if Input.is_action_pressed("ui_up"):  
		pitch_angle += turn_speed * delta
		
	elif Input.is_action_pressed("ui_down"):  
		pitch_angle -= turn_speed * delta
	
	rotation_degrees.x = pitch_angle  
	rotation_degrees.y = yaw_angle    
	
	if start:
		var substep_delta = delta / substeps
		
		for i in range(substeps):
			var propulsion = -transform.basis.z * min(acceleration * time, max_speed)
			
			velocity = propulsion - Vector3(0, gravity * time, 0)
			
			var collision = move_and_collide(velocity * substep_delta)
			
			if collision:
				restart_rocket()
				break 
			
			time += substep_delta
	else: 
		velocity = Vector3.ZERO


func restart_rocket(): 
	start = false
	time = 0.0
	reset_rocket()

func reset_rocket():
	rotation_degrees.x = 45.0
	rotation_degrees.y = 0.0
	pitch_angle = 45.0
	yaw_angle = 0.0
	time = 0.0
	velocity = Vector3.ZERO
	position = Vector3(0, 7, 0)
