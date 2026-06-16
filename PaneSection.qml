import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import FDF

Rectangle {
    id: root

    property bool isPaneSection: true
    property string title: ""
    property string icon: ""
    property bool collapsible: false
    property bool collapsed: false
    property bool fill: false
    property bool bottomPane: false
    property var items: []

    default property alias content: sectionContent.data

    radius: Theme.rLg
    color: Theme.palette.surfaceHigh
    clip: true

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.25)
        shadowBlur: 0.15
        autoPaddingEnabled: true
    }

    Layout.fillWidth: true
    Layout.fillHeight: root.fill && !root.bottomPane
    Layout.minimumHeight: root.fill && !root.bottomPane ? 60 : 0
    Layout.minimumWidth: 80

    implicitHeight: sectionLayout.implicitHeight + Theme.spMd * 2

    Behavior on implicitHeight { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }

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
            Layout.fillHeight: root.fill && !root.bottomPane
            visible: !root.collapsible || !root.collapsed
            spacing: Theme.spSm
            implicitHeight: visible && !root.fill ? childrenRect.height : 0

            Behavior on implicitHeight { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
        }

        ColumnLayout {
            visible: (!root.collapsible || !root.collapsed) && (root.items || []).length > 0
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
                    }
                }
            }
        }
    }
}
