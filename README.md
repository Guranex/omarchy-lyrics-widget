# Media Lyrics Card

The lyrics media player card from [end-4's dots-hyprland](https://github.com/end-4/dots-hyprland)
(`illogical-impulse`), ported to the Omarchy shell as a desktop widget.

Cover art, artist and title, a rounded transport pill, and an expandable panel of
synced lyrics — on the wallpaper, above it and below your windows, restyled by
the active Omarchy theme. Enable it and it is there; disable it and nothing runs.

Two styles ship: **Omarchy** (the shell's own popover palette and type scale,
Nerd Font glyphs) and **Material** (end-4's Material 3 baseline, with the
cookie-shaped transport).

## Install

```bash
omarchy plugin add https://github.com/Guranex/Omarchy-Lyrics-Widget.git --enable
omarchy plugin enable io.github.guranex.media-lyrics --section right
```

For local development, point Omarchy at a checkout by copying it into
`~/.config/omarchy/plugins/io.github.guranex.media-lyrics/` and reloading:

```bash
scripts/dev-install        # sync this checkout into the plugin dir and reload
```

## Uninstall

```bash
omarchy plugin remove io.github.guranex.media-lyrics
```

That deletes the plugin directory, which is where all of its code, its lyrics
helper and its licence live. Nothing outside it is touched.

Two things survive on purpose:

- **Your settings** live on this plugin's entry in `~/.config/omarchy/shell.json`
  and are removed along with the entry. Nothing else in that file is rewritten.
- **Cached cover art** stays in `~/.cache/omarchy-media-lyrics/`; delete the
  directory if you want it gone.

Removing the plugin also removes its bar entry. Re-adding starts from the
defaults.

## Requirements

| | |
|---|---|
| **Omarchy 4.0 "Quattro" or newer** | The plugin API and the Quickshell-based bar |
| A **media player that speaks MPRIS** | Spotify, mpv with `mpv-mpris`, most browsers. With nothing playing the card shows its placeholder state |
| **`python3`** | The lyrics helper is a Python script. Ships with Omarchy |
| **`curl`** | Cover-art download. Ships with Omarchy |
| **Network access to [lrclib.net](https://lrclib.net)** | Lyrics. Only the track's title, artist and duration are sent, as query parameters — no account, no API key, nothing else. A song that cannot be matched simply reports "not found" |
| A **Nerd Font** | Omarchy's own bar font supplies the icons. Material Symbols is used instead if you have it installed and pick that in the popup |

The plugin reads MPRIS metadata, writes its own settings entry, downloads cover
art into `~/.cache/omarchy-media-lyrics/`, and runs two commands of its own:
`python3 scripts/lyrics/lyrics.py …` and `bash -c '… curl …'`. It never
requests privileges, never writes outside those two locations, and registers no
global IPC names beyond its own `mediaLyrics` and `media-lyrics-bar` targets.

## Using it

**The bar icon.** Left-click opens the settings popup; right-click shows or hides
the card without losing the rest of your setup.

**The card.** It sits in the corner you pick in the popup.

- The **lyrics button** (the note-on-paper glyph) opens and closes the lyrics
  panel; the card grows to fit it and shrinks back.
- The **cookie** is play/pause. Skip back and next sit either side.
- **Drag the corner handle** to switch between the five sizes (`1x1`, `1x2`,
  `2x2`, `1x3`, `2x3`); the size is remembered. Lock it from the popup if you
  keep catching the handle.

**Moving it.** The dotted grip in the top-right corner takes hold after a short
press — then the card follows the pointer anywhere on the screen, and stays
where you drop it. A plain click on the grip does nothing, so brushing the
corner cannot nudge the card, and the two handles never overlap: the grip
carries, the bottom-right corner resizes.

While a card is held, the widget lifts to the top layer and covers the whole
screen for the duration of the drag, so the pointer cannot fall off a
card-sized surface halfway across. It drops back to the wallpaper layer on
release. Putting the card back on a corner is one click in the popup; the
**Free** chip returns it to where you last dropped it.

Lyrics come from [LRCLIB](https://lrclib.net) and are matched on the playing
track's title and artist. With no match the panel says so; nothing is cached
beyond the cover art in `~/.cache/omarchy-media-lyrics/`.

## Styles

**Omarchy** follows the shell's own singletons (`Color`, `Style`), so a theme
switch restyles the card in the same frame as the bar and the popups. **Material**
is end-4's Material 3 baseline — the same palette, corner radii and type scale
its `Appearance` singleton ships.

Because Omarchy ships Nerd Fonts rather than Material Symbols, icons resolve
through a small map: the same codepoints the stock Omarchy media widget and
OmaWidgets use. Install a Material Symbols font and the **Icons** row can use it
instead; leave it on **Auto** and it picks whichever is present.

## IPC

```bash
omarchy shell mediaLyrics toggle          # show/hide the card
omarchy shell mediaLyrics show | hide
omarchy shell mediaLyrics theme material  # or omarchy
omarchy shell mediaLyrics size 2x2        # 1x1 · 1x2 · 2x2 · 1x3 · 2x3
omarchy shell mediaLyrics position bottom-right
omarchy shell mediaLyrics move 620 430   # park it at a point, in screen pixels
omarchy shell mediaLyrics lock true
omarchy shell mediaLyrics lyricsPanel     # open/close the lyrics panel
omarchy shell mediaLyrics nowPlaying      # "playing<TAB>title<TAB>artist"
omarchy shell mediaLyrics lyrics          # "ok<TAB>line<TAB>count"
omarchy shell mediaLyrics reloadLyrics
omarchy shell mediaLyrics status
```

`omarchy shell media-lyrics-bar toggle` opens the settings popup itself, which
is handy for a keybind.

## Settings

Everything lives on this plugin's entry in `~/.config/omarchy/shell.json`; the
popup is the only writer apart from a finished drag. Defaults: shown, Omarchy
style, auto icons, `1x3`, top-right, 28/20 px margins, every monitor, shadow on,
size unlocked. A dragged card stores `position: "free"` with `freeX` / `freeY`.

The service reads that file itself and watches it, rather than waiting to be
handed the settings. That matters on a replacement bar: Omarchy gives a
third-party bar a deliberately service-less facade, so a popup's writes never
reach the plugin's own service by the usual route. Reading the file makes every
writer equal — the popup, `omarchy` commands, a hand edit, and a drag.

## What was reused, and what changed

The card is end-4's code, not a reimplementation. Vendored nearly verbatim:

```
src/MediaCard.qml          ← modules/ii/background/widgets/media/MediaWidget.qml
src/Lyrics.qml             ← modules/common/widgets/Lyrics.qml
src/LyricsService.qml      ← services/LyricsService.qml
src/MprisController.qml    ← services/MprisController.qml
src/{StyledText,StyledImage,RippleButton,MaterialSymbol,StyledRectangularShadow,
     MaterialLoadingIndicator,MaterialShape,MaterialShapeWrappedMaterialSymbol,
     WidgetCard,ResizeHandler,ColorUtils}.qml
src/shapes/                ← modules/common/widgets/shapes/
scripts/lyrics/lyrics.py   ← scripts/lyrics/lyrics.py
```

What had to change, and why:

- **Imports.** end-4's `qs.modules.*` became one local module (`src/qmldir`).
- **The base class.** `AbstractBackgroundWidget`/`AbstractWidget` (end-4's widget
  canvas and its drag/config machinery) was replaced by `WidgetBase`, a
  hover-aware `MouseArea`. Placement belongs to the plugin's layer-shell surface
  now, so a card resize writes to this plugin's settings instead of end-4's
  config entry.
- **Moving.** `src/MoveHandler.qml` is new (end-4 pinned its widgets to a corner,
  so it had nothing to reuse). `DesktopSurface` grew free positioning and the
  expand-for-the-drag trick described above.
- **The theme.** `Appearance` resolves to `ThemeOmarchy` or `ThemeMaterial`; the
  card source never learned about the switch.
- **Config.** A small singleton exposes the handful of `Config.options.*` fields
  end-4's code reads, backed by this plugin's settings.
- **Two bug fixes.** end-4's `LyricsService` only watched `trackTitleChanged`, so
  lyrics never loaded for a track that was already playing when the shell
  started — which is exactly what happens when a plugin is enabled mid-song; it
  now watches the controller too. And `MediaCard.artUrl` defaults to `""`
  instead of `undefined`, which was filling the log with type warnings.

## Licensing

This plugin is a derivative work of
[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland), which is
**GPL-3.0**, and is therefore GPL-3.0 as well — see [LICENSE](LICENSE). The
Material shape geometry under `src/shapes/` keeps its own Apache-2.0 licence
(`src/shapes/LICENSE`). `src/MprisController.qml` is redistributed from end-4
with its upstream note intact. Lyrics are fetched from LRCLIB at runtime.
