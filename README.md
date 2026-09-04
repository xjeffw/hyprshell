# Hyprshell

A compact, multi-monitor Hyprland top bar built with Quickshell 0.3. Its layout
follows the supplied AGS reference bar while using simple Qt Quick components
and the Catppuccin Macchiato palette by default.

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

Notifications use supported body markup, close when clicked, and fall back to a
five-second duration when the sender does not provide one.

For Hyprland autostart, use the packaged command with an absolute repository
path, for example:

```ini
exec-once = nix run /absolute/path/to/hyprshell#hyprshell
```

## Color theme

Hyprshell includes Catppuccin Macchiato (the default) and Catppuccin Mocha.
Set `HYPRSHELL_THEME` when starting the shell to select a theme:

```sh
HYPRSHELL_THEME=mocha nix run .#hyprshell
```

The same setting works when running Quickshell directly:

```sh
HYPRSHELL_THEME=mocha quickshell --path ./quickshell
```

Supported values are `macchiato` and `mocha`. Theme names are
case-insensitive, and an unsupported value falls back to Macchiato.

Workspace buttons switch with left click. Media uses left click for play/pause,
right click to cycle players, and the scroll wheel to seek. The volume section
toggles mute on click and changes volume with the scroll wheel.

## Hyprland media bindings

The running shell exposes the same media requests as the previous AGS bar. If
the `hyprshell` package is installed in your user or system profile, the
existing bindings can be changed by replacing `ags` with `hyprshell`:

```ini
bind = SUPER CONTROL, up, exec, hyprshell request 'playPause'
bind = SUPER CONTROL, down, exec, hyprshell request 'selectNextPlayer'
bind = SUPER CONTROL, left, exec, hyprshell request 'previousTrack'
bind = SUPER CONTROL, right, exec, hyprshell request 'nextTrack'
bind = SUPER CONTROL SHIFT, left, exec, hyprshell request 'seekDelta -10'
bind = SUPER CONTROL SHIFT, right, exec, hyprshell request 'seekDelta 10'
```

These map to the native Quickshell IPC target and can also be invoked directly:

```sh
hyprshell ipc call mpris playPause
hyprshell ipc call mpris selectNextPlayer
hyprshell ipc call mpris previousTrack
hyprshell ipc call mpris nextTrack
hyprshell ipc call mpris seekDelta -10
hyprshell ipc call mpris seekDelta 10
```
