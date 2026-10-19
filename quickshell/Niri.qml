pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Workspace and window state from the niri IPC event stream. Hyprland exposes
// the same data through Quickshell.Hyprland; niri has no Quickshell module, so
// this follows `niri msg event-stream` over the socket in NIRI_SOCKET.
Singleton {
    id: root

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET") ?? ""
    readonly property bool available: socketPath.length > 0

    // Sorted by output, then by position on the output.
    property var workspaces: []
    // Keyed by window id.
    property var windows: ({})
    property var focusedWindowId: null

    readonly property var focusedWorkspace: workspaces.find(workspace => workspace.is_focused) ?? null
    readonly property string focusedOutput: focusedWorkspace?.output ?? ""

    function workspacesOn(output) {
        return workspaces.filter(workspace => workspace.output === output);
    }

    function focusedWindowOn(output) {
        const window = focusedWindowId === null ? null : windows[focusedWindowId] ?? null;
        if (window === null)
            return null;
        const workspace = workspaces.find(workspace => workspace.id === window.workspace_id);
        return workspace?.output === output ? window : null;
    }

    function focusWorkspace(id) {
        send({
            Action: {
                FocusWorkspace: {
                    reference: {
                        Id: id
                    }
                }
            }
        });
    }

    function send(request) {
        actionSocket.write(JSON.stringify(request) + "\n");
        actionSocket.flush();
    }

    function sortWorkspaces(list) {
        return list.slice().sort((a, b) => (a.output ?? "").localeCompare(b.output ?? "") || a.idx - b.idx);
    }

    function updateWorkspaces(update) {
        workspaces = workspaces.map(workspace => Object.assign({}, workspace, update(workspace)));
    }

    function handleEvent(line) {
        let event;
        try {
            event = JSON.parse(line);
        } catch (error) {
            console.warn(`Niri: unparseable event: ${line}`);
            return;
        }

        const [type, data] = Object.entries(event)[0];
        if (type === "Err") {
            console.warn(`Niri: event stream error: ${data}`);
        } else if (type === "WorkspacesChanged") {
            workspaces = sortWorkspaces(data.workspaces);
        } else if (type === "WorkspaceActivated") {
            const output = workspaces.find(workspace => workspace.id === data.id)?.output;
            updateWorkspaces(workspace => ({
                is_active: workspace.output === output ? workspace.id === data.id : workspace.is_active,
                is_focused: data.focused ? workspace.id === data.id : workspace.is_focused
            }));
        } else if (type === "WorkspaceUrgencyChanged") {
            updateWorkspaces(workspace => workspace.id === data.id ? { is_urgent: data.urgent } : {});
        } else if (type === "WorkspaceActiveWindowChanged") {
            updateWorkspaces(workspace => workspace.id === data.workspace_id ? { active_window_id: data.active_window_id } : {});
        } else if (type === "WindowsChanged") {
            const next = {};
            for (const window of data.windows)
                next[window.id] = window;
            windows = next;
            focusedWindowId = data.windows.find(window => window.is_focused)?.id ?? null;
        } else if (type === "WindowOpenedOrChanged") {
            windows = Object.assign({}, windows, { [data.window.id]: data.window });
            if (data.window.is_focused)
                focusedWindowId = data.window.id;
        } else if (type === "WindowClosed") {
            const next = Object.assign({}, windows);
            delete next[data.id];
            windows = next;
            if (focusedWindowId === data.id)
                focusedWindowId = null;
        } else if (type === "WindowFocusChanged") {
            focusedWindowId = data.id;
        }
    }

    Socket {
        id: eventSocket

        path: root.socketPath
        connected: root.available

        onConnectionStateChanged: {
            if (connected) {
                write("\"EventStream\"\n");
                flush();
            }
        }

        parser: SplitParser {
            onRead: line => root.handleEvent(line)
        }
    }

    Socket {
        id: actionSocket

        path: root.socketPath
        connected: root.available

        // Each request gets a one-line reply; only errors are interesting.
        parser: SplitParser {
            onRead: line => {
                if (!line.startsWith("{\"Ok\""))
                    console.warn(`Niri: action failed: ${line}`);
            }
        }
    }
}
