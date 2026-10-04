// Settings for the media lyrics card.
//
// The stored object is untrusted: JSON in ~/.config/omarchy/shell.json that a
// person or another tool may have hand-edited. Anything unrecognised falls back
// to a default, every number is clamped, so a bad field produces a working card
// rather than a broken binding.
var THEMES = ["omarchy", "material"]
var ICON_STYLES = ["auto", "nerd", "material"]
var SIZE_MODES = ["1x1", "1x2", "2x2", "1x3", "2x3"]
// "free" is not a corner: it means the card was dragged and holds its own
// coordinates (freeX / freeY). It is accepted here so a saved free card
// survives normalisation.
var FREE = "free"
var POSITIONS = [
  "top-left", "top-center", "top-right",
  "middle-left", "middle-right",
  "bottom-left", "bottom-center", "bottom-right", "free"
]

var DEFAULTS = {
  desktop: true,
  theme: "omarchy",
  iconStyle: "auto",
  sizeMode: "1x3",
  position: "top-right",
  marginX: 28,
  marginY: 20,
  freeX: 0,
  freeY: 0,
  monitor: "",
  preferredPlayer: "",
  filterDuplicatePlayers: true,
  shadow: true,
  locked: false
}

function num(value, fallback, min, max) {
  var n = Number(value)
  if (!isFinite(n)) return fallback
  if (n < min) return min
  if (n > max) return max
  return n
}

function oneOf(value, allowed, fallback) {
  var s = String(value === undefined || value === null ? "" : value)
  return allowed.indexOf(s) === -1 ? fallback : s
}

function bool(value, fallback) {
  if (value === undefined || value === null) return fallback
  if (value === true || value === "true") return true
  if (value === false || value === "false") return false
  return fallback
}

function str(value, fallback) {
  if (value === undefined || value === null) return fallback
  return String(value)
}

function normalize(raw) {
  var r = raw && typeof raw === "object" ? raw : {}
  return {
    desktop: bool(r.desktop, DEFAULTS.desktop),
    theme: oneOf(r.theme, THEMES, DEFAULTS.theme),
    iconStyle: oneOf(r.iconStyle, ICON_STYLES, DEFAULTS.iconStyle),
    sizeMode: oneOf(r.sizeMode, SIZE_MODES, DEFAULTS.sizeMode),
    position: oneOf(r.position, POSITIONS, DEFAULTS.position),
    marginX: num(r.marginX, DEFAULTS.marginX, 0, 400),
    marginY: num(r.marginY, DEFAULTS.marginY, 0, 400),
    freeX: num(r.freeX, DEFAULTS.freeX, -400, 20000),
    freeY: num(r.freeY, DEFAULTS.freeY, -400, 20000),
    monitor: str(r.monitor, DEFAULTS.monitor),
    preferredPlayer: str(r.preferredPlayer, DEFAULTS.preferredPlayer),
    filterDuplicatePlayers: bool(r.filterDuplicatePlayers, DEFAULTS.filterDuplicatePlayers),
    shadow: bool(r.shadow, DEFAULTS.shadow),
    locked: bool(r.locked, DEFAULTS.locked)
  }
}

// The settings live on the bar entry in shell.json when one exists, and on the
// top-level plugin entry when the plugin is enabled without a bar widget.
function fromBarConfig(barConfig, pluginId) {
  var id = String(pluginId || "")
  var cfg = barConfig && typeof barConfig === "object" ? barConfig : {}
  var layout = cfg.layout && typeof cfg.layout === "object" ? cfg.layout : {}
  var sections = ["left", "center", "right"]
  for (var s = 0; s < sections.length; s++) {
    var entries = layout[sections[s]]
    if (!Array.isArray(entries)) continue
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      if (entry && typeof entry === "object" && String(entry.id || "") === id) return entry
    }
  }
  if (Array.isArray(cfg.plugins)) {
    for (var j = 0; j < cfg.plugins.length; j++) {
      var p = cfg.plugins[j]
      if (p && typeof p === "object" && String(p.id || "") === id) return p
    }
  }
  return {}
}

if (typeof module !== "undefined") {
  module.exports = {
    DEFAULTS: DEFAULTS,
    THEMES: THEMES,
    ICON_STYLES: ICON_STYLES,
    SIZE_MODES: SIZE_MODES,
    POSITIONS: POSITIONS,
    normalize: normalize,
    fromBarConfig: fromBarConfig
  }
}
