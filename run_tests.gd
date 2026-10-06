extends SceneTree

func _initialize() -> void:
	if not ClassDB.class_exists("Autowork"):
		push_error("Autowork module is required (Blazium editor with module_autowork_enabled=yes)")
		quit(1)
		return
	var autowork = ClassDB.instantiate("Autowork")
	root.add_child(autowork)
	if ClassDB.class_exists("AutoworkConfig"):
		var cfg = ClassDB.instantiate("AutoworkConfig")
		cfg.load_options("res://.autoworkconfig.json")
		cfg.apply_options(autowork)
	autowork.add_directory("res://tests/gdscript", "test_", ".gd")
	autowork.run_tests()
	var fails: int = autowork.get_fail_count()
	print("Autowork done: pass=%d fail=%d pending=%d" % [
		autowork.get_pass_count(), fails, autowork.get_pending_count()
	])
	quit(fails)
