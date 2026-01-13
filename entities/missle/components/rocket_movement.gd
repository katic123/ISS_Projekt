extends CharacterBody3D

# =========================================================
# PHYSICAL PARAMETERS (DYNAMICS MODEL)
# =========================================================
@export var mass: float = 10.0                 # kg
@export var thrust_force: float = 5000.0        # N
@export var drag_coeff: float = 0.4            # aerodynamic drag
@export var gravity: float = 9.8               # m/s^2
@export var substeps: int = 5                  # integration stability

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
var roll_angle: float = 0.0                    # deg (unused)

var start: bool = false

# =========================================================
# INITIALIZATION
# =========================================================
func _ready():
	reset_rocket()
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
				restart_rocket()
				break
	else:
		velocity = Vector3.ZERO

# =========================================================
# RESET / RESTART
# =========================================================
func restart_rocket():
	start = false
	reset_rocket()

func reset_rocket():
	pitch_angle = 45.0
	yaw_angle = 0.0
	roll_angle = 0.0
	velocity = Vector3.ZERO
	global_position = Vector3(0, 7, 0)
	rotation_degrees = Vector3(pitch_angle, yaw_angle, roll_angle)

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
