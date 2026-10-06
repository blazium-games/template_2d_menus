extends Node

const TOKEN_PATH := "user://device_token.txt"
const EVENTS_URL := "https://api.blazium.online/api/v1/public/events"
const MS_CAP := 600000
const SEC_CAP := 86400

var warned_missing_ids := false
var device_token := ""
var boot_msec := 0
var noted_input := false

func _ready() -> void:
	boot_msec = Time.get_ticks_msec()
	device_token = _read_or_make_token()
	_try_emit("session_start", {})
	await get_tree().process_frame
	var elapsed := Time.get_ticks_msec() - boot_msec
	_try_emit("boot_ok", {"device_uid": device_token, "ms": clamp_span_ms(elapsed)})

func _input(event: InputEvent) -> void:
	if noted_input:
		return
	if not _is_press(event):
		return
	noted_input = true
	var elapsed := Time.get_ticks_msec() - boot_msec
	_try_emit("first_input", {"ms": clamp_span_ms(elapsed)})

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_close_session(false)

func request_quit() -> void:
	_close_session(true)
	get_tree().quit()

func _close_session(chosen: bool) -> void:
	var seconds := int((Time.get_ticks_msec() - boot_msec) / 1000.0)
	if chosen:
		_try_emit("quit", {})
	_try_emit("session_end", {"seconds": clamp_span_sec(seconds)})

func clamp_span_ms(raw: int) -> int:
	return clampi(raw, 0, MS_CAP)

func clamp_span_sec(raw: int) -> int:
	return clampi(raw, 0, SEC_CAP)

func ids_ready() -> bool:
	var app := str(ProjectSettings.get_setting("application/crash_reporter/app_id", "")).strip_edges()
	var build := str(ProjectSettings.get_setting("application/crash_reporter/build_id", "")).strip_edges()
	return app != "" and build != ""

func _try_emit(kind: String, fields: Dictionary) -> void:
	if not ids_ready():
		if not warned_missing_ids:
			warned_missing_ids = true
			push_warning("Launch events skipped until app_id and build_id are both set.")
		return
	var payload := {"event": kind, "anonymous": true}
	if device_token != "":
		payload["device_uid"] = device_token
	for key in fields.keys():
		payload[key] = fields[key]
	var body := JSON.stringify({"events": [payload]})
	var req := HTTPRequest.new()
	add_child(req)
	var headers := PackedStringArray([
		"Content-Type: application/json",
		"X-App-Id: %s" % str(ProjectSettings.get_setting("application/crash_reporter/app_id", "")),
		"X-Build-Id: %s" % str(ProjectSettings.get_setting("application/crash_reporter/build_id", "")),
	])
	req.request(EVENTS_URL, headers, HTTPClient.METHOD_POST, body)

func _is_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo
	if event is InputEventMouseButton:
		return event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventJoypadButton:
		return event.pressed
	return false

func _read_or_make_token() -> String:
	if FileAccess.file_exists(TOKEN_PATH):
		var reader := FileAccess.open(TOKEN_PATH, FileAccess.READ)
		if reader:
			var existing := reader.get_as_text().strip_edges()
			reader.close()
			if existing != "":
				return existing
	var made := "%s-%s" % [Time.get_unix_time_from_system(), randi()]
	var writer := FileAccess.open(TOKEN_PATH, FileAccess.WRITE)
	if writer:
		writer.store_string(made)
		writer.close()
	return made
