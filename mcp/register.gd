extends Node

func register() -> void:
	var runtime := _runtime()
	if runtime == null:
		push_error("JustAMCP: mcp/register.gd needs the JustAMCPRuntime singleton")
		return
	runtime.register_tool(
		"read_menus",
		"Read live save and settings state for Menus 2D.",
		{"type": "object", "properties": {}},
		Callable(self, "_read_state")
	)
	runtime.register_tool(
		"reset_menus",
		"Wipe live slots and settings for Menus 2D.",
		{"type": "object", "properties": {}},
		Callable(self, "_reset_state")
	)
	runtime.register_tool(
		"set_halt",
		"Pause or resume this starter.",
		{"type": "object", "properties": {"halted": {"type": "boolean", "description": "If omitted, toggle"}}},
		Callable(self, "_set_halt")
	)
	runtime.register_tool(
		"exercise_menus",
		"Call one rule function on the live scene. Pass action and an args array. This is not eval.",
		{
			"type": "object",
			"properties": {
				"action": {"type": "string", "description": "Rule function name"},
				"args": {"type": "array", "description": "Arguments for that function"},
			},
			"required": ["action"],
		},
		Callable(self, "_exercise")
	)
	if runtime.has_method("register_prompt"):
		runtime.register_prompt(
			"starter_brief",
			"How to extend Menus 2D.",
			Callable(self, "_brief")
		)

func _runtime() -> Object:
	if Engine.has_singleton("JustAMCPRuntime"):
		return Engine.get_singleton("JustAMCPRuntime")
	return null

func _presenter() -> Node:
	var loop := Engine.get_main_loop()
	if loop == null or not (loop is SceneTree):
		return null
	return loop.current_scene

func _read_state(_args: Dictionary) -> Dictionary:
	var node := _presenter()
	if node == null or not ("slots" in node) or not ("prefs" in node):
		return {"ok": false, "reason": "scene_down"}
	var slots: Object = node.get("slots")
	var prefs: Object = node.get("prefs")
	if slots == null or prefs == null:
		return {"ok": false, "reason": "scene_down"}
	return {
		"ok": true,
		"newest": slots.newest_index(),
		"loudness": prefs.loudness,
		"fullscreen": prefs.fullscreen,
	}

func _reset_state(_args: Dictionary) -> Dictionary:
	var node := _presenter()
	if node == null or not ("slots" in node) or not ("prefs" in node):
		return {"ok": false, "reason": "scene_down"}
	var slots: Object = node.get("slots")
	var prefs: Object = node.get("prefs")
	if slots == null or prefs == null:
		return {"ok": false, "reason": "scene_down"}
	load("res://scripts/slot_rules.gd").clear_route()
	slots.wipe_slots()
	prefs.wipe_prefs()
	node.set("slots", load("res://scripts/slot_rules.gd").new())
	node.set("prefs", load("res://scripts/prefs_rules.gd").new())
	return {"reset": true}

func _set_halt(args: Dictionary) -> Dictionary:
	var loop := Engine.get_main_loop()
	if loop == null or not (loop is SceneTree):
		return {"ok": false, "reason": "scene_down"}
	var guard: Node = loop.root.get_node_or_null("BootGuard")
	if guard == null:
		return {"ok": false, "reason": "guard_down"}
	if args.has("halted"):
		guard.halted = bool(args["halted"])
		guard.get_tree().paused = guard.halted
	else:
		guard.toggle_halt()
	return {"halted": guard.halted}

func _exercise(args: Dictionary) -> Dictionary:
	var node := _presenter()
	if node == null:
		return {"ok": false, "reason": "scene_down"}
	var action := str(args.get("action", ""))
	if action == "" or action.begins_with("_"):
		return {"ok": false, "reason": "unknown_action"}
	var rules: Object = null
	var slots: Object = node.get("slots")
	var prefs: Object = node.get("prefs")
	if slots != null and slots.has_method(action):
		rules = slots
	elif prefs != null and prefs.has_method(action):
		rules = prefs
	if rules == null:
		return {"ok": false, "reason": "unknown_action"}
	var call_args: Array = args.get("args", [])
	if typeof(call_args) != TYPE_ARRAY:
		return {"ok": false, "reason": "args_must_be_array"}
	return {"ok": true, "result": rules.callv(action, call_args)}

func _brief(_args: Dictionary) -> String:
	return "Menus 2D. Each menu is its own scene and script so you can copy that pair. Save and load need scripts/slot_rules.gd. Settings needs scripts/prefs_rules.gd. Open scenes/menus/front_sheet.tscn and play_stage.tscn. Editor MCP is http://127.0.0.1:6506/mcp. Game MCP is http://127.0.0.1:6507/mcp. Tools: read_menus, reset_menus, set_halt, exercise_menus."
