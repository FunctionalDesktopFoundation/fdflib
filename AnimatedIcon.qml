import QtQuick
import QtQuick.Controls

Text {
    id: root

    property string icon: ""
    property string state: "idle"
    property color color_: Theme.palette.onSurface
    property int size: Theme.fsXl

    text: root.icon
    font.family: Theme.fontMono
    font.pixelSize: root.size
    color: root.color_

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    states: [
        State {
            name: "idle"
            PropertyChanges { target: root; rotation: 0; scale: 1.0 }
        },
        State {
            name: "spinning"
            PropertyChanges { target: spinAnim; running: true }
        },
        State {
            name: "pulsing"
            PropertyChanges { target: pulseAnim; running: true }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "idle"
            SequentialAnimation {
                NumberAnimation { target: root; property: "rotation"; to: 0; duration: Theme.animNorm; easing.type: Easing.OutCubic }
                PropertyAction { target: spinAnim; property: "running"; value: false }
                PropertyAction { target: pulseAnim; property: "running"; value: false }
            }
        }
    ]

    RotationAnimation on rotation {
        id: spinAnim
        from: 0; to: 360
        duration: 900
        loops: Animation.Infinite
        running: false
        easing.type: Easing.Linear
    }

    SequentialAnimation on scale {
        id: pulseAnim
        running: false
        loops: Animation.Infinite
        NumberAnimation { from: 1.0; to: 1.25; duration: 400; easing.type: Easing.OutCubic }
        NumberAnimation { from: 1.25; to: 1.0; duration: 400; easing.type: Easing.InCubic }
    }

    onStateChanged: {
        if (state === "spinning" || state === "pulsing") {
            idleReset.restart()
        } else {
            idleReset.stop()
        }
    }

    SequentialAnimation {
        id: idleReset
        PauseAnimation { duration: 2000 }
        onFinished: root.state = "idle"
    }

    function spin() { root.state = "spinning" }
    function pulse() { root.state = "pulsing" }
    function stop()  { root.state = "idle" }

    function morph(targetIcon, callback) {
        morphAnim.targetIcon = targetIcon
        morphAnim.callback = callback
        morphAnim.restart()
    }

    property var _morphTarget: ""
    property var _morphCallback: null

    SequentialAnimation {
        id: morphAnim
        property string targetIcon: ""
        property var callback: null

        NumberAnimation { target: root; property: "scale"; to: 0.0; duration: Theme.animFast; easing.type: Easing.InCubic }
        ScriptAction { script: {
            root.icon = morphAnim.targetIcon
            if (morphAnim.callback) morphAnim.callback()
        }}
        NumberAnimation { target: root; property: "scale"; to: 1.0; duration: Theme.animFast; easing.type: Easing.OutCubic }
    }
}
