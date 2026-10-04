import QtQuick

// The move grip on the card's top-right corner.
//
// A long press takes hold of the card; from then on the pointer carries it. A
// plain click does nothing, so the grip cannot be mistaken for a control, and
// the card is not nudged every time the corner is brushed.
//
// The grip only reports where the pointer is, in window coordinates. Moving the
// card is the surface's job: it is the only thing that knows where the card
// sits on screen, and it has to expand itself for the duration of the drag so
// the pointer cannot leave it.
Item {
    id: root

    required property Item anchorItem
    property bool hoverActive: false
    property bool locked: false
    property int holdMs: 260

    signal moveStarted(real pointerX, real pointerY)
    signal moved(real pointerX, real pointerY)
    signal moveFinished()

    property bool dragging: false

    width: 26
    height: 26
    anchors {
        right: root.anchorItem.right
        top: root.anchorItem.top
        rightMargin: 5
        topMargin: 5
    }
    // A grip that appears only on hover is one nobody finds. It stays visible
    // while the card can be moved, faint enough to sit in the corner of the
    // artwork, and comes up to full strength under the pointer.
    opacity: (root.hoverActive || area.containsMouse || root.dragging) ? 0.95 : 0.28
    visible: !root.locked

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    // Window coordinates. While the surface is expanded for a drag these are
    // screen coordinates, which is exactly what the surface wants.
    function windowPoint(mx, my) {
        return area.mapToItem(null, mx, my)
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding?.small ?? 6
        color: Appearance.colors.colPrimaryContainer
        opacity: 0.55
    }

    Grid {
        anchors.centerIn: parent
        columns: 2
        spacing: 2

        Repeater {
            model: 6
            Rectangle {
                width: 3
                height: 3
                radius: 1.5
                color: Appearance.colors.colOnPrimaryContainer
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        cursorShape: area.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        property real pressX: 0
        property real pressY: 0

        onPressed: function (mouse) {
            pressX = mouse.x
            pressY = mouse.y
            hold.restart()
        }
        onPositionChanged: function (mouse) {
            if (!root.dragging) return
            var point = root.windowPoint(mouse.x, mouse.y)
            root.moved(point.x, point.y)
        }
        onReleased: {
            hold.stop()
            if (!root.dragging) return
            root.dragging = false
            root.moveFinished()
        }
        onCanceled: {
            hold.stop()
            if (!root.dragging) return
            root.dragging = false
            root.moveFinished()
        }

        Timer {
            id: hold
            interval: root.holdMs
            onTriggered: {
                root.dragging = true
                var point = root.windowPoint(area.pressX, area.pressY)
                root.moveStarted(point.x, point.y)
            }
        }
    }
}
