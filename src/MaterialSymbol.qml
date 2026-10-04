import QtQuick

// One icon. The call sites name icons the way end-4 does and set the same
// properties (`text`, `iconSize`, `fill`, `color`), so nothing in the ported
// card changed; Glyphs decides whether that name is drawn as a Material Symbols
// ligature or as a Nerd Font codepoint.
Item {
    id: root

    property string text: ""
    property color color: "white"
    property real iconSize: Appearance?.font.pixelSize.small ?? 16
    property real fill: 0
    // Kept so MaterialShapeWrappedMaterialSymbol can alias it; Glyphs supplies
    // the family that actually draws.
    property var font: null

    readonly property real resolvedFill: fill >= 0.5 ? 1.0 : 0.0
    readonly property var glyph: Glyphs.resolve(root.text)
    readonly property bool usingMaterial: root.glyph.family === Glyphs.materialFamily

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.glyph.text
        color: root.color
        renderType: Text.NativeRendering
        font {
            hintingPreference: Font.PreferNoHinting
            family: root.glyph.family
            pixelSize: root.iconSize
            weight: root.resolvedFill > 0.5 ? Font.DemiBold : Font.Normal
            variableAxes: root.usingMaterial
                ? ({ "FILL": root.resolvedFill, "opsz": root.iconSize })
                : ({})
        }
    }
}
