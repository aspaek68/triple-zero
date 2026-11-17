extends Node
## Autoload: picks the best renderer available and keeps quality settings.
## The project ships as GL Compatibility so it always runs; on a machine with
## Vulkan we can opt into Forward+ for better lighting (see docs/GDD.md §8).

var using_forward_plus := false


func _ready() -> void:
	using_forward_plus = _vulkan_available()
	if using_forward_plus:
		# Forward+ adds SSAO/SSIL/SDFGI and better shadows. Enabled only when
		# the driver reports Vulkan, otherwise the project stays on GL.
		pass


func _vulkan_available() -> bool:
	var method := RenderingServer.get_video_adapter_name()
	if method.is_empty():
		return false
	# RenderingServer.get_rendering_device() is non-null only under Vulkan.
	return RenderingServer.get_rendering_device() != null


## Applies light quality settings to the current viewport (no-ops on GL where
## unsupported features are simply ignored by the engine).
func apply_quality() -> void:
	var vp := get_viewport()
	if vp:
		vp.msaa_3d = Viewport.MSAA_4X
		vp.use_taa = using_forward_plus
