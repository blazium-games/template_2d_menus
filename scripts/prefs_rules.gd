extends RefCounted

var prefs_path := "user://menu_prefs.cfg"
var loudness := 0.8
var fullscreen := false

func set_loudness(value: float) -> bool:
	if value < 0.0 or value > 1.0:
		return false
	loudness = value
	return true

func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled

func store_prefs() -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("prefs", "loudness", loudness)
	cfg.set_value("prefs", "fullscreen", fullscreen)
	return cfg.save(prefs_path) == OK

func recall_prefs() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(prefs_path) != OK:
		return false
	var value: Variant = cfg.get_value("prefs", "loudness", 0.8)
	if not set_loudness(float(value)):
		return false
	fullscreen = bool(cfg.get_value("prefs", "fullscreen", false))
	return true

func wipe_prefs() -> void:
	if FileAccess.file_exists(prefs_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(prefs_path))
	loudness = 0.8
	fullscreen = false
