import QtQuick

Rectangle {
    id: root
    required property var widget
    // end-4 blurred the card against the wallpaper behind it. On a layer-shell
    // surface there is no wallpaper item to sample, so the card keeps the tint
    // and drops the blur rather than faking it.
    property bool blurred: false
    property bool shadowed: Config.options.background.widgets.shadow
    property color tint: Appearance.colors.colLayer1
    property real tintOpacity: 0.55

    radius: Appearance.rounding?.verylarge ?? 30
    color: Appearance.colors.colPrimaryContainer

    StyledRectangularShadow {
        target: root
        z: -2
        visible: root.shadowed
    }
}
