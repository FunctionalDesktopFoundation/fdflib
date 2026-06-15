import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import FDF as FDF

Item {
    id: root

    property string text: ""
    property int lifted: 0
    property int showDelay: 500
    property int hideDelay: 200

    default property alias content: contentItem.data

    clip: false

    Item {
        id: contentItem
        anchors.fill: parent
    }

    Component.onCompleted: {
        for (var i = 0; i < contentItem.data.length; i++) {
            var c = contentItem.data[i]
            if (c !== _tooltip && c !== _dummyHandler) {
                if (c.implicitWidth) root.implicitWidth = c.implicitWidth
                if (c.implicitHeight) root.implicitHeight = c.implicitHeight
                break
            }
        }
    }

    HoverHandler {
        id: _dummyHandler
        onHoveredChanged: {
            if (hovered) root.show()
            else root.hide()
        }
    }

    property bool _hovered: false

    SequentialAnimation {
        id: showAnim
        PauseAnimation { duration: root.showDelay }
        onFinished: { root.updatePosition(); _tooltip.open() }
    }

    SequentialAnimation {
        id: hideAnim
        PauseAnimation { duration: root.hideDelay }
        onFinished: _tooltip.close()
    }

    function show() {
        if (root.text === "") return
        _hovered = true
        hideAnim.stop()
        showAnim.restart()
    }

    function hide() {
        _hovered = false
        showAnim.stop()
        hideAnim.restart()
    }

    function updatePosition() {
        if (!root.Window.window) return
        var pos = root.mapToItem(root.Window.window, 0, root.height + FDF.Theme.spXs)
        _tooltip.x = Math.max(FDF.Theme.spSm, pos.x + (root.width - _tooltip.width) / 2)
        _tooltip.y = pos.y
    }

    Popup {
        id: _tooltip
        padding: 0
        margins: 0
        closePolicy: Popup.NoAutoClose

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animFast; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.animFast; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            color: Theme.palette.surfaceHigh
            radius: Theme.rMd

            layer.enabled: root.lifted > 0
            layer.effect: DropShadow {
                radius: root.lifted * 8; samples: root.lifted * 16
                color: Qt.rgba(0, 0, 0, 0.45)
            }
        }

        contentItem: FDF.Label {
            text: root.text
            variant: "sm"
            padding: FDF.Theme.spMd
        }
    }
}
