# Menus 2D

Menus 2D is a set of separate menus plus a three-slot save. Copy one scene with its script. Do not copy the whole starter unless you want every menu.

The main scene is scenes/menus/front_sheet.tscn.

## Files

- scenes/menus/front_sheet.tscn and scripts/front_sheet.gd is the main menu.
- scenes/menus/halt_sheet.tscn and scripts/halt_sheet.gd is pause. The play scene instances it.
- scenes/menus/prefs_sheet.tscn and scripts/prefs_sheet.gd is settings.
- scenes/menus/thanks_sheet.tscn and scripts/thanks_sheet.gd is credits.
- scenes/menus/keep_sheet.tscn and scripts/keep_sheet.gd is save.
- scenes/menus/recall_sheet.tscn and scripts/recall_sheet.gd is load. Empty slots stay disabled.
- scenes/menus/confirm_sheet.tscn and scripts/confirm_sheet.gd is yes or no.
- scenes/play_stage.tscn and scripts/play_stage.gd is the small scene pause freezes.
- scripts/slot_rules.gd is the save reject logic. Autowork calls it with no window. Copy it with save, load, pause, and confirm.
- scripts/prefs_rules.gd stores loudness and fullscreen. Copy it with settings.
- autoload/boot_guard.gd checks the input map, clamps volume to 0..1, and pauses on halt when a menu did not handle that key.
- autoload/launch_events.gd sends session_start, boot_ok, first_input, session_end, and quit only after app_id and build_id are both set.
- mcp/register.gd registers the game MCP tools.
- tests/gdscript holds the Autowork tests.
- tools/check_names.py fails if a gameplay declaration matches the source template.
- docs/crash-reporting.md explains the sidecar.

## Extend

`may_quit(confirmed)` rejects quitting the front sheet without confirm. Slot overwrite rules stay. The play scene is unchanged. After that, add a fourth slot the confirm sheet can guard.

Change the rule first, then the scene, then the menu script. Add an Autowork test for the new reject. Run the name check before you save a new declaration.

Slot files live in user://menu_slots. Prefs live in user://menu_prefs.cfg. A copied menu still uses those paths unless you change root_dir or prefs_path.

## Editor MCP

http://127.0.0.1:6506/mcp

This is the engine catalog. Use it to inspect the scene, scripts, and Autowork tools. The project sets blazium/justamcp/server_enabled and override_editor_settings so the editor listens on 6506. Autowork tools are enabled. Headless Autowork still needs --enable-mcp or the editor host stays off. Do not dump the whole catalog. Call blazium_list_toolsets, then one toolset.

## Game MCP

http://127.0.0.1:6507/mcp

This host only exposes tools from res://mcp/register.gd:

- read_menus reads slots and prefs on the current scene. If the scene is not running, the tool returns scene_down.
- reset_menus wipes those live slots and prefs.
- set_halt pauses through BootGuard. Pass halted, or omit it to toggle.
- exercise_menus calls one rule function. Pass action and an args array. Actions include slot_ok, may_overwrite, may_load, write_slot, read_slot, newest_index, wipe_slots, set_loudness, set_fullscreen, store_prefs, and recall_prefs. Names that start with an underscore are rejected. This is not eval.
- starter_brief is a prompt with this same guidance.

Run one starter at a time. Every starter uses ports 6506 and 6507.
