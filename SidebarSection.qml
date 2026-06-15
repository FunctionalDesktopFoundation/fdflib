import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF


Rectangle {
    id: root

    property string title: ""
    property string icon: ""
    property bool collapsible: false
    property bool collapsed: false

    property bool fill: false
    property var items: []

    default property alias content: sectionContent.data

    implicitHeight: fill ? 0 : (sectionLayout.implicitHeight + Theme.spMd * 2)
    radius: Theme.rLg
    color: Theme.palette.surfaceHigh
    clip: true

    Layout.topMargin: Theme.spSm
    Layout.fillWidth: true
    Layout.fillHeight: root.fill
    Layout.minimumHeight: root.fill ? 60 : 0

    ColumnLayout {
        id: sectionLayout
        anchors.fill: parent
        anchors.margins: Theme.spMd
        spacing: Theme.spSm


        RowLayout {
            visible: root.title !== "" || root.collapsible
            Layout.fillWidth: true
            spacing: Theme.spSm

            FIcon {
                visible: root.icon !== ""
                icon: root.icon
                pixelSize: Theme.fsMd
                color: Theme.palette.textDim
            }
            Text {
                visible: root.title !== ""
                text: root.title
                font.family: Theme.fontSans
                font.pixelSize: Theme.fsSm
                font.weight: Theme.fontWeightSubheader
                color: Theme.palette.textDim
                Layout.fillWidth: true
                Layout.minimumWidth: 1
                elide: Text.ElideRight
            }
            FButton {
                visible: root.collapsible
                icon: root.collapsed ? "\uf054" : "\uf078"
                variant: "ghost"
                fontSize: Theme.fsXs
                implicitWidth: 18
                implicitHeight: 18
                radius: 3
                onClicked: { root.collapsed = !root.collapsed }
            }
        }


        ColumnLayout {
            id: sectionContent
            Layout.fillWidth: true
            Layout.minimumWidth: 1
            Layout.fillHeight: root.fill
            visible: !root.collapsible || !root.collapsed
            spacing: Theme.spSm
            implicitHeight: visible && !root.fill ? childrenRect.height : 0
        }


        ColumnLayout {
            visible: !root.collapsible || !root.collapsed
            Layout.fillWidth: true
            Layout.minimumWidth: 1
            spacing: Theme.spXs
            Repeater {
                model: root.items || []
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spSm
                    FIcon {
                        icon: modelData.icon || ""
                        pixelSize: Theme.fsMd
                        color: Theme.palette.textDim
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: modelData.label || modelData.name || ""
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsSm
                        color: Theme.palette.textBright
                        Layout.fillWidth: true
                        Layout.minimumWidth: 1
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
