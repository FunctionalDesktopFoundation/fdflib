import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Rectangle {
    id: root

    default property alias content: contentArea.data

    color: Theme.palette.surfaceHigh
    radius: Theme.rLg
    clip: false

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: 160
    Layout.minimumHeight: 120

    layer.enabled: true

    readonly property real _contentMargin: Theme.isMobile(width) ? Theme.spMd : Theme.spLg

    Item {
        id: contentArea
        anchors.fill: parent
        anchors.margins: root._contentMargin
        clip: false
    }
}
