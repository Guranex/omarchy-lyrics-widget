pragma Singleton
import QtQuick

// One icon, two fonts. The ported card names icons the way end-4 does
// ("music_note", "skip_next", …); this turns a name into the glyph and family
// the active style wants.
//
// The Nerd codepoints are the same ones the stock Omarchy media widget and
// OmaWidgets use, verified against the installed font's cmap:
//   md-music_note F0387 · md-skip_previous F04AE · md-skip_next F04AD
//   md-play F040A · md-pause F03E4 · md-note_text F039E
QtObject {
    id: root

    readonly property string materialFamily: Fonts.iconMaterialFamily
    readonly property string nerdFamily: "JetBrainsMono Nerd Font"

    readonly property var nerd: ({
        "music_note": "󰎇",
        "skip_previous": "󰒮",
        "skip_next": "󰒭",
        "play_arrow": "󰐊",
        "pause": "󰏤",
        "lyrics": "󰎞"
    })

    // "auto" picks Material Symbols when it is installed, Nerd otherwise — so a
    // stock Omarchy shows icons instead of empty boxes.
    readonly property bool useNerd: {
        var style = Config.iconStyle
        if (style === "nerd") return true
        if (style === "material") return false
        return !Fonts.materialSymbolsAvailable
    }

    function resolve(name) {
        if (root.useNerd) {
            var glyph = root.nerd[name]
            return { text: glyph !== undefined ? glyph : name, family: root.nerdFamily }
        }
        return { text: name, family: root.materialFamily }
    }
}
