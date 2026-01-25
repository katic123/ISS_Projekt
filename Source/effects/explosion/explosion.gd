extends Node3D

@onready var debris: GPUParticles3D = $Debris
@onready var fire: GPUParticles3D = $Fire
@onready var smoke: GPUParticles3D = $Smoke
@onready var explosion_sound: AudioStreamPlayer3D = $ExplosionSound
@onready var exploded=false
func _ready() -> void:
	debris.emitting = false
	fire.emitting = false
	smoke.emitting = false

func explode ():
	exploded=true
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	explosion_sound.play()
	await get_tree().create_timer(4.0).timeout
	queue_free()
	
