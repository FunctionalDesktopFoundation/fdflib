import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

RowLayout {
    id: root
    spacing: Theme.spLg

    property string title: ""
    property string subtitle: ""
    property string appIcon: ""
    property bool showTrafficLights: true
    property bool showMinimize: false
    property bool showZoom: false
    property var targetWindow: null
    property var actions: []
    property alias actionRow: actionRow
    default property alias content: titleSlot.data

    signal closeClicked()

    TrafficLights {
        visible: root.showTrafficLights
        showMinimize: root.showMinimize
        showZoom: root.showZoom
        targetWindow: root.targetWindow
        onCloseClicked: root.closeClicked()
    }

    FIcon {
        visible: root.appIcon !== ""
        icon: root.appIcon
        pixelSize: Theme.fsLg
        color: Theme.palette.textBright
        Layout.alignment: Qt.AlignVCenter
    }


    Item {
        id: titleSlot
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: titleLabel.height > 0 ? titleLabel.height : childrenRect.height


        RowLayout {
            id: titleLabel
            visible: root.title !== "" && titleSlot.children.length <= 1
            spacing: Theme.spMd
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: root.title
                font.pixelSize: Theme.fs2xl
                font.family: Theme.fontSans
                font.weight: Theme.fontWeightHeader
                color: Theme.palette.textBright
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                font.pixelSize: Theme.fsMd
                font.family: Theme.fontSans
                font.weight: Theme.fontWeightSubtitle
                color: Theme.palette.textDim
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }


    RowLayout {
        id: actionRow
        spacing: Theme.spSm

        Repeater {
            model: root.actions
            delegate: FButton {
                icon: modelData.icon || ""
                text: modelData.text || ""
                variant: modelData.variant || "ghost"
                fontSize: modelData.fontSize || Theme.fsMd
                implicitWidth: (modelData.width !== undefined && modelData.width !== null) ? modelData.width : (modelData.text ? undefined : 28)
                implicitHeight: (modelData.height !== undefined && modelData.height !== null) ? modelData.height : 28
                radius: Theme.rBtn
                onClicked: { if (modelData.onClicked) modelData.onClicked() }
            }
        }
    }
}
