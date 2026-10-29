# Tether

Tether saves the windows that belong together as a room: coding, writing, a client call, or anything else that needs its own desktop shape. Restore a room to put its open windows back where you left them.

Everything stays local. Tether stores room names, window titles, app bundle identifiers and window frames in `UserDefaults`; it has no network access, accounts or telemetry.

## Current v1

- Save the currently open windows as a named room.
- Restore the positions and sizes of apps that are already running.
- Browse rooms and their individual saved windows.
- Accessibility permission is requested only when needed.

## Run

Requires macOS 14 or newer and Xcode's command-line tools.

```sh
swift run
```

On the first capture or restore, macOS will ask for **Accessibility** permission. Enable Tether in **System Settings → Privacy & Security → Accessibility**, then return to the app.

## Limits, for now

- A room currently arranges apps that are already open. Launching closed apps and multi-display rules are the next pieces to add.
- Some apps deliberately do not expose every window to macOS Accessibility, so those windows cannot be reliably saved or moved.
