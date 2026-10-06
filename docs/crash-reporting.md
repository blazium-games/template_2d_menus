# Crash reporting for Menus 2D

The project settings under `application/crash_reporter/` turn the engine reporter on in Sidecar mode. Consent is required. The engine writes a dump and a json file. The sidecar only shows them and uploads after the player confirms.

Put the official `crash_reporter.exe` (or `crash_reporter` on Linux) next to the exported game. Install that binary with `blazium-cli update apply --product crash_reporter`. Set `reporter_filename.windows` if you move it into a subfolder, and optionally pin `reporter_sha256`.

`app_id` and `build_id` are empty in this starter. Fill both from the build you are exporting before you ship. They are public ids, not secrets. Until both are set, the launch-event autoload warns once and does not POST.

Endpoint: `https://api.blazium.online/api/v1/public/crashes`

The same ids go on launch events: `session_start`, `boot_ok`, `first_input`, `session_end`, and `quit`. `boot_ok` includes a random per-install `device_uid`. `ms` is clamped to 0..600000. `session_end` sends `seconds` clamped to 0..86400.

Do not put API secrets in Project Settings. Do not call `induce_crash` from Autowork.
