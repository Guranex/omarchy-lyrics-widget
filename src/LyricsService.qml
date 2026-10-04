pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property MprisPlayer activePlayer: MprisController.activePlayer

    property var lyricsLines: []
    property int activeIndex: -1
    property string status: "loading"
    property var slots: ["", "", "", "", "", "", ""]

    readonly property int before: 3
    readonly property int after:  3
    readonly property int total:  7

    function buildSlots(idx) {
        let result = []
        for (let i = 0; i < root.total; i++) {
            let lineIdx = idx - root.before + i
            if (lineIdx >= 0 && lineIdx < root.lyricsLines.length)
                result.push(root.lyricsLines[lineIdx].text || "♪")
            else
                result.push("")
        }
        return result
    }

    readonly property bool playing: root.activePlayer?.isPlaying ?? false
    readonly property bool synced: root.status === "ok" && root.lyricsLines.length > 0
    readonly property real leadSeconds: 0.15

    property real basePosition: 0
    property real baseTime: Date.now()

    function currentPosition() {
        return root.playing ? root.basePosition + (Date.now() - root.baseTime) / 1000 : root.basePosition
    }

    function resync() {
        if (!root.activePlayer) return
        root.activePlayer.positionChanged()
        readPositionTimer.restart()
    }

    function indexAt(pos) {
        const lines = root.lyricsLines
        let low = 0
        let high = lines.length - 1
        let result = -1
        while (low <= high) {
            const mid = (low + high) >> 1
            if (lines[mid].time <= pos) {
                result = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return result
    }

    function update() {
        boundaryTimer.stop()
        if (!root.synced) return
        const idx = root.indexAt(root.currentPosition() + root.leadSeconds)
        if (idx !== root.activeIndex) {
            root.activeIndex = idx
            root.slots = root.buildSlots(idx)
        }
        const next = root.lyricsLines[idx + 1]
        if (!root.playing || !next) return
        const delay = (next.time - root.leadSeconds - root.currentPosition()) * 1000
        boundaryTimer.interval = Math.max(1, Math.ceil(delay))
        boundaryTimer.start()
    }

    Timer {
        id: readPositionTimer
        interval: 80
        onTriggered: {
            root.basePosition = root.activePlayer?.position ?? 0
            root.baseTime = Date.now()
            root.update()
        }
    }

    Timer {
        id: boundaryTimer
        onTriggered: root.update()
    }

    Timer {
        id: driftTimer
        interval: 4000
        repeat: true
        running: root.synced && root.playing
        onTriggered: root.resync()
    }

    Process {
        id: lyricsProc
        running: false
        stdout: SplitParser {
            onRead: data => {
                const trimmed = data.trim()
                if (trimmed === "not_found") { root.status = "not_found"; return }
                if (trimmed === "no_info")   { root.status = "no_info";   return }

                const parts = trimmed.split("§")
                if (parts.length < 3) return
                if (parts[parts.length - 1].trim() !== "ok") return

                let lines = []
                for (let i = 0; i < parts.length - 1; i += 2) {
                    const t = parseFloat(parts[i])
                    const txt = parts[i + 1] || ""
                    if (!isNaN(t)) lines.push({ time: t, text: txt })
                }

                if (lines.length === 0) { root.status = "not_found"; return }

                root.lyricsLines = lines
                root.activeIndex = -1
                root.slots = root.buildSlots(-1)
                root.status = "ok"
                root.resync()
            }
        }

        // A script that cannot run at all — no python3, a moved file, a broken
        // interpreter — prints nothing, which would leave the panel spinning on
        // "loading" for good. A silent exit is the same answer as a miss.
        onExited: {
            if (root.status === "loading") root.status = "not_found"
        }
    }

    function restartLyrics() {
        lyricsProc.running = false
        boundaryTimer.stop()
        root.lyricsLines = []
        root.activeIndex = -1
        root.slots = ["", "", "", "", "", "", ""]
        root.status = "loading"

        // Nothing to fetch for a card nobody can see; the panel is only ever
        // read from the card. Hiding it also stops the position timers, because
        // `synced` goes false with the status.
        if (!Config.cardVisible) {
            root.status = "idle"
            return
        }

        const title    = root.activePlayer?.trackTitle  ?? ""
        const artist   = root.activePlayer?.trackArtist ?? ""
        const duration = root.activePlayer?.length       ?? 0

        if (!title || !artist) { root.status = "no_info"; return }

        lyricsProc.command = [
            "python3",
            `${Directories.scriptPath}/lyrics/lyrics.py`,
            title, artist, String(Math.floor(duration))
        ]
        lyricsProc.running = true
    }

    Connections {
        target: root.activePlayer
        function onTrackTitleChanged() { root.restartLyrics() }
        function onPlaybackStateChanged() { root.resync() }
    }

    // The Connections above cannot fire for the player that is already playing
    // when this service is built: the target appears with its title already set,
    // so no title change is ever emitted and the lyrics would stay blank until
    // the next track. Watching the controller covers start-up, plugin enable,
    // and hot-reload — all of which end-4's long-running shell never hit.
    Connections {
        target: MprisController
        function onActivePlayerChanged() { root.restartLyrics() }
    }

    // Coming back into view is a fresh start: whatever was playing while the
    // card was hidden was never fetched.
    Connections {
        target: Config
        function onCardVisibleChanged() { root.restartLyrics() }
    }

    Component.onCompleted: root.restartLyrics()
}
