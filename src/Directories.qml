pragma Singleton
import QtQuick
import Quickshell

// The two paths the card needs, resolved against this plugin rather than
// against the shell's config root.
QtObject {
    id: root

    // Qt.resolvedUrl("..") from files in src/ is the plugin directory.
    readonly property string pluginRoot: {
        var url = Qt.resolvedUrl("..").toString()
        return url.replace(/^file:\/\//, "").replace(/\/$/, "")
    }

    readonly property string scriptPath: root.pluginRoot + "/scripts"

    readonly property string coverArt: {
        var cache = Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")
        return cache + "/omarchy-media-lyrics/coverart"
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.coverArt])
}
