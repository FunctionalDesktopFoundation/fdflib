import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property string variant: "default"
    property string animState: ""

    property color bgColor: {
        if (!enabled) return Theme.palette.surfaceHover
        switch (variant) {
            case "primary":  return Theme.palette.accent
            case "delete":   return Theme.palette.deleteBg
            case "danger":   return Theme.palette.errorContainer
            case "ghost":    return "transparent"
            case "subtle":   return Theme.palette.surfaceActive
            default:         return Theme.palette.surfaceActive
        }
    }
    property color bgHoverColor: {
        if (!enabled) return Theme.palette.surfaceHover
        switch (variant) {
            case "primary":  return Qt.lighter(Theme.palette.accent, 1.1)
            case "delete":   return Theme.palette.deleteBgHover
            case "danger":   return Qt.lighter(Theme.palette.errorContainer, 1.2)
            case "ghost":    return Theme.palette.surfaceHover
            case "subtle":   return Theme.palette.surfacePressed
            default:         return Theme.palette.surfacePressed
        }
    }
    property color textColor: {
        if (!enabled) return Theme.palette.textDim
        switch (variant) {
            case "primary":  return Theme.palette.onAccent
            case "delete":   return Theme.palette.delete
            case "danger":   return Theme.palette.error
            case "ghost":    return Theme.palette.textDim
            case "subtle":   return Theme.palette.onSurface
            default:         return Theme.palette.onSurface
        }
    }
    property color textHoverColor: {
        if (!enabled) return Theme.palette.textDim
        switch (variant) {
            case "delete":   return Theme.palette.deleteHover
            case "ghost":    return Theme.palette.onSurface
            default:         return textColor
        }
    }
    property color borderColor: {
        if (root.noBorder) return "transparent"
        switch (variant) {
            case "ghost":    return Theme.palette.border
            case "subtle":   return Theme.palette.border
            default:         return "transparent"
        }
    }

    property int fontSize: Theme.fsSm
    property int radiusSize: Theme.rSm
    property int minWidth: 0
    property string fontFam: Theme.fontSans
    property int fontWt: Font.Medium
    property bool busy: false
    property bool iconOnly: text === "" && icon !== ""
    property bool noBorder: false

    signal clicked()

    implicitWidth: iconOnly ? implicitHeight : Math.max(minWidth, contentRow.implicitWidth + Theme.spMd * 2)
    implicitHeight: iconOnly ? (Theme.btnH + 6) : Theme.btnH
    radius: iconOnly ? implicitHeight / 2 : radiusSize
    color: tap.containsMouse && !tap.pressed ? bgHoverColor : (tap.pressed ? Qt.darker(bgColor, 1.15) : bgColor)
    border.color: borderColor
    border.width: root.noBorder ? 0 : (variant === "ghost" || variant === "subtle" ? 1 : 0)
    opacity: root.enabled ? 1.0 : 0.4

    scale: root.enabled ? 1.0 : 1.0

    Accessible.role: Accessible.Button
    Accessible.name: root.text || root.icon || "Button"

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spXs

        FIcon {
            visible: root.icon !== ""
            icon: root.icon
            pixelSize: root.fontSize + (root.iconOnly ? 2 : 0)
            color: tap.containsMouse ? root.textHoverColor : root.textColor
        }
        Text {
            visible: root.text !== ""
            text: root.text
            font.family: root.fontFam
            font.pixelSize: root.fontSize
            font.weight: root.fontWt
            color: tap.containsMouse ? root.textHoverColor : root.textColor
        }
    }

    TapHandler {
        id: tap
        enabled: root.enabled && !root.busy
        onTapped: root.clicked()
    }

    SequentialAnimation {
        id: successAnim
        PauseAnimation { duration: 1800 }
        onFinished: root.animState = ""
    }

    function startLoading() {
        root.busy = true
        root.animState = "loading"
    }
    function done() {
        root.busy = false
        root.animState = "success"
        successAnim.restart()
    }
    function fail() {
        root.busy = false
        root.animState = ""
        successAnim.stop()
    }
    function reset() {
        root.busy = false
        root.animState = ""
        successAnim.stop()
    }
}
