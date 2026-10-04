pragma Singleton
import QtQuick

// The card reads its settings from here. The plugin service owns the values and
// pushes them in; the only thing that ever flows the other way is a card resize,
// which the service persists with `settingWritten`.
//
// `options` mirrors the shape end-4's own `Config` exposes, so the ported QML
// keeps reading `Config.options.background.widgets.shadow` unchanged.
QtObject {
    id: root

    property var settings: ({})
    // Set while the service pushes a settings snapshot, so an incoming value
    // never echoes back out as a user edit.
    property bool pushing: false

    readonly property string theme: String(settings.theme ?? "omarchy")
    readonly property string iconStyle: String(settings.iconStyle ?? "auto")
    readonly property bool widgetsLocked: settings.locked === true
    // True while the card is on screen. Anything that costs something — a
    // network request, a timer — asks this first.
    property bool cardVisible: true

    // Two-way: WidgetBase's ResizeHandler writes the new mode, and the service
    // saves it. `pushing` keeps a snapshot from looking like a resize.
    property string sizeMode: "1x3"
    signal settingWritten(string key, var value)
    onSizeModeChanged: {
        if (!root.pushing) root.settingWritten("sizeMode", root.sizeMode)
    }

    // Asked for by a keybind or a script through the `mediaLyrics` IPC target;
    // the card owns the panel, so it answers.
    signal lyricsToggled()

    readonly property QtObject options: QtObject {
        readonly property QtObject background: QtObject {
            readonly property QtObject widgets: QtObject {
                readonly property bool shadow: root.settings.shadow !== false
                readonly property bool blurWidgets: false
            }
            readonly property bool widgetsLocked: root.widgetsLocked
        }
        readonly property QtObject bar: QtObject {
            readonly property QtObject media: QtObject {
                readonly property string preferredPlayer: String(root.settings.preferredPlayer ?? "")
            }
        }
        readonly property QtObject media: QtObject {
            readonly property bool filterDuplicatePlayers: root.settings.filterDuplicatePlayers !== false
        }
    }
}
