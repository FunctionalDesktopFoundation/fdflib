import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property bool highlighted: false

    signal clicked()

    implicitHeight: 40
    radius: Theme.rMd
    color: highlighted ? Theme.palette.surfaceActive : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spMd
        anchors.rightMargin: Theme.spMd
        spacing: Theme.spSm

        FIcon {
            visible: root.icon !== ""
            icon: root.icon
            pixelSize: Theme.fsMd
            color: root.highlighted ? Theme.palette.accent : Theme.palette.textDim
            Layout.preferredWidth: 18
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: root.text
            font.family: Theme.fontSans
            font.pixelSize: Theme.fsBase
            font.weight: root.highlighted ? Font.Medium : Font.Normal
            color: root.highlighted ? Theme.palette.textBright : Theme.palette.textDim
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Accessible.role: Accessible.ListItem
    Accessible.name: root.text
}
