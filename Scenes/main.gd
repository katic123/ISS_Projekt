extends Node3D

@onready var launcher_camera = $LauncherCamera  
@onready var missile_camera = $RocketPlayer/MissleCamera  
@onready var tank_camera = $Tank/TankCamera 
@onready var tank = $Tank
@onready var arrow = $Arrow
@onready var rocket= $RocketPlayer  
@onready var explosion= $Explosion 
@export var slowmo_scale: float = 0.40
var slowmo_enabled: bool = false
var distance = 600
func _ready():
	launcher_camera.position = rocket.position+Vector3(0,2,2)
	
	var random_angle = randf_range(0, 2 * PI)
	
	tank.position.x = rocket.position.x + cos(random_angle) * distance
	tank.position.z = rocket.position.z + sin(random_angle) * distance
	launcher_camera.current = true
	missile_camera.current = false
	
	
func _physics_process(delta):
	
	arrow.position=tank.position
	if(explosion):
		explosion.position=tank.position
	if(tank.visible==false):
		tank_camera.current=true
		tank.move_speed= 0
		tank.rotation_speed=0
		arrow.visible=false
		if(explosion):
			if(explosion.exploded==false):
				explosion.explode()
	
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		var launcher_on = launcher_camera.current
		launcher_camera.current = !launcher_on
		missile_camera.current = launcher_on
		
	# SLOW MOTION TOGGLE
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			slowmo_enabled = !slowmo_enabled
			Engine.time_scale = slowmo_scale if slowmo_enabled else 1.0
