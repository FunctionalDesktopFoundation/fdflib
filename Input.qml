import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string placeholder: ""
    property bool password: false
    property int inputRadius: Theme.rSm
    property string icon: ""
    property bool clearable: false
    readonly property bool hasIcon: icon !== ""
    readonly property bool hasClear: clearable

    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias font: textField.font
    property alias validator: textField.validator

    signal accepted()
    signal cleared()

    implicitHeight: Theme.inputH
    implicitWidth: 200

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spXs
        spacing: Theme.spXs

        Item {
            Layout.preferredWidth: root.hasIcon ? 24 : 0
            Layout.fillHeight: true
            visible: root.hasIcon

            FIcon {
                anchors.centerIn: parent
                icon: root.icon
                pixelSize: Theme.fsBase
                color: Theme.palette.textDim
            }
        }

        TextField {
            id: textField

            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: root.hasIcon ? Theme.spLg * 2 : Theme.spLg
            rightPadding: root.hasClear ? Theme.spLg * 2 : Theme.spLg

            font.family: Theme.fontSans
            font.pixelSize: Theme.fsBase
            color: Theme.palette.textBright
            placeholderText: root.placeholder
            placeholderTextColor: Theme.palette.textDim
            echoMode: root.password ? TextInput.Password : TextInput.Normal

            background: Rectangle {
                color: Theme.palette.surfaceActive
                radius: root.inputRadius
            }

            onAccepted: root.accepted()
        }

        Item {
            Layout.preferredWidth: root.hasClear ? 24 : 0
            Layout.fillHeight: true
            visible: root.hasClear

            Rectangle {
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 2
                color: Theme.palette.surfaceHover

                Text {
                    anchors.centerIn: parent
                    text: "\u00D7"
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsXs
                    font.weight: Font.Bold
                    color: Theme.palette.textDim
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        textField.text = ""
                        root.cleared()
                    }
                }
            }
        }
    }

    Accessible.role: Accessible.EditableText
    Accessible.name: root.placeholder || "Input"
}
