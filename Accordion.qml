import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Rectangle {
    id: root

    property string title: ""
    property string icon: ""
    property string subtitle: ""
    property bool expanded: false
    property int lifted: 0

    default property alias content: contentArea.data

    signal toggled(bool expanded)

    radius: Theme.rXl
    color: Theme.palette.surfaceHigh
    border.width: 1
    border.color: Theme.palette.border
    height: header.implicitHeight + (expanded ? contentArea.implicitHeight + Theme.spMd * 2 : 0) + (expanded ? Theme.spSm : 0)
    clip: true

    Behavior on height { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            implicitHeight: Math.max(labelRow.implicitHeight + Theme.spMd, 28)
            radius: root.radius
            color: mouseArea.containsMouse ? Theme.palette.surfaceHover : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            RowLayout {
                id: labelRow
                anchors.fill: parent
                anchors.leftMargin: Theme.spMd
                anchors.rightMargin: Theme.spSm
                spacing: Theme.spSm

                FIcon {
                    visible: root.icon !== ""
                    icon: root.icon
                    pixelSize: Theme.fsMd
                    color: Theme.palette.onSurface
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    Text {
                        text: root.title
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsBase
                        font.weight: Font.Medium
                        color: Theme.palette.textBright
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: root.subtitle !== ""
                        text: root.subtitle
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsXs
                        color: Theme.palette.textDim
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    implicitWidth: 16; implicitHeight: 16; radius: 8
                    color: root.expanded ? Theme.palette.accentContainer : "transparent"
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        anchors.centerIn: parent
                        text: root.expanded ? "\uf068" : "\uf067"
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsXs
                        color: root.expanded ? Theme.palette.onAccent : Theme.palette.textDim
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.expanded = !root.expanded; root.toggled(root.expanded) }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spMd
            Layout.rightMargin: Theme.spMd
            Layout.topMargin: expanded ? Theme.spSm : 0
            Layout.bottomMargin: expanded ? Theme.spSm : 0
            clip: true
            implicitHeight: expanded ? contentArea.implicitHeight : 0
            opacity: expanded ? 1.0 : 0.0

            Behavior on implicitHeight {
                NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Item {
                id: contentArea
                width: parent.width
                implicitHeight: childrenRect.height
            }
        }
    }
}
