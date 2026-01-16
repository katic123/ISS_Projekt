extends DirectionalLight3D

@export var sun_speed: float = 0.7  # degrees per second (slow)

func _ready():
	# Morning position
	rotation_degrees = Vector3(-15, 45, 0)

func _process(delta):
	# Move sun slowly across the sky
	rotation_degrees.x -= sun_speed * delta
