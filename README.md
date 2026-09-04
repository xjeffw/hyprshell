# Hyprshell

A compact, multi-monitor Hyprland top bar built with Quickshell 0.3. Its layout
follows the supplied AGS reference bar while using simple Qt Quick components
and the Catppuccin Mocha palette.

The bar provides:

- monitor-local Hyprland workspaces and the active window title;
- MPRIS media status and play/pause, player cycling, and seeking controls;
- system tray items with activation, menus, and scrolling;
- shared CPU, temperature, frequency, and memory statistics;
- PipeWire output volume and optional UPower battery status;
- date and time; and
- a notification daemon with a top-right popup and action buttons.

## Run it

Enter the development shell and start Quickshell against the repository config:

```sh
nix develop
quickshell --path ./quickshell
```

Or run the packaged shell directly:

```sh
nix run .#hyprshell
```

Only one desktop notification daemon can own the notification D-Bus name. Stop
another daemon such as `dunst`, `mako`, or `swaync` before starting Hyprshell.
You can test the popup from the development shell with:

```sh
notify-send "Hyprshell" "Notifications are working"
```

For Hyprland autostart, use the packaged command with an absolute repository
path, for example:

```ini
exec-once = nix run /absolute/path/to/hyprshell#hyprshell
```

Workspace buttons switch with left click. Media uses left click for play/pause,
right click to cycle players, and the scroll wheel to seek. The volume section
toggles mute on click and changes volume with the scroll wheel.
