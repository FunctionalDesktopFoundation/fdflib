import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import FDF

Item {
    id: root

    default property alias content: mainContentArea.data

    property var rightPane: null
    property var bottomPane: null
    property int rightPaneWidth: 240
    property int bottomPaneHeight: 180
    property real paneSpacing: Theme.spLg
    property real margins: Theme.spLg

    property real _rightPaneAnimW: 0

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        spacing: root.paneSpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.paneSpacing

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.rWindow
                color: Theme.palette.surfaceHigh
                clip: true

                Item {
                    id: mainContentArea
                    anchors.fill: parent
                    anchors.margins: root.margins
                    clip: false
                }
            }

            Rectangle {
                id: rightPaneContainer
                Layout.preferredWidth: root._rightPaneAnimW
                Layout.fillHeight: true
                radius: Theme.rWindow
                color: Theme.palette.surfaceHigh
                clip: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.25)
                    shadowBlur: 0.15
                    autoPaddingEnabled: true
                }
                opacity: rightPaneLoader.active ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }

                Loader {
                    id: rightPaneLoader
                    anchors.fill: parent
                    anchors.margins: root.margins
                    sourceComponent: root.rightPane
                    active: root.rightPane !== null
                }
            }
        }

        Rectangle {
            id: bottomPaneContainer
            Layout.fillWidth: true
            Layout.preferredHeight: root.bottomPane !== null ? root.bottomPaneHeight : 0
            radius: Theme.rWindow
            color: Theme.palette.surfaceHigh
            clip: true
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.25)
                shadowBlur: 0.15
                autoPaddingEnabled: true
            }
            opacity: bottomPaneLoader.active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }

            Loader {
                id: bottomPaneLoader
                anchors.fill: parent
                anchors.margins: root.margins
                sourceComponent: root.bottomPane
                active: root.bottomPane !== null
            }
        }
    }

    NumberAnimation {
        id: rightPaneAnim
        target: root; property: "_rightPaneAnimW"
        to: rightPaneLoader.active ? root.rightPaneWidth : 0
        duration: Theme.animNorm; easing.type: Easing.OutCubic
    }

    onRightPaneChanged: rightPaneAnim.restart()
}
