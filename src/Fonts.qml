pragma Singleton
import QtQuick

// Whether the Material Symbols icon font is on this machine. Omarchy ships Nerd
// Fonts, not Material Symbols, so on a stock system Glyphs falls back to the
// Nerd codepoints the rest of the shell already uses.
QtObject {
    id: root

    property string iconMaterialFamily: "Material Symbols Rounded"
    property bool materialSymbolsAvailable: false

    Component.onCompleted: root.detect()

    function detect() {
        var families = []
        try {
            if (typeof Qt.fontFamilies === "function") families = Qt.fontFamilies()
        } catch (e) {
            families = []
        }
        for (var i = 0; i < families.length; i++) {
            var name = String(families[i])
            if (name.indexOf("Material Symbols") === 0) {
                root.iconMaterialFamily = name
                root.materialSymbolsAvailable = true
                return
            }
        }
        root.materialSymbolsAvailable = false
    }
}
