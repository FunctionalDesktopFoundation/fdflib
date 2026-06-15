import QtQuick
import QtQuick.Controls

Item {
    id: root

    property real value: 0.0
    property real from: 0.0
    property real to: 1.0
    property bool indeterminate: false
    property string label: ""

    property color trackColor: Theme.palette.surfaceActive
    property color fillColor: Theme.palette.accent
    property int height_: 4

    implicitWidth: 200
    implicitHeight: label !== "" ? height_ + Theme.fsXs + Theme.spSm : height_

    Accessible.role: Accessible.ProgressBar
    Accessible.name: root.label || "Progress"

    Column {
        anchors.fill: parent
        spacing: Theme.spSm

        Text {
            visible: root.label !== ""
            text: root.label
            font.family: Theme.fontSans
            font.pixelSize: Theme.fsXs
            color: Theme.palette.textDim
        }

        Item {
            width: parent.width
            height: root.height_

            Rectangle {
                anchors.fill: parent
                radius: root.height_ / 2
                color: root.trackColor
            }

            Rectangle {
                id: fillRect
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: root.indeterminate
                    ? parent.width * 0.3
                    : parent.width * Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
                radius: root.height_ / 2
                color: root.fillColor

                visible: !root.indeterminate || indeterminateAnim.running
            }

            SequentialAnimation {
                id: indeterminateAnim
                running: root.indeterminate
                loops: Animation.Infinite
                PropertyAction { target: fillRect; property: "x"; value: -parent.width * 0.3 }
                NumberAnimation {
                    target: fillRect
                    property: "x"
                    to: parent.width
                    duration: 1200
                    easing.type: Easing.InOutCubic
                }
                PauseAnimation { duration: 300 }
            }
        }
    }
}
