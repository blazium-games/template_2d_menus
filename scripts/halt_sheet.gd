extends Control

# Pause menu. Instance it over a play scene. Copy this scene and this script together.
# Save, load, pause, and confirm also need scripts/slot_rules.gd.
# Settings also needs scripts/prefs_rules.gd.

const SlotRules = preload("res://scripts/slot_rules.gd")
const PrefsRules = preload("res://scripts/prefs_rules.gd")
const CHOICES: PackedStringArray = ["Resume", "Settings", "Save", "Quit"]
const FRONT := "res://scenes/menus/front_sheet.tscn"
const PLAY := "res://scenes/play_stage.tscn"
const HALT := "res://scenes/menus/halt_sheet.tscn"
const PREFS := "res://scenes/menus/prefs_sheet.tscn"
const THANKS := "res://scenes/menus/thanks_sheet.tscn"
const KEEP := "res://scenes/menus/keep_sheet.tscn"
const RECALL := "res://scenes/menus/recall_sheet.tscn"
const CONFIRM := "res://scenes/menus/confirm_sheet.tscn"

var slots: RefCounted
var prefs: RefCounted
var index := 0
var notice := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	slots = SlotRules.new()
	prefs = PrefsRules.new()
	_boot_prefs()
	var lens : Node = get_node_or_null("SheetLens")
	if lens is Camera2D:
		(lens as Camera2D).make_current()
	var rows : Node = get_node_or_null("Rows")
	if rows != null:
		for child in rows.get_children():
			if child is Button:
				child.pressed.connect(_on_pressed.bind(child.name))
	_prepare()
	if _row_disabled(CHOICES[index]):
		_step(1)
	else:
		_refresh()

func _on_pressed(choice: String) -> void:
	var found := CHOICES.find(choice)
	if found >= 0:
		index = found
	_activate(choice)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("stride_north"):
		_step(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("stride_south"):
		_step(1)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		return
	elif event.is_action_pressed("primary"):
		_activate(CHOICES[index])
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("halt"):
		_halt_choice()
		get_viewport().set_input_as_handled()

func _refresh() -> void:
	var rows : Node = get_node_or_null("Rows")
	if rows != null:
		for i in CHOICES.size():
			var choice := CHOICES[i]
			var button : Node = rows.get_node_or_null(choice)
			if button is Button:
				button.text = _caption(choice)
				button.disabled = _row_disabled(choice)
				if button.disabled:
					button.modulate = Color(0.45, 0.45, 0.45)
				elif i == index:
					button.modulate = Color(1, 0.86, 0.4)
				else:
					button.modulate = Color(1, 1, 1)
	var note : Node = get_node_or_null("Notice")
	if note is Label:
		note.text = notice
func _boot_prefs() -> void:
	prefs.recall_prefs()
	_push_guard()
	_apply_window()

func _push_guard() -> void:
	var guard: Node = get_node_or_null("/root/BootGuard")
	if guard != null:
		guard.set_loudness(prefs.loudness)

func _apply_window() -> void:
	if OS.has_feature("headless") or DisplayServer.get_name() == "headless":
		return
	var mode := DisplayServer.WINDOW_MODE_WINDOWED
	if prefs.fullscreen:
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	if DisplayServer.window_get_mode() == mode:
		return
	DisplayServer.window_set_mode(mode)

func _step(delta: int) -> void:
	var guard := 0
	while guard < CHOICES.size():
		index = _wrap(index + delta, CHOICES.size())
		if not _row_disabled(CHOICES[index]):
			break
		guard += 1
	_refresh()

func _wrap(value: int, size: int) -> int:
	var mod := value % size
	if mod < 0:
		mod += size
	return mod

func _go(next_path: String) -> void:
	if get_tree().paused:
		get_tree().paused = false
	get_tree().change_scene_to_file(next_path)

func _handoff(next_path: String) -> void:
	var host := get_parent()
	if SlotRules.from_pause and host != null and host.has_method("open_overlay"):
		host.open_overlay(next_path)
		return
	_go(next_path)

func _leave() -> void:
	var host := get_parent()
	if SlotRules.from_pause and host != null and host.has_method("open_overlay"):
		var back := SlotRules.return_scene
		if back == "":
			back = HALT
		host.open_overlay(back)
		return
	var back_path := SlotRules.back_scene
	if back_path == "":
		back_path = FRONT
	_go(back_path)

func _after_confirm() -> void:
	var host := get_parent()
	if SlotRules.from_pause and host != null and host.has_method("open_overlay"):
		var back := SlotRules.confirm_return
		if back == "":
			back = SlotRules.return_scene
		if back == "":
			back = HALT
		host.open_overlay(back)
		return
	var back_path := SlotRules.back_scene
	if back_path == "":
		back_path = FRONT
	_go(back_path)

func _loudness() -> float:
	var guard: Node = get_node_or_null("/root/BootGuard")
	if guard != null and "loudness" in guard:
		return float(guard.loudness)
	return prefs.loudness

func _seconds() -> int:
	var host := get_parent()
	if host != null and host.has_method("played_seconds"):
		return int(host.played_seconds())
	return 0

func _slot_index(choice: String) -> int:
	if not choice.begins_with("Slot"):
		return -1
	return int(choice.substr(4))

func _halt_choice() -> void:
	if CHOICES.find("Back") >= 0:
		_activate("Back")
	elif CHOICES.find("Resume") >= 0:
		_activate("Resume")
	elif CHOICES.find("No") >= 0:
		_activate("No")
	else:
		_activate("Quit")
func _activate(choice: String) -> void:
	var host := get_parent()
	if choice == "Resume":
		if host != null and host.has_method("close_overlay"):
			host.close_overlay()
		else:
			if get_tree().paused:
				get_tree().paused = false
			queue_free()
	elif choice == "Settings":
		SlotRules.from_pause = true
		SlotRules.return_scene = HALT
		if host != null and host.has_method("open_overlay"):
			host.open_overlay(PREFS)
	elif choice == "Save":
		SlotRules.from_pause = true
		SlotRules.return_scene = HALT
		if host != null and host.has_method("open_overlay"):
			host.open_overlay(KEEP)
	elif choice == "Quit":
		SlotRules.confirm_kind = "quit"
		SlotRules.from_pause = true
		SlotRules.return_scene = HALT
		SlotRules.confirm_return = HALT
		if host != null and host.has_method("open_overlay"):
			host.open_overlay(CONFIRM)

func _prepare() -> void:
	pass

func _caption(choice: String) -> String:
	return choice

func _row_disabled(_choice: String) -> bool:
	return false

