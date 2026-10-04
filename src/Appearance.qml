pragma Singleton
import QtQuick

// One name for "how the card is drawn", backed by two palettes. Everything the
// ported card asks of Appearance — colours, corner radii, type scale — resolves
// through whichever style is active, so the card source never learned about the
// switch.
QtObject {
    id: root

    readonly property QtObject material: ThemeMaterial {}
    readonly property QtObject omarchy: ThemeOmarchy {}

    readonly property var theme: Config.theme === "material" ? material : omarchy

    readonly property var colors: root.theme.colors
    readonly property var m3colors: root.theme.m3colors
    readonly property var rounding: root.theme.rounding
    readonly property var font: root.theme.font
    readonly property var sizes: root.theme.sizes

    // Motion is shared: end-4's expressive M3 curves read well in both styles
    // and none of it is palette-dependent.
    readonly property QtObject animationCurves: QtObject {
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1]
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveEffectsDuration: 200
    }

    readonly property QtObject animation: QtObject {
        readonly property QtObject elementMoveEnter: QtObject {
            readonly property int duration: 400
            readonly property int type: Easing.BezierSpline
            readonly property list<real> bezierCurve: root.animationCurves.emphasizedDecel
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        readonly property QtObject elementMoveFast: QtObject {
            readonly property int duration: root.animationCurves.expressiveEffectsDuration
            readonly property int type: Easing.BezierSpline
            readonly property list<real> bezierCurve: root.animationCurves.expressiveEffects
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
        }

        readonly property QtObject elementResize: QtObject {
            readonly property int duration: 300
            readonly property int type: Easing.BezierSpline
            readonly property list<real> bezierCurve: root.animationCurves.emphasized
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementResize.duration
                    easing.type: root.animation.elementResize.type
                    easing.bezierCurve: root.animation.elementResize.bezierCurve
                }
            }
        }
    }
}
