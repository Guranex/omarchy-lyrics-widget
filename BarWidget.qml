import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "model/Settings.js" as Settings

// The bar entry: an icon, and a popup that configures the card.
//
// It is also the plugin's only write path to shell.json. The service reads the
// same entry but never edits it, so a setting can only change in one place.
Panel {
  id: root

  ipcTarget: "media-lyrics-bar"
  // The base Panel IPC target is all this widget needs: open/close/show/hide/
  // toggle, so a keybind can summon the popup.
  manageIpc: true

  // The bar host injects `settings` and re-injects it when shell.json changes,
  // which makes this widget the live view of them.
  readonly property var config: Settings.normalize(settings)
  readonly property var service: bar && bar.shell && typeof bar.shell.serviceFor === "function"
    ? bar.shell.serviceFor(moduleName) : null

  readonly property color iconColor: config.desktop ? barForeground : Qt.darker(barForeground, 1.55)

  function write(changes) {
    if (!bar || !bar.shell || typeof bar.shell.updateEntryInline !== "function") return
    var merged = ({})
    for (var key in settings) merged[key] = settings[key]
    for (var change in changes) merged[change] = changes[change]
    var next = Settings.normalize(merged)
    settings = next
    bar.shell.updateEntryInline(moduleName, next)
  }

  function writeOne(key, value) {
    var change = ({})
    change[key] = value
    write(change)
  }

  // The service acts on the settings a beat before shell.json is re-read, so
  // push rather than let it read back stale values.
  function pushSettings() {
    if (service) service.applySettings(settings)
  }
  onSettingsChanged: pushSettings()
  onServiceChanged: pushSettings()
  Component.onCompleted: pushSettings()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰝚"
    foreground: root.iconColor
    tooltipText: root.config.desktop ? "Media lyrics · shown" : "Media lyrics · hidden"
    onPressed: function (pressedButton) {
      if (pressedButton === Qt.RightButton) root.write({ desktop: !root.config.desktop })
      else root.toggle()
    }
  }

  component Chip: Rectangle {
    id: chip
    property string label: ""
    property bool active: false
    signal picked()

    implicitWidth: chipText.implicitWidth + Style.spacing.lg * 2
    implicitHeight: Style.space(24)
    radius: Math.max(4, Style.cornerRadius)
    color: chip.active ? Util.alpha(Color.accent, 0.22) : Util.alpha(Color.popups.text, 0.06)
    border.width: 1
    border.color: chip.active ? Color.accent : Util.alpha(Color.popups.border, 0.4)

    Text {
      id: chipText
      anchors.centerIn: parent
      text: chip.label
      color: Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
    }
    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: chip.picked()
    }
  }

  component SettingRow: Item {
    id: row
    property string label: ""
    default property alias content: items.children
    width: parent ? parent.width : 0
    implicitHeight: Math.max(labelText.implicitHeight, items.implicitHeight)

    Text {
      id: labelText
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: row.label
      color: Util.alpha(Color.popups.text, 0.65)
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
    }
    Row {
      id: items
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.spacing.xs
    }
  }

  // For option sets too wide for one line: the label sits above a Flow that
  // wraps, which is what the eight screen positions need.
  component SettingBlock: Item {
    id: block
    property string label: ""
    default property alias content: blockFlow.children
    width: parent ? parent.width : 0
    implicitHeight: labelText.implicitHeight + Style.spacing.xs + blockFlow.implicitHeight

    Text {
      id: labelText
      anchors.left: parent.left
      anchors.top: parent.top
      text: block.label
      color: Util.alpha(Color.popups.text, 0.65)
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
    }
    Flow {
      id: blockFlow
      anchors.top: labelText.bottom
      anchors.topMargin: Style.spacing.xs
      width: parent.width
      spacing: Style.spacing.xs
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(300))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      anchors.fill: parent
      onCloseRequested: root.close()

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
          id: content
          width: parent.width
          spacing: Style.spacing.md

          Text {
            text: "Media lyrics"
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }

          SettingRow {
            label: "On the desktop"
            Chip { label: "Shown"; active: root.config.desktop; onPicked: root.write({ desktop: true }) }
            Chip { label: "Hidden"; active: !root.config.desktop; onPicked: root.write({ desktop: false }) }
          }

          SettingRow {
            label: "Style"
            Chip { label: "Omarchy"; active: root.config.theme === "omarchy"; onPicked: root.writeOne("theme", "omarchy") }
            Chip { label: "Material"; active: root.config.theme === "material"; onPicked: root.writeOne("theme", "material") }
          }

          SettingRow {
            label: "Icons"
            Chip { label: "Auto"; active: root.config.iconStyle === "auto"; onPicked: root.writeOne("iconStyle", "auto") }
            Chip { label: "Nerd"; active: root.config.iconStyle === "nerd"; onPicked: root.writeOne("iconStyle", "nerd") }
            Chip { label: "Material"; active: root.config.iconStyle === "material"; onPicked: root.writeOne("iconStyle", "material") }
          }

          SettingRow {
            label: "Size"
            Repeater {
              model: Settings.SIZE_MODES
              Chip {
                required property var modelData
                label: modelData
                active: root.config.sizeMode === modelData
                onPicked: root.writeOne("sizeMode", modelData)
              }
            }
          }

          SettingBlock {
            label: "Position"
            Repeater {
              model: Settings.POSITIONS
              Chip {
                required property var modelData
                // The presets are corners; "free" is where a drag left the card.
                label: modelData === "free" ? "Free" : modelData
                active: root.config.position === modelData
                onPicked: root.writeOne("position", modelData)
              }
            }
          }

          SettingRow {
            label: "Card"
            Chip { label: "Locked"; active: root.config.locked; onPicked: root.writeOne("locked", !root.config.locked) }
            Chip { label: "Shadow"; active: root.config.shadow; onPicked: root.writeOne("shadow", !root.config.shadow) }
          }
        }
      }
    }
  }
}
