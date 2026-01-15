extends Node3D

@onready var launcher_camera = $LauncherCamera  
@onready var missile_camera = $RocketPlayer/MissleCamera  
@onready var tank = $Tank
@onready var arrow = $Arrow
@onready var rocket= $RocketPlayer
var radius=50
func _ready():
	launcher_camera.position = rocket.position+Vector3(0,2,2)
	var distance = 500  
	var random_angle = randf_range(0, 2 * PI)
	
	tank.position.x = rocket.position.x + cos(random_angle) * distance
	tank.position.z = rocket.position.z + sin(random_angle) * distance
	launcher_camera.current = true
	missile_camera.current = false
	
	
func _physics_process(delta):
	arrow.position=tank.position
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		var launcher_on = launcher_camera.current
		launcher_camera.current = !launcher_on
		missile_camera.current = launcher_on
		
