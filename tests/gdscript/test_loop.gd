extends AutoworkTest

const SlotRules = preload("res://scripts/slot_rules.gd")
const PrefsRules = preload("res://scripts/prefs_rules.gd")

func _slots() -> RefCounted:
	var rules = SlotRules.new()
	rules.root_dir = "user://menu_slots_autowork_2d"
	rules.wipe_slots()
	return rules

func test_slot_index_reject() -> void:
	var rules = _slots()
	assert_false(rules.slot_ok(0), "zero rejected")
	assert_true(rules.slot_ok(1), "first slot")
	assert_true(rules.slot_ok(3), "third slot")
	assert_false(rules.slot_ok(4), "fourth rejected")
	assert_eq(rules.write_slot(0, 0.5, 1, false, false), "bad_index", "bad index")
	assert_eq(rules.write_slot(1, 1.4, 1, false, false), "bad_loudness", "loudness high")
	assert_eq(rules.write_slot(1, -0.1, 1, false, false), "bad_loudness", "loudness low")
	assert_eq(rules.write_slot(1, 0.4, -2, false, false), "bad_seconds", "negative seconds")

func test_overwrite_needs_confirm() -> void:
	var rules = _slots()
	assert_false(rules.may_overwrite(true, false), "occupied needs confirm")
	assert_true(rules.may_overwrite(true, true), "confirm allows overwrite")
	assert_true(rules.may_overwrite(false, false), "empty slot writes")
	assert_eq(rules.write_slot(1, 0.5, 1, true, false), "needs_confirm", "write blocked")
	assert_false(rules.may_load(rules.read_slot(1)), "nothing stored")
	assert_eq(rules.write_slot(1, 0.5, 4, true, true), "kept", "confirm writes")
	assert_true(rules.may_load(rules.read_slot(1)), "stored body loads")

func test_missing_and_bad_version() -> void:
	var rules = _slots()
	assert_false(rules.may_load({}), "empty body rejected")
	assert_eq(rules.newest_index(), -1, "continue has no slot")
	assert_eq(rules.write_slot(2, 0.4, 3, false, false), "kept", "seed slot")
	var file = FileAccess.open(rules.slot_path(2), FileAccess.WRITE)
	file.store_string("{\"version\": 9, \"loudness\": 0.2, \"seconds\": 3}")
	file.close()
	assert_false(rules.may_load(rules.read_slot(2)), "old version rejected")
	assert_eq(rules.newest_index(), -1, "bad version is not continue")

func test_newest_slot() -> void:
	var rules = _slots()
	assert_eq(rules.write_slot(1, 0.4, 2, false, false), "kept", "slot one")
	assert_eq(rules.write_slot(3, 0.6, 9, false, false), "kept", "slot three")
	assert_eq(rules.newest_index(), 3, "newer seconds win")
	var body = rules.read_slot(3)
	assert_almost_eq(float(body["loudness"]), 0.6, 0.001, "loudness roundtrip")
	assert_eq(int(body["seconds"]), 9, "seconds roundtrip")
	rules.wipe_slots()
	assert_eq(rules.newest_index(), -1, "wipe clears continue")

func test_prefs_roundtrip() -> void:
	var prefs = PrefsRules.new()
	prefs.prefs_path = "user://menu_prefs_autowork_2d.cfg"
	prefs.wipe_prefs()
	assert_false(prefs.set_loudness(-0.01), "below zero rejected")
	assert_false(prefs.set_loudness(1.01), "above one rejected")
	assert_true(prefs.set_loudness(0.3), "mid loudness")
	prefs.set_fullscreen(true)
	assert_true(prefs.store_prefs(), "prefs stored")
	var again = PrefsRules.new()
	again.prefs_path = prefs.prefs_path
	assert_true(again.recall_prefs(), "prefs loaded")
	assert_almost_eq(again.loudness, 0.3, 0.001, "loudness kept")
	assert_true(again.fullscreen, "fullscreen kept")
	again.wipe_prefs()
	assert_false(again.recall_prefs(), "wiped prefs miss")

func test_menu_scenes_load() -> void:
	var rows = [
		["res://scenes/menus/front_sheet.tscn", "Control"],
		["res://scenes/menus/halt_sheet.tscn", "Control"],
		["res://scenes/menus/prefs_sheet.tscn", "Control"],
		["res://scenes/menus/thanks_sheet.tscn", "Control"],
		["res://scenes/menus/keep_sheet.tscn", "Control"],
		["res://scenes/menus/recall_sheet.tscn", "Control"],
		["res://scenes/menus/confirm_sheet.tscn", "Control"],
		["res://scenes/play_stage.tscn", "Node2D"],
	]
	for row in rows:
		var packed = load(row[0])
		assert_true(packed != null, row[0])
		var node = packed.instantiate()
		assert_eq(node.get_class(), row[1], row[0])
		assert_true(node.get_script() != null, row[0])
		var lens = node.get_node_or_null("SheetLens")
		assert_true(lens is Camera2D, row[0])
		node.free()

func test_may_quit() -> void:
	assert_false(SlotRules.may_quit(false), "front sheet")
	assert_true(SlotRules.may_quit(true), "confirmed")
