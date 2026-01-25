extends CharacterBody3D
signal collision 
# =========================================================
# PHYSICAL PARAMETERS (DYNAMICS MODEL)
# =========================================================
@export var mass: float = 30.0                 # kg
@export var thrust_force: float = 10000.0        # N
@export var drag_coeff: float = 0.4            # aerodynamic drag
@export var gravity: float = 9.8               # m/s^2
@export var substeps: int = 5                  # integration stability
var time: float = 0.0
# =========================================================
# CONTROL PARAMETERS (ATTITUDE)
# =========================================================
@export var turn_speed: float = 70.0            # deg/s
@export var max_pitch: float = 85.0             # deg

# =========================================================
# STATE VARIABLES
# =========================================================
var pitch_angle: float = 45.0                  # deg
var yaw_angle: float = 0.0                     # deg
var roll_angle: float = 0.0                    # deg

var start: bool = false
var start_position: Vector3

# =========================================================
# SPHERE SPAWNING VARIABLES
# =========================================================
var sphere_spawn_timer: float = 0.0
const SPHERE_SPAWN_INTERVAL: float = 0.01 
const SPHERE_LIFETIME: float = 1.0  

var spawned_spheres: Array = []

# =========================================================
# INITIALIZATION
# =========================================================
func _ready():
	# Set random position
	position.x = randf_range(-100, 100)
	position.y = 1000
	position.z = randf_range(-100, 100)
	
	# Adjust position based on terrain
	var terrain_info = get_terrain_info()
	if terrain_info:
		position.y = terrain_info.position.y + 3
	
	start_position = global_position
	rotation_degrees = Vector3(pitch_angle, yaw_angle, roll_angle)
	add_to_group("rocket")  

# =========================================================
# MAIN LOOP
# =========================================================
func _physics_process(delta: float) -> void:
	# -------------------------
	# START / STOP
	# -------------------------
	if Input.is_action_just_pressed("ui_accept"):
		start = !start
		if not start:
			reset_rocket()
		else:
			# Play rocket fire sound when starting
			if velocity == Vector3.ZERO:
				$SoundRocketFire.play()

	# -------------------------
	# MANUAL ATTITUDE CONTROL
	# -------------------------
	if Input.is_action_pressed("ui_left"):
		yaw_angle += turn_speed * delta
	elif Input.is_action_pressed("ui_right"):
		yaw_angle -= turn_speed * delta

	if Input.is_action_pressed("ui_up"):
		pitch_angle += turn_speed * delta
	elif Input.is_action_pressed("ui_down"):
		pitch_angle -= turn_speed * delta

	pitch_angle = clamp(pitch_angle, -max_pitch, max_pitch)

	rotation_degrees = Vector3(pitch_angle, yaw_angle, roll_angle)

	# -------------------------
	# FORCE-BASED DYNAMICS
	# -------------------------
	if start:
		# Play flying sound
		if not $SoundRocketFly.playing:
			$SoundRocketFly.play()
		
		# Handle sphere spawning
		sphere_spawn_timer += delta
		if sphere_spawn_timer >= SPHERE_SPAWN_INTERVAL:
			spawn_sphere()
			sphere_spawn_timer = 0.0
		
		var sub_dt := delta / substeps

		for i in range(substeps):
			# Missile forward direction (body axis)
			var forward := -transform.basis.z.normalized()

			# Forces
			var thrust := thrust_force * forward
			var drag := -drag_coeff * velocity.length() * velocity
			var gravity_force := Vector3.DOWN * gravity * mass

			var total_force := thrust + drag + gravity_force

			# Newton's 2nd law
			var accel := total_force / mass

			# Integrate ODEs
			velocity += accel * sub_dt

			var collision = move_and_collide(velocity * sub_dt)
			if collision:
				# Play explosion sound on collision
				match randi_range(0, 2):
					0: 
						%SoundRocketExplode1.play()
					1:
						%SoundRocketExplode2.play()
					2:
						%SoundRocketExplode3.play()
				restart_rocket()
				emit_signal("collision")
				break
	else:
		velocity = Vector3.ZERO
		# Stop flying sound when not active
		if $SoundRocketFly.playing:
			$SoundRocketFly.stop()
	
	# Clean up old spheres
	cleanup_spheres()

# =========================================================
# SPHERE SPAWNING FUNCTIONS
# =========================================================
func spawn_sphere():
	var sphere = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	sphere.mesh.radius = 1 
	sphere.mesh.height = 2.0  
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 0, 0)  
	sphere.material_override = material
	
	sphere.position = position
	get_parent().add_child(sphere)
	
	spawned_spheres.append({
		"node": sphere,
		"creation_time": Time.get_ticks_msec()
	})

func cleanup_spheres():
	var current_time = Time.get_ticks_msec()
	var spheres_to_remove: Array = []
	
	for i in range(spawned_spheres.size() - 1, -1, -1):
		var sphere_data = spawned_spheres[i]
		var sphere_age = (current_time - sphere_data["creation_time"]) / 1000.0  # Convert to seconds
		
		if sphere_age >= SPHERE_LIFETIME:
			if is_instance_valid(sphere_data["node"]):
				sphere_data["node"].queue_free()
			spheres_to_remove.append(i)
	
	for index in spheres_to_remove:
		spawned_spheres.remove_at(index)

# =========================================================
# RESET / RESTART
# =========================================================
func restart_rocket():
	start = false
	time = 0.0
	sphere_spawn_timer = 0.0
	
	# Stop sounds
	if $SoundRocketFly.playing:
		$SoundRocketFly.stop()
	
	reset_rocket()

func reset_rocket():
	pitch_angle = 45.0
	yaw_angle = 0.0
	roll_angle = 0.0
	velocity = Vector3.ZERO
	global_position = start_position
	rotation_degrees = Vector3(pitch_angle, yaw_angle, roll_angle)
	print("Resetting to:", start_position)
	
	# Clean up all spheres when rocket resets
	for sphere_data in spawned_spheres:
		if is_instance_valid(sphere_data["node"]):
			sphere_data["node"].queue_free()
	spawned_spheres.clear()

func _exit_tree():
	# Clean up spheres when rocket is destroyed
	for sphere_data in spawned_spheres:
		if is_instance_valid(sphere_data["node"]):
			sphere_data["node"].queue_free()

# =========================================================
# TERRAIN DETECTION
# =========================================================
func get_terrain_info():
	var space = get_world_3d().direct_space_state
	var ray_start = global_position + Vector3(0, 1, 0) * 10
	var ray_end = global_position + Vector3(0, -1, 0) * 10000
	var result = space.intersect_ray(PhysicsRayQueryParameters3D.create(ray_start, ray_end))
	return result

# =========================================================
# STATE OUTPUT (OPTION A / D COMPATIBILITY)
# =========================================================
func get_state() -> Dictionary:
	return {
		"x": global_position.x,
		"y": global_position.y,
		"z": global_position.z,
		"pitch": pitch_angle,
		"yaw": yaw_angle,
		"roll": roll_angle
	}
