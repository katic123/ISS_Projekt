extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node):
	if body.is_in_group("rocket"):
		print("rocket entered tank area3d")
		call_deferred("destroy_tank", body)

func destroy_tank(rocket: Node):
	var tank = get_parent()
	
	
	tank.visible = false
	disable_tank_collisions(tank)
	print("tank destroyed")
	
	if rocket.has_method("restart_rocket"):
		rocket.restart_rocket()

func disable_tank_collisions(node: Node):
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0
		if node is Area3D:
			node.monitoring = false
			node.monitorable = false
	for child in node.get_children():
		disable_tank_collisions(child)
