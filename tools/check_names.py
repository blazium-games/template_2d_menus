import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BANNED = ROOT / "tools" / "banned_names.txt"
ALLOW = {
    "_ready", "_process", "_physics_process", "_input", "_unhandled_input",
    "_notification", "_enter_tree", "_exit_tree", "_init", "_initialize", "_draw", "_unhandled_input", "_gui_input",
}
EXEMPT = {
    "launch_events.gd", "boot_guard.gd", "register.gd", "run_tests.gd",
    "test_session.gd", "check_names.py", "banned_names.txt",
}
SKIP_DIRS = {".git", ".godot", ".cursor", ".import", ".blazium"}
DECL = re.compile(
    r"^(?:class_name|func|signal|enum|const)\s+(\w+)|^(?:@\w+(?:\([^)]*\))?\s+)*var\s+(\w+)"
)

def declared(text: str) -> set[str]:
    found = set()
    for line in text.splitlines():
        if line.startswith(" ") or line.startswith("\t"):
            continue
        match = DECL.match(line.strip())
        if not match:
            continue
        name = match.group(1) or match.group(2)
        if name and name not in ALLOW:
            found.add(name)
    return found

def main() -> int:
    if not BANNED.exists():
        print("no banned_names.txt")
        return 0
    banned = {line.strip() for line in BANNED.read_text(encoding="utf-8").splitlines() if line.strip()}
    banned -= ALLOW
    hits = []
    for path in ROOT.rglob("*.gd"):
        if path.name in EXEMPT or any(part in SKIP_DIRS for part in path.parts):
            continue
        overlap = declared(path.read_text(encoding="utf-8")) & banned
        for name in sorted(overlap):
            hits.append(f"{path.relative_to(ROOT)} declares {name}")
    for path in ROOT.rglob("*"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.is_file() and path.name not in EXEMPT and path.name in banned:
            hits.append(f"filename {path.relative_to(ROOT)} is banned")
    if hits:
        print("\n".join(hits))
        return 1
    print("banned-name check ok")
    return 0

if __name__ == "__main__":
    sys.exit(main())
