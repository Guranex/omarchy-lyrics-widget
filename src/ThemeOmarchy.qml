import QtQuick
import qs.Commons

// The Omarchy look: the same palette the bar, popups and OmaWidgets read, so the
// card restyles in the same frame as the rest of the shell on a theme switch.
QtObject {
    id: root

    readonly property QtObject m3colors: QtObject {
        readonly property color m3background: Color.background
        readonly property color m3onBackground: Color.popups.text
        readonly property color m3onSurface: Color.popups.text
        readonly property color m3outline: Color.muted
        readonly property color m3primary: Color.accent
    }

    readonly property QtObject colors: QtObject {
        readonly property color colSubtext: Util.alpha(Color.popups.text, 0.55)

        readonly property color colLayer1: Util.alpha(Color.popups.background, 0.90)
        readonly property color colLayer1Hover: Util.alpha(Color.popups.text, 0.08)
        readonly property color colLayer1Active: Util.alpha(Color.popups.text, 0.14)

        readonly property color colPrimary: Color.accent
        readonly property color colOnPrimary: Color.background
        readonly property color colPrimaryHover: Util.alpha(Color.accent, 0.85)
        readonly property color colPrimaryActive: Util.alpha(Color.accent, 0.72)
        // The card's own fill. end-4 used a solid M3 container tone here, so an
        // Omarchy card uses the same popup surface the rest of the shell does
        // rather than a wash of text colour.
        readonly property color colPrimaryContainer: Util.alpha(Color.popups.background, 0.94)
        readonly property color colPrimaryContainerHover: Util.alpha(Color.popups.text, 0.12)
        readonly property color colPrimaryContainerActive: Util.alpha(Color.popups.text, 0.18)
        readonly property color colOnPrimaryContainer: Color.popups.text

        readonly property color colSecondaryContainer: Util.alpha(Color.popups.text, 0.08)
        readonly property color colSecondaryContainerHover: Util.alpha(Color.popups.text, 0.14)
        readonly property color colSecondaryContainerActive: Util.alpha(Color.popups.text, 0.20)
        readonly property color colOnSecondaryContainer: Color.popups.text

        readonly property color colSurfaceContainerLow: Util.alpha(Color.popups.text, 0.06)
        readonly property color colShadow: Util.alpha("#000000", 0.55)
        readonly property color colOutlineVariant: Util.alpha(Color.popups.border, 0.5)
    }

    readonly property QtObject rounding: QtObject {
        readonly property int small: Math.max(4, Style.cornerRadius)
        readonly property int normal: Math.max(6, Style.cornerRadius)
        readonly property int verylarge: Math.max(10, Style.cornerRadius + 4)
        readonly property int full: 9999
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string main: Style.font.family
            readonly property string numbers: Style.font.family
        }
        readonly property QtObject variableAxes: QtObject {
            readonly property var main: ({})
        }
        readonly property QtObject pixelSize: QtObject {
            readonly property int smaller: Style.font.bodySmall
            readonly property int small: Style.font.body
            readonly property int normal: Style.font.subtitle
            readonly property int large: Style.font.heading
            readonly property int huge: Style.font.display
        }
    }

    readonly property QtObject sizes: QtObject {
        readonly property real elevationMargin: 10
    }
}
