import QtQuick
import QtQuick.Controls
import FDF

Row {
    id: root
    spacing: 7

    property bool showMinimize: true
    property bool showZoom: true
    property var targetWindow: null
    property string style: "iconic"

    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()

    property bool _anyHovered: false
    function _updateHover() {
        _anyHovered = (style === "classic") && (closeMa.hovered || minMa.hovered || zoomMa.hovered)
    }

    Loader {
        sourceComponent: root.style === "classic" ? classicStyle : iconicStyle
    }

    Component { id: iconicStyle
        Row { spacing: 4
            FButton { icon: "\uf00d"; variant: "ghost"; fontSize: Theme.fsSm; implicitWidth: 16; implicitHeight: 16; radius: 2
                Accessible.name: "Close"; onClicked: root.closeClicked() }
            FButton { icon: "\uf2d1"; variant: "ghost"; fontSize: Theme.fsSm; implicitWidth: 16; implicitHeight: 16; radius: 2; visible: root.showMinimize
                Accessible.name: "Minimize"; onClicked: { root.minimizeClicked(); if (root.targetWindow) root.targetWindow.visibility = Window.Minimized } }
            FButton { icon: "\uf2d0"; variant: "ghost"; fontSize: Theme.fsSm; implicitWidth: 16; implicitHeight: 16; radius: 2; visible: root.showZoom
                Accessible.name: "Zoom"; onClicked: { root.zoomClicked(); if (root.targetWindow) { root.targetWindow.visibility = (root.targetWindow.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized } } }
        }
    }

    Component { id: classicStyle
        Row { spacing: 6
            Rectangle { width: 12; height: 12; radius: 6
                color: closeMa.pressed ? "#E04040" : (closeMa.hovered ? "#FF5F57" : Theme.palette.trafficRed)
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: Theme.fsBase; font.family: Theme.fontMono; font.weight: Font.Bold; color: Theme.palette.trafficRedDim; opacity: root._anyHovered ? 1 : 0; Behavior on opacity { NumberAnimation { duration: Theme.animFast } } }
                MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onEntered: root._updateHover(); onExited: root._updateHover(); onClicked: root.closeClicked() }
                Accessible.role: Accessible.Button; Accessible.name: "Close"
            }
            Rectangle { width: 12; height: 12; radius: 6; visible: root.showMinimize
                color: minMa.pressed ? "#C09000" : (minMa.hovered ? "#FFBD2E" : Theme.palette.trafficYellow)
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Text { anchors.centerIn: parent; text: "\u2212"; font.pixelSize: Theme.fsMd; font.family: Theme.fontMono; font.weight: Font.Bold; color: Theme.palette.trafficYellowDim; opacity: root._anyHovered ? 1 : 0; Behavior on opacity { NumberAnimation { duration: Theme.animFast } } }
                MouseArea { id: minMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onEntered: root._updateHover(); onExited: root._updateHover(); onClicked: { root.minimizeClicked(); if (root.targetWindow) root.targetWindow.visibility = Window.Minimized } }
                Accessible.role: Accessible.Button; Accessible.name: "Minimize"
            }
            Rectangle { width: 12; height: 12; radius: 6; visible: root.showZoom
                color: zoomMa.pressed ? "#009000" : (zoomMa.hovered ? "#28CA41" : Theme.palette.trafficGreen)
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Text { anchors.centerIn: parent; text: "\u002B"; font.pixelSize: Theme.fsMd; font.family: Theme.fontMono; font.weight: Font.Bold; color: Theme.palette.trafficGreenDim; opacity: root._anyHovered ? 1 : 0; Behavior on opacity { NumberAnimation { duration: Theme.animFast } } }
                MouseArea { id: zoomMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onEntered: root._updateHover(); onExited: root._updateHover(); onClicked: { root.zoomClicked(); if (root.targetWindow) { root.targetWindow.visibility = (root.targetWindow.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized } } }
                Accessible.role: Accessible.Button; Accessible.name: "Zoom"
            }
        }
    }
}
