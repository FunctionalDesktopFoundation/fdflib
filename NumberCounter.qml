import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property int value: 0
    property string prefix: ""
    property string suffix: ""
    property color color: Theme.palette.textBright
    property int fontPixelSize: Theme.fsBase
    property string fontFamily: Theme.fontSans
    property int fontWeight: Font.Normal
    property bool bold: false
    property int animationDuration: Theme.animSlow

    implicitWidth: row.implicitWidth
    implicitHeight: fontPixelSize * 1.4

    property string _display: prefix + value + suffix
    property string _prevDisplay: ""

    onValueChanged: {
        _prevDisplay = _display
        _display = prefix + value + suffix
        charRepeater.model = Math.max(_display.length, _prevDisplay.length)
    }

    Component.onCompleted: {
        _display = prefix + value + suffix
        charRepeater.model = _display.length
    }

    Row {
        id: row
        spacing: 0

        Repeater {
            id: charRepeater

            delegate: Item {
                width: cm.advanceWidth
                height: root.fontPixelSize * 1.4
                clip: true

                readonly property string cur: index < root._display.length ? root._display[index] : ""
                readonly property string prev: index < root._prevDisplay.length ? root._prevDisplay[index] : ""
                readonly property bool isDigit: cur >= "0" && cur <= "9" && prev >= "0" && prev <= "9"
                readonly property bool changed: prev !== "" && cur !== prev
                readonly property bool increased: changed && isDigit && prev < cur

                FontMetrics {
                    id: cm
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                }

                Text {
                    id: curText
                    text: cur
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                    font.weight: root.bold ? Font.Bold : root.fontWeight
                    color: root.color
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 0
                    opacity: 1
                }
                Text {
                    id: prevText
                    text: prev
                    font.family: root.fontFamily
                    font.pixelSize: root.fontPixelSize
                    font.weight: root.bold ? Font.Bold : root.fontWeight
                    color: root.color
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 0
                    opacity: 0
                    visible: false
                }

                states: State {
                    name: "animate"
                    when: false
                    PropertyChanges { target: curText; y: 0; opacity: 1 }
                    PropertyChanges { target: prevText; y: 0; opacity: 0 }
                }

                function triggerAnim() {
                    if (!changed || root._prevDisplay === "") return
                    var dir = increased ? 1 : -1
                    curText.y = -dir * root.fontPixelSize
                    curText.opacity = 0
                    prevText.text = prev
                    prevText.y = 0
                    prevText.opacity = 1
                    prevText.visible = true
                    var anim = Qt.createQmlObject(
                        "import QtQuick; import QtQuick.Easing; ParallelAnimation { " +
                        "NumberAnimation { target: curText; property: \"y\"; to: 0; duration: " + root.animationDuration + "; easing.type: Easing.OutCubic } " +
                        "NumberAnimation { target: curText; property: \"opacity\"; to: 1; duration: " + Math.round(root.animationDuration * 0.7) + "; easing.type: Easing.OutCubic } " +
                        "NumberAnimation { target: prevText; property: \"y\"; to: " + (dir * root.fontPixelSize) + "; duration: " + Math.round(root.animationDuration * 0.6) + "; easing.type: Easing.InCubic } " +
                        "NumberAnimation { target: prevText; property: \"opacity\"; to: 0; duration: " + Math.round(root.animationDuration * 0.4) + "; easing.type: Easing.InCubic } " +
                        "onFinished: { prevText.visible = false; anim.destroy(); } }",
                        parent, "charAnim");
                    anim.start()
                }

                onChangedChanged: {
                    if (changed) Qt.callLater(triggerAnim)
                }
            }
        }
    }
}
