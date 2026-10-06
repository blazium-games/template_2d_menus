# Menus 2D

Main, pause, settings, credits, save, and load as separate Control scenes you can copy. Three slots reject a bad index, a bad version, and an overwrite without confirm.

Follow-on scene: `scenes/play_stage.tscn`.

## Open

Download the editor from [blazium.app/download](https://blazium.app/download), or install it with:

```text
blazium-cli install latest-release
```

Open this folder and press Play. The main scene is `scenes/menus/front_sheet.tscn`.

## Controls

Stride north and stride south move the selection. Primary confirms. Halt goes back. On the main menu, halt asks you to quit. On the play scene, halt opens the pause menu.

## Tests

From this folder, with `blazium` on your PATH:

```text
blazium --headless --path . -s res://run_tests.gd
python tools/check_names.py
```

Exit code 0 on both is the pass. Crash reporting is in [docs/crash-reporting.md](docs/crash-reporting.md). How to extend this starter is in [docs/engineer.md](docs/engineer.md).

Game MCP tools: `read_menus, reset_menus, set_halt, exercise_menus`. `exercise_*` calls one public rule method. Pass `action` and an `args` array. It is not eval. Headless Autowork does not start MCP unless you also pass `--enable-mcp`.

## Copy one menu

Copy one scene and its matching script. Save, load, pause, and confirm also need `scripts/slot_rules.gd`. Settings also needs `scripts/prefs_rules.gd`.


## Blazium Engine

[Blazium Engine](https://blazium.app) is the free MIT game engine. The editor belongs to it. `blazium-cli` installs editors, manages projects, remote-controls a running editor, and deploys to Steam and itch.io. Two lines ship: `blazium-dev` is the Godot 4.3+ line, and `blazium_4.8` is the Godot 4.8+ line. Hub, the crash reporter, skills, and subagents track `blazium_4.8`.

## Blazium Games

[Blazium Games](https://blazium.games) is a separate store, operated by Divine Games, Inc. It is the platform for playing and publishing games, applications, mods, and assets. A game on that store does not have to be made with the Blazium engine, and the engine does not require that store. `chauffeur` is the only upload tool for Blazium Games. Docs are at [docs.blazium.games](https://docs.blazium.games).

## Community

- Official website: [https://blazium.app/](https://blazium.app/)
- IndieDB blog: [https://www.indiedb.com/engines/blazium-engine](https://www.indiedb.com/engines/blazium-engine)
- Official community: [Discord](https://blazium.app/chat)
- Docs: [docs.blazium.app](https://docs.blazium.app)

## Platform

- Docs: [docs.blazium.app](https://docs.blazium.app) and [docs.blazium.games](https://docs.blazium.games)
- Skills: `npm install @blazium-engine/skills`
- Editor MCP: http://127.0.0.1:6506/mcp for scenes, scripts, and Autowork tools
- Game MCP: http://127.0.0.1:6507/mcp for this starter only
- CLI: [blazium-cli](https://github.com/blazium-games/blazium-cli) installs the editor. It is not the Games uploader.
- Hub: [BlaziumHub](https://github.com/blazium-games/blazium-hub) opens projects in the editor
- Launcher: [BlaziumLauncher](https://github.com/blazium-games/games_launcher) plays store games. It does not open this starter.
- Support: [blazium-games/support](https://github.com/blazium-games/support/issues). Status: [status.blazium.games](https://status.blazium.games)

Run one starter at a time. Every starter uses ports 6506 and 6507.

## Support

- Bugs in this starter: open an issue on this repository.
- Engine bugs: [blazium-games/blazium](https://github.com/blazium-games/blazium/issues).
- Store, account, or payment issues: [blazium-games/support](https://github.com/blazium-games/support/issues) or [blazium.games/support](https://blazium.games/support). Email [support@blazium.games](mailto:support@blazium.games) for account and payment problems. Do not post passwords, login codes, API keys, or payment details.
- Security reports: use the private advisory on [blazium-games/support](https://github.com/blazium-games/support/security/advisories/new). Do not open a public issue.
- Status: [status.blazium.games](https://status.blazium.games).

## License

Licensed under the MIT License. See [LICENSE](LICENSE).
