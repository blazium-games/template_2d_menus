extends Node2D

# Play scene for the pause menu. Not a game.
# Halt opens the pause scene over this node.

const SlotRules = preload("res://scripts/slot_rules.gd")
const PrefsRules = preload("res://scripts/prefs_rules.gd")
const HALT := "res://scenes/menus/halt_sheet.tscn"

var slots: RefCounted
var prefs: RefCounted
var overlay: Node = null
var elapsed := 0.0

func _ready() -> void:
	slots = SlotRules.new()
	prefs = PrefsRules.new()
	prefs.recall_prefs()
	var guard: Node = get_node_or_null("/root/BootGuard")
	if guard != null:
		guard.set_loudness(prefs.loudness)
	elapsed = float(SlotRules.resume_seconds)
	SlotRules.resume_seconds = 0
	SlotRules.from_pause = false
	if get_tree().paused:
		get_tree().paused = false
	var lens : Node = get_node_or_null("SheetLens")
	if lens is Camera2D:
		(lens as Camera2D).make_current()
func _process(delta: float) -> void:
	elapsed += delta
	var readout : Node = get_node_or_null("SecondsReadout")
	if readout is Label:
		readout.text = "Seconds %d" % int(elapsed)
func played_seconds() -> int:
	return int(elapsed)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("halt"):
		return
	if overlay != null and is_instance_valid(overlay):
		return
	SlotRules.from_pause = true
	SlotRules.return_scene = HALT
	open_overlay(HALT)
	get_viewport().set_input_as_handled()

func open_overlay(next_path: String) -> void:
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null
	overlay = load(next_path).instantiate()
	add_child(overlay)
	if get_tree() != null:
		get_tree().paused = true

func close_overlay() -> void:
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null
	SlotRules.from_pause = false
	if get_tree() != null:
		get_tree().paused = false
