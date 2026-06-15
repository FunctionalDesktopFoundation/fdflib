import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

RowLayout {
    id: root

    property var path: []
    property bool compact: false

    signal selected(int index)

    spacing: 0
    Layout.fillHeight: true

    Repeater {
        model: root.path

        delegate: RowLayout {
            spacing: 0
            Layout.fillHeight: true

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: textRow.implicitWidth + Theme.spXs * 2
                radius: Theme.rXs
                color: tap.containsMouse ? Theme.palette.surfaceHover : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                RowLayout {
                    id: textRow
                    anchors.centerIn: parent
                    spacing: Theme.spXs

                    Text {
                        visible: typeof model.modelData !== "string" && model.modelData.icon
                        text: typeof model.modelData === "string" ? "" : (model.modelData.icon || "")
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsSm
                        color: index === root.path.length - 1 ? Theme.palette.textBright : Theme.palette.textDim
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: typeof model.modelData === "string" ? model.modelData : (model.modelData.label || "")
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.fsMd
                        font.weight: index === root.path.length - 1 ? Theme.fontWeightSubheader : Theme.fontWeightText
                        color: index === root.path.length - 1 ? Theme.palette.textBright : Theme.palette.textDim
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                TapHandler {
                    id: tap
                    onTapped: root.selected(index)
                }
            }

            Text {
                visible: index < root.path.length - 1
                text: "\u203A"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMd
                color: Theme.palette.textDim
                leftPadding: Theme.spXs
                rightPadding: Theme.spXs
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
