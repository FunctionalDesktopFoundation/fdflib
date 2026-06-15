import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int defaultDuration: 3000

    signal toastDismissed(string text, string variant)

    ListModel { id: toastModel }

    function show(text, icon, duration, variant) {
        toastModel.append({
            text: text || "",
            icon: icon || "",
            duration: duration || root.defaultDuration,
            variant: variant || "default"
        })
    }

    function info(text, dur) { show(text, "\uf05a", dur, "info") }
    function success(text, dur) { show(text, "\uf058", dur, "success") }
    function warn(text, dur) { show(text, "\uf071", dur, "warn") }
    function error(text, dur) { show(text, "\uf057", dur, "error") }

    function dismissRow(row) {
        toastModel.remove(row, 1)
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.spLg
        width: Math.min(380, root.width * 0.85)
        spacing: Theme.spSm

        Repeater {
            model: toastModel

            delegate: Rectangle {
                id: delegateRoot
                readonly property int _idx: index
                readonly property var _data: model

                Layout.fillWidth: true
                implicitHeight: layoutRow.implicitHeight + Theme.spLg * 2
                radius: Theme.rLg
                color: {
                    switch (variant) {
                        case "info":    return Qt.rgba(82/255, 148/255, 226/255, 0.95)
                        case "success": return Qt.rgba(74/255, 222/255, 128/255, 0.95)
                        case "warn":    return Qt.rgba(255/255, 159/255, 10/255, 0.95)
                        case "error":   return Qt.rgba(255/255, 69/255, 58/255, 0.95)
                        default:        return Theme.palette.surfaceHigh
                    }
                }
                border.width: variant === "default" ? 1 : 0
                border.color: variant === "default" ? Theme.palette.border : "transparent"

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 12; samples: 16
                    color: Qt.rgba(0, 0, 0, 0.45)
                }

                opacity: 0
                scale: 0.85

                Behavior on opacity { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }

                RowLayout {
                    id: layoutRow
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spLg
                    anchors.rightMargin: Theme.spLg
                    spacing: Theme.spMd

                    FIcon {
                        visible: model.icon !== ""
                        icon: model.icon
                        pixelSize: Theme.fsLg
                        color: model.variant === "default" ? Theme.palette.onSurface : "#FFFFFF"
                    }

                    Text {
                        text: model.text
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsBase
                        color: model.variant === "default" ? Theme.palette.onSurface : "#FFFFFF"
                        Layout.fillWidth: true
                        Layout.minimumWidth: 1
                        wrapMode: Text.Wrap
                    }
                }

                TapHandler {
                    onTapped: startExit()
                }

                function startExit() {
                    exitAnim.restart()
                    enterAnim.stop()
                }

                SequentialAnimation {
                    id: exitAnim
                    ParallelAnimation {
                        NumberAnimation { target: delegateRoot; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
                        NumberAnimation { target: delegateRoot; property: "scale"; to: 0.85; duration: 150; easing.type: Easing.InCubic }
                    }
                    ScriptAction {
                        script: {
                            toastDismissed(delegateRoot._data.text, delegateRoot._data.variant)
                            root.dismissRow(delegateRoot._idx)
                        }
                    }
                }

                Component.onCompleted: {
                    enterAnim.restart()
                }

                SequentialAnimation {
                    id: enterAnim
                    ParallelAnimation {
                        NumberAnimation { target: delegateRoot; property: "opacity"; from: 0; to: 1; duration: Theme.animNorm; easing.type: Easing.OutCubic }
                        NumberAnimation { target: delegateRoot; property: "scale"; from: 0.85; to: 1; duration: Theme.animSlow; easing.type: Easing.OutCubic }
                    }
                    PauseAnimation { duration: model.duration }
                    ScriptAction { script: startExit() }
                }

                Component.onDestruction: {
                    enterAnim.stop()
                    exitAnim.stop()
                }
            }
        }
    }
}
