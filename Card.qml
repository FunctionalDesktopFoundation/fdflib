import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property int lifted: 0
    property var source: null
    property var modelData: null
    property int index: -1
    default property alias content: contentArea.data
    implicitWidth: 280
    implicitHeight: contentColumn.implicitHeight + Theme.spLg * 2
    color: Theme.palette.surfaceHigh
    radius: Theme.rXl
    layer.enabled: root.lifted > 0
    layer.effect: DropShadow {
        radius: root.lifted * 8; samples: root.lifted * 16
        color: Qt.rgba(0, 0, 0, 0.25)
    }
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.spLg
        spacing: Theme.spSm
        RowLayout {
            visible: root.title !== "" || root.icon !== ""
            Layout.fillWidth: true
            spacing: Theme.spSm
            Image { visible: root.source != null; source: root.source != null ? root.source : ""; Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
            FIcon { visible: root.icon !== ""; icon: root.icon; pixelSize: Theme.fsLg; color: Theme.palette.onSurface }
            ColumnLayout { Layout.fillWidth: true; spacing: 0
                Text { visible: root.title !== ""; text: root.title; font.family: Theme.fontSans; font.pixelSize: Theme.fsMd; font.weight: Theme.fontWeightHeader; color: Theme.palette.textBright }
                Text { visible: root.subtitle !== ""; text: root.subtitle; font.family: Theme.fontSans; font.pixelSize: Theme.fsXs; color: Theme.palette.textDim }
            }
        }
        ColumnLayout { id: contentArea; Layout.fillWidth: true; Layout.fillHeight: true; spacing: Theme.spSm }
    }
}
