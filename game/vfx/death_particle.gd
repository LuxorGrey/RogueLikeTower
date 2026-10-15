extends GPUParticles2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if process_material is ShaderMaterial:
		process_material = (process_material as ShaderMaterial).duplicate(true)
	emitting = false
	visible = false
