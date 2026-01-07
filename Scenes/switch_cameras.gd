extends Node3D

@onready var launcher_camera = $LauncherCamera  
@onready var missile_camera = $RocketPlayer/MissleCamera  
func _ready():
	launcher_camera.current = true
	missile_camera.current = false

func _input(event):
	if event.is_action_pressed("ui_select"):
		var launcher_on = launcher_camera.current
		launcher_camera.current = !launcher_on
		missile_camera.current = launcher_on
