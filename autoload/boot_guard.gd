extends Node

const REQUIRED: PackedStringArray = ["stride_west", "stride_east", "stride_north", "stride_south", "leap", "halt", "primary"]
const USE_3D := false

var halted := false
var loudness := 0.8

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("halt"):
		toggle_halt()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	_check_actions()
	apply_loudness()
	await get_tree().process_frame
	if not view_current():
		push_error("No current camera. Add one and mark it current before shipping a build.")

func view_current() -> bool:
	if USE_3D:
		return get_viewport().get_camera_3d() != null
	return get_viewport().get_camera_2d() != null

func _check_actions() -> void:
	for action in REQUIRED:
		if not InputMap.has_action(action):
			push_error("Missing input action: %s" % action)

func set_loudness(value: float) -> bool:
	if value < 0.0 or value > 1.0:
		return false
	loudness = value
	apply_loudness()
	return true

func apply_loudness() -> void:
	if not is_inside_tree():
		return
	var idx := AudioServer.get_bus_index("Master")
	if idx < 0:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(loudness, 0.0001, 1.0)))

func toggle_halt() -> bool:
	halted = not halted
	if get_tree() != null:
		get_tree().paused = halted
	return halted
