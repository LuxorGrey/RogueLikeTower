extends Node2D

const DEATH_PARTICLE_SCENE: PackedScene = preload("res://game/vfx/death_particle.tscn")

var _available_particles: Array[GPUParticles2D] = []
var _white_pixel: Texture2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_white_pixel = _create_white_pixel_texture()

func emit_death_particles_at(coords: Vector2, sprite: Sprite2D) -> void:
	if sprite == null or not is_instance_valid(sprite) or sprite.texture == null:
		return
	var texture: Texture2D = sprite.texture
	if texture.get_width() <= 0 or texture.get_height() <= 0:
		return
	var particles: GPUParticles2D = _get_particles()
	if particles == null:
		return
	var process_material := particles.process_material as ShaderMaterial
	if process_material == null:
		return

	particles.global_position = coords
	particles.scale = sprite.scale
	particles.amount = texture.get_width() * texture.get_height()
	particles.texture = _white_pixel
	process_material.set_shader_parameter("sprite", texture)
	process_material.set_shader_parameter("sprite_frame", sprite.frame)
	process_material.set_shader_parameter("sprite_hframes", sprite.hframes)
	process_material.set_shader_parameter("sprite_vframes", sprite.vframes)
	process_material.set_shader_parameter("sprite_flip_h", sprite.flip_h)
	process_material.set_shader_parameter("sprite_modulate", sprite.modulate)
	particles.visible = true
	particles.emitting = false
	particles.restart()
	particles.emitting = true

func _get_particles() -> GPUParticles2D:
	while not _available_particles.is_empty():
		var candidate: GPUParticles2D = _available_particles.pop_back()
		if is_instance_valid(candidate):
			return candidate
	var particles := DEATH_PARTICLE_SCENE.instantiate() as GPUParticles2D
	if particles == null:
		return null
	add_child(particles)
	particles.finished.connect(_on_particles_finished.bind(particles))
	return particles

func _on_particles_finished(particles: GPUParticles2D) -> void:
	if not is_instance_valid(particles) or _available_particles.has(particles):
		return
	particles.emitting = false
	particles.visible = false
	particles.scale = Vector2.ONE
	particles.position = Vector2.ZERO
	_available_particles.append(particles)

func _create_white_pixel_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
