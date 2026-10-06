extends AutoworkTest

func test_loudness_range() -> void:
	var guard = load("res://autoload/boot_guard.gd").new()
	assert_false(guard.set_loudness(-0.01), "below zero rejected")
	assert_false(guard.set_loudness(1.01), "above one rejected")
	assert_true(guard.set_loudness(0.4), "mid volume kept")
	assert_almost_eq(guard.loudness, 0.4, 0.001, "stored loudness")
	guard.free()

func test_launch_ids_and_clamps() -> void:
	var events = load("res://autoload/launch_events.gd").new()
	assert_false(events.ids_ready(), "empty ids do not post")
	assert_eq(events.clamp_span_ms(700000), 600000, "ms cap")
	assert_eq(events.clamp_span_ms(-4), 0, "ms floor")
	assert_eq(events.clamp_span_sec(90000), 86400, "seconds cap")
	assert_eq(events.clamp_span_sec(-1), 0, "seconds floor")
	events.free()
