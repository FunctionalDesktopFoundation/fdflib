import QtQuick
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 44
    implicitHeight: 24

    property bool checked: false
    property string label: ""
    property color onColor: Theme.palette.toggleOn
    property color offColor: Theme.palette.toggleOff
    property color knobColor: Theme.palette.toggleKnob
    property color knobOffColor: Theme.palette.toggleKnobOff

    signal toggled(bool checked)

    Accessible.role: Accessible.Switch
    Accessible.name: root.label || "Toggle"
    Accessible.checked: root.checked

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? onColor : offColor
        Behavior on color { ColorAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: knob
        x: root.checked ? parent.width - width - 3 : 3
        y: 3
        width: parent.height - 6
        height: parent.height - 6
        radius: width / 2
        color: root.checked ? knobColor : knobOffColor
        Behavior on x { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    TapHandler {
        onTapped: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
