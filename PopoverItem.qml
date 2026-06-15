import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Item {
    id: root

    property string text: ""
    property string icon: ""
    property string subtitle: ""
    property bool selected: false
    property int blobSize: 32
    property int _staggerOrder: 0

    signal clicked()

    implicitWidth: parent ? parent.width : 200
    implicitHeight: contentRow.implicitHeight + Theme.spSm * 2

    Rectangle {
        id: bgHighlight
        anchors.fill: parent
        radius: Theme.rMd
        color: root.selected ? Theme.palette.surfaceActive : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    RowLayout {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spSm
        anchors.rightMargin: Theme.spSm
        spacing: Theme.spMd

        Rectangle {
            id: iconBlob
            width: root.blobSize
            height: root.blobSize
            radius: width / 2
            color: Theme.palette.surface

            border.width: 1
            border.color: root.selected ? Theme.palette.accent : Theme.palette.border

            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            FIcon {
                anchors.centerIn: parent
                icon: root.icon
                pixelSize: Theme.fsMd
                color: root.selected ? Theme.palette.accent : Theme.palette.onSurfaceMid

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }

        Rectangle {
            id: connector
            height: 2
            implicitWidth: root.selected ? 12 : 0
            Layout.preferredWidth: implicitWidth
            Layout.minimumWidth: 0
            radius: 1
            color: Theme.palette.accent

            Behavior on implicitWidth { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 6
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.text
                font.family: Theme.fontSans
                font.pixelSize: Theme.fsSm
                font.weight: Font.Medium
                color: Theme.palette.onSurface
                Layout.fillWidth: true
                Layout.minimumWidth: 1
                elide: Text.ElideRight
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                font.family: Theme.fontSans
                font.pixelSize: Theme.fsXs
                color: Theme.palette.onSurfaceDim
                Layout.fillWidth: true
                Layout.minimumWidth: 1
                elide: Text.ElideRight
            }
        }

        FIcon {
            visible: root.selected
            icon: "\u2713"
            pixelSize: Theme.fsSm
            color: Theme.palette.accent
            Layout.alignment: Qt.AlignVCenter
        }
    }

    TapHandler {
        onTapped: root.clicked()
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            bgHighlight.color = hover.hovered ? Theme.palette.surfaceHover : (root.selected ? Theme.palette.surfaceActive : "transparent")
        }
    }

    property bool _suppressBehaviors: false

    Behavior on opacity {
        enabled: !root._suppressBehaviors
        NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        enabled: !root._suppressBehaviors
        NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic }
    }
}
