import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// The card on the wallpaper.
//
// Three things make it behave like a desktop widget rather than an overlay:
//
//   * WlrLayer.Bottom sits above the wallpaper and below every application
//     window, so the card is there when you look at the desktop and gone when
//     you are working.
//   * The surface is sized to the card and anchored to one corner, not stretched
//     over the screen — a full-screen surface would swallow the double-click
//     Omarchy uses on empty wallpaper.
//   * Dragging the card's move grip expands the surface to the whole screen for
//     the duration of the drag and lifts it to the top layer. Without that the
//     pointer would leave the card-sized surface a few pixels in and the drag
//     would stop dead.
Item {
  id: root

  property bool showCard: true
  // A corner name, or "free" once the card has been dragged somewhere itself.
  property string position: "top-right"
  property real freeX: 0
  property real freeY: 0
  property string monitor: ""
  property real marginX: 28
  property real marginY: 20

  // Where a free card was put, as the card's top-left in screen pixels.
  signal positionPicked(real x, real y)

  readonly property bool free: root.position === "free"
  // What the bar reserves at the top. Presets are placed inside the usable area
  // by the compositor; a free card is placed by hand, so it has to keep clear of
  // the bar itself.
  readonly property real barInset: Style.bar.sizeHorizontal + Style.gapsOut

  readonly property var spot: {
    switch (root.position) {
      case "top-left": return { top: true, left: true }
      case "top-center": return { top: true }
      case "top-right": return { top: true, right: true }
      case "middle-left": return { left: true }
      case "middle-right": return { right: true }
      case "bottom-left": return { bottom: true, left: true }
      case "bottom-center": return { bottom: true }
      // A hand-placed card is pinned by its top-left and sized by the card.
      // Falling through to the default would anchor the opposite edges too and
      // stretch the surface to the bottom-right corner of the screen.
      case "free": return {}
      default: return { bottom: true, right: true }
    }
  }

  // An empty `monitor` means every screen. A name that matches nothing yields no
  // surface, which is the honest outcome of asking for an absent screen.
  readonly property var targetScreens: {
    var wanted = String(root.monitor || "")
    if (wanted === "") return Quickshell.screens
    var out = []
    for (var i = 0; i < Quickshell.screens.length; i++)
      if (Quickshell.screens[i] && Quickshell.screens[i].name === wanted) out.push(Quickshell.screens[i])
    return out
  }

  Variants {
    model: root.targetScreens

    PanelWindow {
      id: surface
      required property var modelData

      // Room for the card's shadow; the surface itself is transparent.
      readonly property real shadowPad: 14

      property bool dragging: false
      property real dragCardX: 0
      property real dragCardY: 0
      // Where inside the card the pointer took hold, so the card does not jump
      // under the cursor when the drag starts.
      property real grabOffX: 0
      property real grabOffY: 0

      readonly property real screenW: surface.screen ? surface.screen.width : 0
      readonly property real screenH: surface.screen ? surface.screen.height : 0

      screen: modelData
      visible: root.showCard
      color: "transparent"

      WlrLayershell.namespace: "omarchy-media-lyrics"
      // A parked card stays under the windows; a dragged one has to be over
      // everything, or the pointer would be handed to whatever it passed over.
      WlrLayershell.layer: surface.dragging ? WlrLayer.Top : WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      // Presets borrow the compositor's placement, so they keep clear of the bar.
      // A hand-placed card measures from the true screen edge instead, which is
      // what makes its stored coordinates mean what they say.
      exclusionMode: (root.free || surface.dragging) ? ExclusionMode.Ignore : ExclusionMode.Normal
      exclusiveZone: 0

      anchors {
        top: surface.dragging || root.free || root.spot.top === true
        bottom: surface.dragging || root.spot.bottom === true
        left: surface.dragging || root.free || root.spot.left === true
        right: surface.dragging || root.spot.right === true
      }
      margins {
        top: surface.dragging ? 0 : (root.free ? surface.clampWindowY(root.freeY) : root.marginY)
        bottom: surface.dragging ? 0 : root.marginY
        left: surface.dragging ? 0 : (root.free ? surface.clampWindowX(root.freeX) : root.marginX)
        right: surface.dragging ? 0 : root.marginX
      }

      implicitWidth: surface.dragging ? surface.screenW : card.implicitWidth + surface.shadowPad * 2
      implicitHeight: surface.dragging ? surface.screenH : card.implicitHeight + surface.shadowPad * 2

      // Where the card sits on screen right now, before any drag has started.
      // Presets are placed by the compositor inside the usable area, which is
      // why the top ones carry the bar's reserved height.
      function parkedCardX() {
        if (root.free) return root.freeX + surface.shadowPad
        if (root.spot.left === true) return root.marginX + surface.shadowPad
        if (root.spot.right === true) return surface.screenW - root.marginX - card.implicitWidth
        return (surface.screenW - card.implicitWidth) / 2
      }

      function parkedCardY() {
        if (root.free) return root.freeY + surface.shadowPad
        if (root.spot.top === true)
          return root.barInset + root.marginY + surface.shadowPad
        if (root.spot.bottom === true) return surface.screenH - root.marginY - card.implicitHeight
        return (surface.screenH - card.implicitHeight) / 2
      }

      function clampX(x) {
        return Math.max(0, Math.min(x, Math.max(0, surface.screenW - card.implicitWidth)))
      }

      function clampY(y) {
        return Math.max(root.barInset, Math.min(y, Math.max(0, surface.screenH - card.implicitHeight)))
      }

      // The same limits for the stored position, so a coordinate written by
      // hand, or left over from a bigger screen, still lands on this one.
      function clampWindowX(x) {
        var span = card.implicitWidth + surface.shadowPad * 2
        return Math.max(0, Math.min(x, Math.max(0, surface.screenW - span)))
      }

      function clampWindowY(y) {
        var span = card.implicitHeight + surface.shadowPad * 2
        return Math.max(0, Math.min(y, Math.max(0, surface.screenH - span)))
      }

      function beginMove(pointerX, pointerY) {
        surface.grabOffX = pointerX - surface.shadowPad
        surface.grabOffY = pointerY - surface.shadowPad
        surface.dragCardX = surface.clampX(surface.parkedCardX())
        surface.dragCardY = surface.clampY(surface.parkedCardY())
        surface.dragging = true
      }

      function updateMove(pointerX, pointerY) {
        if (!surface.dragging) return
        surface.dragCardX = surface.clampX(pointerX - surface.grabOffX)
        surface.dragCardY = surface.clampY(pointerY - surface.grabOffY)
      }

      function endMove() {
        if (!surface.dragging) return
        surface.dragging = false
        root.positionPicked(surface.dragCardX - surface.shadowPad,
                            surface.dragCardY - surface.shadowPad)
      }

      MediaCard {
        id: card
        // An explicit position in both cases: anchoring would fight the drag.
        x: surface.dragging ? surface.dragCardX : surface.shadowPad
        y: surface.dragging ? surface.dragCardY : surface.shadowPad
        onMoveStarted: (pointerX, pointerY) => surface.beginMove(pointerX, pointerY)
        onMoved: (pointerX, pointerY) => surface.updateMove(pointerX, pointerY)
        onMoveFinished: surface.endMove()
      }
    }
  }
}
