import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF as FDF

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool selected: false
    property bool showChevron: false
    property alias leftContent: leftSlot.data
    property alias rightContent: rightSlot.data

    signal clicked()

    implicitHeight: 44
    radius: Theme.rMd

    color: "transparent"

    Accessible.role: Accessible.ListItem
    Accessible.name: root.title || root.subtitle

    onSelectedChanged: {
        if (root.selected) _notifySidebar()
    }

    function _notifySidebar() {
        var p = root.parent
        while (p) {
            if (typeof p.highlightItem === "function" && typeof p.highlightIndex !== "undefined") {
                p.highlightItem(root)
                break
            }
            p = p.parent
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spMd
        anchors.rightMargin: Theme.spMd
        spacing: Theme.spMd

        Item { id: leftSlot; Layout.preferredWidth: leftSlot.children.length > 0 ? 22 : 0; Layout.minimumWidth: 0; Layout.fillHeight: true }

        FIcon {
            visible: root.icon !== ""
            icon: root.icon
            pixelSize: Theme.fsLg
            Layout.minimumWidth: pixelSize
            Layout.preferredWidth: pixelSize < 22 ? 22 : pixelSize
            color: root.selected ? Theme.palette.onSurface : Theme.palette.onSurfaceDim
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 6
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            FDF.Label {
                visible: root.title !== ""
                text: root.title
                variant: "base"
                Layout.fillWidth: true
                Layout.minimumWidth: 1
                elide: Text.ElideRight
            }
            FDF.Label {
                visible: root.subtitle !== ""
                text: root.subtitle
                variant: "xs"
                colorKey: "dim"
                Layout.fillWidth: true
                Layout.minimumWidth: 1
                elide: Text.ElideRight
            }
        }

        Item { id: rightSlot; Layout.preferredWidth: rightSlot.children.length > 0 ? 22 : 0; Layout.minimumWidth: 0; Layout.fillHeight: true }

        FIcon {
            visible: root.showChevron
            icon: "\u203A"
            pixelSize: Theme.fsLg
            Layout.minimumWidth: pixelSize
            Layout.preferredWidth: pixelSize < 22 ? 22 : pixelSize
            color: Theme.palette.textDim
            Layout.alignment: Qt.AlignVCenter
        }
    }

    TapHandler { id: tap; onTapped: root.clicked() }
}
