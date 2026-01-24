extends Node3D

@export var move_speed: float = 1.0
@export var rotation_speed: float = 0.4
@export var tilt_smoothness: float = 5.0 
var previous_terrain_normal: Vector3 = Vector3(0,1,0)
var random_count=0;
var random = randi_range(1000,2000)
func _ready():
	rotation_degrees.y = randf_range(0, 0)
	snap_to_terrain()

func _physics_process(delta):

	var forward_direction = transform.basis. z
	if random_count<int(random/2):
		rotation_degrees.y+=randf_range(0,rotation_speed)
	if random_count>=int(random/2):
		rotation_degrees.y+=randf_range(-rotation_speed,0)
	if(random_count==random):
		random_count=0
	random_count+=1
	forward_direction.y = 0
	global_position += forward_direction.normalized() * move_speed * delta
	var terrain_info = get_terrain_info()
	
	if terrain_info:
		global_position.y = terrain_info.position.y + 1.0
		tilt_to_normal(terrain_info.normal, delta)

func get_terrain_info():
	var space = get_world_3d().direct_space_state
	var ray_start = global_position + Vector3(0,1,0) * 10
	var ray_end = global_position + Vector3(0,-1,0) * 10000
	
	var result = space.intersect_ray(PhysicsRayQueryParameters3D.create(ray_start, ray_end))
	
	return result

func tilt_to_normal(terrain_normal: Vector3, delta: float):
	previous_terrain_normal = previous_terrain_normal.lerp(terrain_normal, tilt_smoothness * delta).normalized()
	
	var current_forward = transform.basis.z
	var current_right = transform.basis.x
	var new_up = previous_terrain_normal
	
	var new_right = current_right - new_up * current_right.dot(new_up)
	new_right = new_right.normalized()
	var new_forward = new_up.cross(new_right).normalized()
	
	transform.basis = Basis(new_right, new_up, new_forward)

func snap_to_terrain():
	var terrain_info = get_terrain_info()
	if terrain_info:
		global_position.y = terrain_info.position.y + 100
		previous_terrain_normal = terrain_info.normal
