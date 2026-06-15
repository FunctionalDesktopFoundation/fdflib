import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Item {
    id: root

    property string title: ""
    property bool showBack: false
    property var breadcrumbs: []
    property bool showTrafficLights: true
    property var targetWindow: null

    property alias leftContent: leftArea.data
    property alias rightContent: rightArea.data
    property alias centerContent: centerArea.data

    signal backClicked()

    implicitHeight: Theme.headH
    z: 20

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.surface
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1; color: Theme.palette.border
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spLg
        anchors.rightMargin: Theme.spLg
        spacing: Theme.spMd

        Loader {
            visible: root.showTrafficLights
            active: visible
            source: "TrafficLights.qml"
            onLoaded: {
                item.showMinimize = root.targetWindow !== null
                item.showZoom = root.targetWindow !== null
                if (root.targetWindow) item.targetWindow = root.targetWindow
                item.closeClicked.connect(function() {
                    if (typeof root.parent.closeWindow === "function")
                        root.parent.closeWindow()
                    else
                        Qt.quit()
                })
            }
        }

        Item {
            id: leftArea
            Layout.preferredHeight: Theme.headH
            Layout.fillWidth: false
            children: []

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spSm

                FButton {
                    visible: root.showBack
                    icon: "\uf053"
                    variant: "ghost"
                    onClicked: root.backClicked()
                }
            }
        }

        Item {
            id: centerArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.title !== ""

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Label {
                    visible: root.breadcrumbs.length > 0
                    Layout.alignment: Qt.AlignHCenter
                    variant: "xs"
                    colorKey: "dim"
                    text: root.breadcrumbs.join(" \u203A ")
                }

                Label {
                    text: root.title
                    variant: "heading"
                    Layout.alignment: Qt.AlignHCenter
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            id: rightArea
            Layout.preferredHeight: Theme.headH
            Layout.fillWidth: false
            children: []
        }
    }
}
