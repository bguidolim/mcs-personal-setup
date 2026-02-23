## iOS Simulator
- Always use the **booted simulator first**, referenced by **UUID** (not name)
- If no simulator is booted, **ask the user** which one to use

## Build & Test (XcodeBuildMCP)

All build, test, and run operations go through **XcodeBuildMCP**. When a task requires building, testing, running, debugging, or interacting with simulators, **invoke the `xcodebuildmcp` skill first** to load the tool catalog and workflow guidance.

### Rules
- Before the first build/test in a session, call `session_show_defaults` to verify the active project, scheme, and simulator
- **Never** run `xcrun` or `xcodebuild` directly via Bash — always use XcodeBuildMCP tools
- **Never** build or test unless explicitly asked
- Always use `__PROJECT__` with the appropriate scheme
- **Never** suppress warnings — if any are related to the session, fix them
- Prefer `snapshot_ui` over `screenshot` (screenshot only as fallback)
