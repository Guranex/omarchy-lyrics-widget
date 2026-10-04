import QtQuick

// The Material 3 look, exactly as end-4 ships it: the baseline dark scheme its
// Appearance singleton carries, with the same derived roles. The dots normally
// re-tint this from the wallpaper with matugen; Omarchy has no matugen, so the
// baseline is used and the shapes, spacing and type stay faithful.
QtObject {
    id: root

    readonly property var m3: ({
        background: "#141313",
        onBackground: "#e6e1e1",
        surfaceContainerLow: "#1c1b1c",
        onSurfaceVariant: "#cbc5ca",
        outline: "#948f94",
        outlineVariant: "#49464a",
        primary: "#cbc4cb",
        onPrimary: "#322f34",
        primaryContainer: "#2d2a2f",
        onPrimaryContainer: "#bcb6bc",
        secondaryContainer: "#4d4b4d",
        onSecondaryContainer: "#ece6e9",
        shadow: "#000000"
    })

    readonly property QtObject m3colors: QtObject {
        readonly property color m3background: root.m3.background
        readonly property color m3onBackground: root.m3.onBackground
        readonly property color m3onSurface: root.m3.onBackground
        readonly property color m3outline: root.m3.outline
        readonly property color m3primary: root.m3.primary
    }

    readonly property QtObject colors: QtObject {
        readonly property color colSubtext: root.m3.outline

        readonly property color colLayer1: root.m3.surfaceContainerLow
        readonly property color colLayer1Hover: ColorUtils.mix(root.m3.surfaceContainerLow, root.m3.onSurfaceVariant, 0.92)
        readonly property color colLayer1Active: ColorUtils.mix(root.m3.surfaceContainerLow, root.m3.onSurfaceVariant, 0.85)

        readonly property color colPrimary: root.m3.primary
        readonly property color colOnPrimary: root.m3.onPrimary
        readonly property color colPrimaryHover: ColorUtils.mix(
            root.m3.primary,
            ColorUtils.mix(root.m3.surfaceContainerLow, root.m3.onSurfaceVariant, 0.92), 0.87)
        readonly property color colPrimaryActive: ColorUtils.mix(
            root.m3.primary,
            ColorUtils.mix(root.m3.surfaceContainerLow, root.m3.onSurfaceVariant, 0.85), 0.70)
        readonly property color colPrimaryContainer: root.m3.primaryContainer
        readonly property color colPrimaryContainerHover: ColorUtils.mix(root.m3.primaryContainer, root.m3.onPrimaryContainer, 0.90)
        readonly property color colPrimaryContainerActive: ColorUtils.mix(root.m3.primaryContainer, root.m3.onPrimaryContainer, 0.80)
        readonly property color colOnPrimaryContainer: root.m3.onPrimaryContainer

        readonly property color colSecondaryContainer: root.m3.secondaryContainer
        readonly property color colSecondaryContainerHover: ColorUtils.mix(root.m3.secondaryContainer, root.m3.onSecondaryContainer, 0.90)
        readonly property color colSecondaryContainerActive: ColorUtils.mix(root.m3.secondaryContainer, root.m3.onSecondaryContainer, 0.54)
        readonly property color colOnSecondaryContainer: root.m3.onSecondaryContainer

        readonly property color colSurfaceContainerLow: root.m3.surfaceContainerLow
        readonly property color colShadow: ColorUtils.transparentize(root.m3.shadow, 0.70)
        readonly property color colOutlineVariant: root.m3.outlineVariant
    }

    readonly property QtObject rounding: QtObject {
        readonly property int small: 12
        readonly property int normal: 17
        readonly property int verylarge: 30
        readonly property int full: 9999
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string main: "sans-serif"
            readonly property string numbers: "sans-serif"
        }
        readonly property QtObject variableAxes: QtObject {
            readonly property var main: ({})
        }
        readonly property QtObject pixelSize: QtObject {
            readonly property int smaller: 12
            readonly property int small: 15
            readonly property int normal: 16
            readonly property int large: 17
            readonly property int huge: 22
        }
    }

    readonly property QtObject sizes: QtObject {
        readonly property real elevationMargin: 10
    }
}
