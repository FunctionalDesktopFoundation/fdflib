import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property string text: ""
    property color color: Theme.palette.textBright
    property int fontPixelSize: Theme.fsBase
    property string fontFamily: Theme.fontSans
    property int fontWeight: Font.Normal
    property bool bold: false
    property real letterSpacing: 0
    property string elide: "none"
    property int animationDuration: Theme.animNorm

    implicitWidth: textMetrics.width
    implicitHeight: fontPixelSize * 1.4

    FontMetrics { id: textMetrics; font.family: root.fontFamily; font.pixelSize: root.fontPixelSize }

    Row {
        id: charRow
        spacing: root.letterSpacing

        Repeater {
            id: charRepeater
            model: root.text.length

            Item {
                width: charMetrics.width
                height: root.fontPixelSize * 1.4

                property string char: root.text.length > index ? root.text[index] : ""
                property bool isNew: false

                FontMetrics {
                    id: charMetrics
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                }

                Text {
                    id: charText
                    text: root.text.length > index ? root.text[index] : ""
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                    font.weight: root.bold ? Font.Bold : root.fontWeight
                    color: root.color
                    opacity: 1
                    y: 0

                    Behavior on y {
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                    }
                }

                states: State {
                    name: "enter"
                    PropertyChanges { target: charText; y: -root.fontPixelSize * 0.5; opacity: 0 }
                }

                transitions: Transition {
                    from: "enter"; to: ""
                    NumberAnimation { properties: "y,opacity"; duration: root.animationDuration; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    charText.y = root.fontPixelSize * 0.3
                    charText.opacity = 0
                    var delay = index * 30
                    fadeInTimer.interval = delay
                    fadeInTimer.start()
                }

                Timer {
                    id: fadeInTimer
                    repeat: false
                    onTriggered: {
                        charText.y = 0
                        charText.opacity = 1
                    }
                }
            }
        }
    }
}
