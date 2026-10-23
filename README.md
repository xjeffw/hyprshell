# Hyprshell

A compact, multi-monitor top bar for Hyprland and niri built with Quickshell
0.3. Its layout
follows the supplied AGS reference bar while using simple Qt Quick components
and the Catppuccin Mocha palette by default.

The bar provides:

- monitor-local Hyprland or niri workspaces and the active window title;
- MPRIS media status and play/pause, player cycling, and seeking controls;
- system tray items with activation, menus, and scrolling;
- shared CPU, temperature, frequency, and memory statistics;
- battery level and charging state, using UPower with a Linux sysfs fallback;
- PipeWire output volume;
- date and time;
- a notification daemon with a top-right popup and action buttons; and
- avizo-style volume and brightness displays.

User-facing options live in `quickshell/Config.qml`. Set `transparentBar` to
`true` to remove the bar's full-width background; it defaults to the solid
Catppuccin background.

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

The packaged command runs its own copy of `quickshell/`. Set
`HYPRSHELL_CONFIG_DIR` to run a checkout instead, so edits take effect without
rebuilding (Quickshell reloads the config when its files change):

```sh
HYPRSHELL_CONFIG_DIR=~/code/hyprshell/quickshell hyprshell
```

`hyprshell request` uses the same variable to reach the running shell, so set it
for both.

For Hyprland autostart, use the packaged command with an absolute repository
path, for example:

```ini
exec-once = nix run /absolute/path/to/hyprshell#hyprshell
```

## niri

Hyprshell uses niri when `NIRI_SOCKET` is set, which niri does for everything it
starts (including systemd user services in a `niri-session`). Workspaces and the
active window title then come from the niri IPC event stream instead of
Hyprland. The bar lists the workspaces on its own output, labelled by name or
index, and hides niri's trailing empty workspace unless it is active.

For niri autostart, use `spawn-at-startup`:

```kdl
spawn-at-startup "nix" "run" "/absolute/path/to/hyprshell#hyprshell"
```

## Color theme

Hyprshell includes Catppuccin Mocha (the default), Macchiato, and Frappé.
Set `HYPRSHELL_THEME` when starting the shell to select a theme:

```sh
HYPRSHELL_THEME=macchiato nix run .#hyprshell
```

The same setting works when running Quickshell directly:

```sh
HYPRSHELL_THEME=macchiato quickshell --path ./quickshell
```

Supported values are `frappe`, `macchiato`, and `mocha`. Theme names are
case-insensitive, and an unsupported value falls back to Mocha.

Workspace buttons switch with left click. Media uses left click for play/pause,
right click to cycle players, and the scroll wheel to seek. The volume section
toggles mute on click and changes volume with the scroll wheel.

## Media bindings

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

The niri equivalents look like this:

```kdl
binds {
    Super+Ctrl+Up { spawn "hyprshell" "request" "playPause"; }
    Super+Ctrl+Shift+Left { spawn "hyprshell" "request" "seekDelta" "-10"; }
}
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

## Volume and brightness displays

The `volume` IPC target raises or lowers the default output's volume by 5%
(stopping at 100%) or toggles mute, then briefly shows a volume display on every
screen, styled like the notification popup and placed like avizo's. Bind the
volume keys to it in place of avizo's `volumectl`:

```ini
binde = ,XF86AudioRaiseVolume, exec, hyprshell ipc call volume up
binde = ,XF86AudioLowerVolume, exec, hyprshell ipc call volume down
bind = ,XF86AudioMute, exec, hyprshell ipc call volume toggleMute
```

The niri equivalents look like this:

```kdl
binds {
    XF86AudioRaiseVolume allow-when-locked=true { spawn "hyprshell" "ipc" "call" "volume" "up"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "hyprshell" "ipc" "call" "volume" "down"; }
    XF86AudioMute allow-when-locked=true repeat=false { spawn "hyprshell" "ipc" "call" "volume" "toggleMute"; }
}
```

Scripts that change a monitor's brightness can show its new level, with the
monitor's name above it, through the `brightness` target. The call prints `true`
once the display is shown; `ipc call` exits successfully even when the target
doesn't exist, so check for that to fall back to a notification:

```sh
hyprshell ipc call brightness changed "DELL P2715Q" 80
```

The displays' layer-shell namespace is `hyprshell-osd`; notification popups use
`hyprshell-notification`.
