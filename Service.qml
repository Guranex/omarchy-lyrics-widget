import QtQuick
import Quickshell
import Quickshell.Io
import "src"
import "model/Settings.js" as Settings

// The plugin's long-lived instance: it owns the settings, keeps the card's view
// of them (Config) in step, and holds the desktop layer the card is drawn on.
//
// Enabling or disabling the plugin is the on/off switch; within a run, the
// `desktop` setting (and the `mediaLyrics` IPC target) shows and hides the card.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property string omarchyPath: ""

  readonly property string pluginId: manifest && manifest.id
    ? String(manifest.id) : "io.github.guranex.media-lyrics"

  // Settings come from shell.json, and this reads the file itself rather than
  // waiting to be told.
  //
  // The obvious route — the bar widget pushing its settings here — does not
  // work under a replacement bar. Omarchy hands a third-party bar a deliberately
  // service-less facade (`pluginShellForBarEntry`), so `bar.shell.serviceFor()`
  // returns null and the popup's writes would never reach this object. Reading
  // the file makes every writer equal: the popup, `omarchy plugin` commands, a
  // hand edit, and the card's own drags.
  property var fileSettings: null

  // Pushed settings still win until the file has been read once, which keeps the
  // first frame of a freshly started shell from flashing defaults.
  property var pushedSettings: null
  readonly property var config: Settings.normalize(
    fileSettings !== null ? fileSettings
      : (pushedSettings !== null ? pushedSettings
        : (shell ? Settings.fromBarConfig(shell.barConfig, pluginId) : ({}))))

  FileView {
    id: shellConfigFile
    path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config"))
      + "/omarchy/shell.json"
    watchChanges: true
    printErrors: false
    onLoaded: root.readShellConfig(text())
    // `text()` is stale inside the change signal itself, so re-read through
    // reload() and let onLoaded hand over the new contents.
    onFileChanged: reload()
    onLoadFailed: root.fileSettings = null
  }

  // This plugin's own entry, wherever it lives in shell.json.
  function readShellConfig(raw) {
    var entry = null
    try {
      var parsed = JSON.parse(String(raw || "{}"))
      var layout = parsed && parsed.bar && parsed.bar.layout ? parsed.bar.layout : {}
      var sections = ["left", "center", "right"]
      for (var s = 0; s < sections.length && entry === null; s++) {
        var list = layout[sections[s]]
        if (!Array.isArray(list)) continue
        for (var i = 0; i < list.length; i++) {
          var candidate = list[i]
          if (candidate && typeof candidate === "object"
              && String(candidate.id || "") === root.pluginId) {
            entry = candidate
            break
          }
        }
      }
      if (entry === null && Array.isArray(parsed.plugins)) {
        for (var j = 0; j < parsed.plugins.length; j++) {
          var plugin = parsed.plugins[j]
          if (plugin && typeof plugin === "object"
              && String(plugin.id || "") === root.pluginId) {
            entry = plugin
            break
          }
        }
      }
    } catch (error) {
      entry = null
    }
    root.fileSettings = entry
  }

  function applySettings(next) {
    if (next === undefined || next === null) return
    if (Object.keys(next).length === 0) return
    pushedSettings = next
  }

  // The single write path: merge, normalise, apply locally, persist. Local
  // first so the card moves on the click that asked it to, without waiting for
  // shell.json to be re-read.
  function write(changes) {
    var merged = ({})
    for (var key in root.config) merged[key] = root.config[key]
    for (var change in changes) merged[change] = changes[change]
    var next = Settings.normalize(merged)
    // Apply locally first so the card moves on the click that asked it to,
    // rather than a file round-trip later. The write lands on the same values,
    // so the reload that follows changes nothing.
    root.fileSettings = next
    root.pushedSettings = next
    if (root.shell && typeof root.shell.updateEntryInline === "function")
      root.shell.updateEntryInline(root.pluginId, next)
    return next
  }

  // Hand the card's own view of the settings over, without letting the push
  // look like a user edit.
  function pushConfig() {
    Config.pushing = true
    Config.settings = root.config
    Config.sizeMode = root.config.sizeMode
    Config.cardVisible = root.config.desktop
    Config.pushing = false
  }

  onConfigChanged: root.pushConfig()
  Component.onCompleted: root.pushConfig()

  // A resize on the desktop card comes back as a settings write.
  Connections {
    target: Config
    function onSettingWritten(key, value) {
      if (key === "sizeMode") root.write({ sizeMode: value })
    }
  }

  DesktopSurface {
    showCard: root.config.desktop
    position: root.config.position
    freeX: root.config.freeX
    freeY: root.config.freeY
    monitor: root.config.monitor
    marginX: root.config.marginX
    marginY: root.config.marginY
    // A finished drag hands the card's new home back here, and this is what
    // turns "wherever the pointer left it" into a remembered position.
    onPositionPicked: (x, y) => root.write({ position: "free", freeX: x, freeY: y })
  }

  IpcHandler {
    target: "mediaLyrics"

    function show(): string { root.write({ desktop: true }); return "shown" }
    function hide(): string { root.write({ desktop: false }); return "hidden" }
    function toggle(): string {
      var next = !root.config.desktop
      root.write({ desktop: next })
      return next ? "shown" : "hidden"
    }

    function theme(name: string): string {
      var next = Settings.normalize(root.write({ theme: name }))
      return next.theme
    }
    function size(mode: string): string {
      var next = Settings.normalize(root.write({ sizeMode: mode }))
      return next.sizeMode
    }
    function position(where: string): string {
      var next = Settings.normalize(root.write({ position: where }))
      return next.position
    }
    // Put the card at a point on the screen, in screen pixels.
    function move(x: real, y: real): string {
      var next = Settings.normalize(root.write({ position: "free", freeX: x, freeY: y }))
      return next.position + "\t" + next.freeX + "\t" + next.freeY
    }
    function lock(value: string): string {
      var locked = String(value) === "true" || String(value) === "1"
      root.write({ locked: locked })
      return locked ? "locked" : "unlocked"
    }
    // Opens or closes the lyrics panel on the desktop card, for a keybind.
    function lyricsPanel(): string { Config.lyricsToggled(); return "ok" }

    // What the card is showing, for a keybind or a status line.
    function nowPlaying(): string {
      var player = MprisController.activePlayer
      if (!player) return "no player"
      return (player.isPlaying ? "playing" : "paused") + "\t"
        + (player.trackTitle || "") + "\t" + (player.trackArtist || "")
    }
    function lyrics(): string {
      return LyricsService.status + "\t" + LyricsService.activeIndex
        + "\t" + LyricsService.lyricsLines.length
    }
    function reloadLyrics(): string { LyricsService.restartLyrics(); return "ok" }
    function status(): string {
      return (root.config.desktop ? "shown" : "hidden") + "\t" + root.config.theme
        + "\t" + root.config.sizeMode + "\t" + root.config.position
    }
  }
}
