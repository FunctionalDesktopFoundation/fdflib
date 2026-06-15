import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Item {
    id: root

    property var tabModel: ListModel {}
    property var tabIcons: []
    property var tabLabels: []
    property int activeIndex: 0

    signal tabSelected(int index)

    implicitHeight: parent ? parent.height : 200

    readonly property real _scale: Theme.responsiveScale(width)

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.topMargin: Theme.spXs
        anchors.bottomMargin: Theme.spXs
        spacing: Theme.spXs

        Repeater {
            id: repeater
            model: root.tabModel.count > 0 ? root.tabModel : root.tabIcons
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.activeIndex === index ? 36 * root._scale : 34 * root._scale
                radius: Theme.rMd
                color: "transparent"

                Behavior on Layout.preferredHeight { NumberAnimation { duration: Theme.animFast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.responsiveSpacing(width, Theme.spMd)
                    anchors.rightMargin: Theme.responsiveSpacing(width, Theme.spMd)
                    spacing: Theme.spSm

                    FIcon {
                        icon: root.tabModel.count > 0 ? root.tabModel.get(index).icon || "" : root.tabIcons[index] || ""
                        pixelSize: Theme.fsXl * root._scale
                        color: root.activeIndex === index ? Theme.palette.onSurface : Theme.palette.onSurfaceDim
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignHCenter
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    Text {
                        text: root.tabLabels[index] || ""
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsBase * root._scale
                        font.weight: root.activeIndex === index ? Theme.fontWeightSubheader : Theme.fontWeightText
                        color: root.activeIndex === index ? Theme.palette.textBright : Theme.palette.textDim
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        visible: root.width >= 180
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.activeIndex = index; root.tabSelected(index) }
                }

                Accessible.role: Accessible.Button
                Accessible.name: root.tabLabels[index] || ""
            }
        }

        Item { Layout.fillHeight: true }
    }


    Rectangle {
        id: highlight
        width: column.width
        height: column.height
        radius: 0
        color: Theme.palette.surfaceActive
        z: -1

        Behavior on y { NumberAnimation { duration: Theme.animNorm; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: Theme.animFast } }
        Behavior on height { NumberAnimation { duration: Theme.animFast } }

        Component.onCompleted: {
            Qt.callLater(updatePosition)
        }

        function updatePosition() {
            if (repeater.count > 0 && repeater.itemAt(root.activeIndex)) {
                var item = repeater.itemAt(root.activeIndex)
                var pos = item.mapToItem(root, 0, 0)
                highlight.y = pos.y
                highlight.width = item.width
                highlight.height = item.height
            }
        }
    }

    Connections {
        target: root
        function onActiveIndexChanged() {
            highlight.updatePosition()
        }
    }

    Connections {
        target: repeater
        function onCountChanged() {
            Qt.callLater(function() { highlight.updatePosition() })
        }
    }
}
