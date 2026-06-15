import QtQuick
import FDF

Item {
    id: root

    property real value: 0.5
    property real from: 0.0
    property real to: 1.0
    property real stepSize: 0.0
    property string label: ""
    property bool showHandle: true
    property int handleSize: 16

    property color trackColor: Theme.palette.surfacePressed
    property color fillColor: Theme.palette.accent
    property color handleColor: Theme.palette.onAccent
    property color handleBorderColor: Qt.rgba(0,0,0,0.2)
    property int trackHeight_: 6

    implicitWidth: 200
    implicitHeight: trackHeight_ + (label !== "" ? Theme.fsXs + Theme.spSm : 0) + (showHandle ? handleSize / 2 : 0)

    readonly property real ratio: Math.max(0, Math.min(1, (value - from) / (to - from)))

    signal moved(real value)

    function setValue(v) {
        var clamped = Math.max(from, Math.min(to, v))
        if (stepSize > 0) clamped = Math.round(clamped / stepSize) * stepSize
        root.value = Math.max(from, Math.min(to, clamped))
        root.moved(root.value)
    }

    Column {
        anchors.fill: parent
        spacing: Theme.spSm

        Text {
            visible: label !== ""
            text: label
            font.family: Theme.fontSans
            font.pixelSize: Theme.fsXs
            color: Theme.palette.textDim
        }

        Item {
            width: parent.width
            height: trackHeight_
            anchors.verticalCenter: showHandle ? undefined : parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: trackHeight_ / 2
                color: trackColor
            }

            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: parent.width * ratio
                radius: trackHeight_ / 2
                color: fillColor
                Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
            }

            Rectangle {
                id: handle
                visible: root.showHandle
                x: parent.width * ratio - width / 2
                y: trackHeight_ / 2 - height / 2
                width: handleSize; height: handleSize; radius: handleSize / 2
                color: handleColor
                border.color: handleBorderColor; border.width: 1
                Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.centerIn: parent
                    width: 4; height: 4; radius: 2
                    color: Qt.rgba(0,0,0,0.3)
                }
            }

            TapHandler {
                onTapped: {
                    var r = point.position.x / width
                    root.setValue(root.from + Math.max(0, Math.min(1, r)) * (root.to - root.from))
                }
            }

            DragHandler {
                id: dragHandler
                target: null
                xAxis { enabled: true; minimum: 0; maximum: parent.width }
                yAxis.enabled: false
                onCentroidChanged: {
                    if (active) {
                        var r = centroid.position.x / parent.width
                        root.setValue(root.from + Math.max(0, Math.min(1, r)) * (root.to - root.from))
                    }
                }
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            Accessible.role: Accessible.Slider
            Accessible.name: root.label || "Slider"
        }
    }
}
