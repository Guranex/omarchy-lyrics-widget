pragma Singleton
import QtQuick

// end-4 routes user-facing strings through a translation singleton. The card
// only needs two of them, and Omarchy ships one language per shell, so this
// keeps the call sites unchanged and the strings as written.
QtObject {
    function tr(text) {
        return text
    }
}
