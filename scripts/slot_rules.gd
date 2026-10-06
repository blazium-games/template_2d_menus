extends RefCounted

const VERSION := 1
const SLOT_MIN := 1
const SLOT_MAX := 3

static var confirm_kind: String = ""
static var confirm_slot: int = 0
static var confirm_loudness: float = 0.8
static var confirm_seconds: int = 0
static var confirm_return: String = ""
static var from_pause: bool = false
static var return_scene: String = ""
static var back_scene: String = ""
static var resume_seconds: int = 0

var root_dir := "user://menu_slots"

static func clear_route() -> void:
	confirm_kind = ""
	confirm_slot = 0
	confirm_loudness = 0.8
	confirm_seconds = 0
	confirm_return = ""
	from_pause = false
	return_scene = ""
	back_scene = ""
	resume_seconds = 0

func slot_ok(index: int) -> bool:
	return index >= SLOT_MIN and index <= SLOT_MAX

func slot_path(index: int) -> String:
	return "%s/slot_%d.json" % [root_dir, index]

func pack_body(loudness: float, seconds: int) -> Dictionary:
	return {"version": VERSION, "loudness": loudness, "seconds": seconds}

static func may_quit(confirmed: bool) -> bool:
	return confirmed

func may_overwrite(occupied: bool, confirmed: bool) -> bool:
	if not occupied:
		return true
	return confirmed

func may_load(body: Dictionary) -> bool:
	if body.is_empty():
		return false
	return int(body.get("version", -1)) == VERSION

func write_slot(index: int, loudness: float, seconds: int, occupied: bool, confirmed: bool) -> String:
	if not slot_ok(index):
		return "bad_index"
	if loudness < 0.0 or loudness > 1.0:
		return "bad_loudness"
	if seconds < 0:
		return "bad_seconds"
	if not may_overwrite(occupied, confirmed):
		return "needs_confirm"
	var absolute := ProjectSettings.globalize_path(root_dir)
	var made := DirAccess.make_dir_recursive_absolute(absolute)
	if made != OK and made != ERR_ALREADY_EXISTS:
		return "write_failed"
	var file := FileAccess.open(slot_path(index), FileAccess.WRITE)
	if file == null:
		return "write_failed"
	file.store_string(JSON.stringify(pack_body(loudness, seconds)))
	file.close()
	return "kept"

func read_slot(index: int) -> Dictionary:
	if not slot_ok(index):
		return {}
	if not FileAccess.file_exists(slot_path(index)):
		return {}
	var file := FileAccess.open(slot_path(index), FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func newest_index() -> int:
	var best := -1
	var best_seconds := -1
	for index in range(SLOT_MIN, SLOT_MAX + 1):
		var body := read_slot(index)
		if not may_load(body):
			continue
		var seconds := int(body.get("seconds", 0))
		if seconds >= best_seconds:
			best_seconds = seconds
			best = index
	return best

func wipe_slots() -> void:
	for index in range(SLOT_MIN, SLOT_MAX + 1):
		var path := slot_path(index)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
