import QtQuick

// A thin stand-in for end-4's AbstractBackgroundWidget: the card only ever
// needed a hover-tracking MouseArea with a `selected` flag and a couple of
// no-op hooks for the widget canvas it used to live on. Placement here belongs
// to the plugin's layer shell surface, so the drag machinery is gone.
MouseArea {
    id: root

    property string configEntryName: ""
    property bool selected: false
    property bool draggable: false
    property bool visibleWhenLocked: true

    // Raised by the card's move grip. The surface that holds the card answers
    // them, because only it knows where the card is on screen.
    signal moveStarted(real pointerX, real pointerY)
    signal moved(real pointerX, real pointerY)
    signal moveFinished()

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    width: implicitWidth
    height: implicitHeight
    cursorShape: root.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor

    function commitPosition() {}
    function requestDelete() {}
}
