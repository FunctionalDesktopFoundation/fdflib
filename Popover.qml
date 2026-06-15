import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var anchor: null
    property string position: "below"
    property real offset: 6
    property int duration: Theme.animNorm
    property bool staggerChildren: false
    property int staggerDelay: 40
    property real scaleAmount: 0.88
    property int lifted: 0
    property int minWidth: 240
    property int maxWidth: 520
    property bool closeOnPressOutside: true
    property bool closeOnEscape: true
    property bool dividerDots: false

    default property alias content: contentLayout.data

    signal opened()
    signal closed()

    property bool _open: false
    property var _contentChildren: []
    property int _staggerIdx: -1
    property var _staggerChildren: []
    property var _staggerHeights: []
    property int _staggerIdx: -1

    function _startStagger() {
        _staggerIdx = -1
        _staggerChildren = []
        _staggerHeights = []
        for (var i = 0; i < _contentChildren.length; i++) {
            var c = _contentChildren[i]
            _staggerChildren.push(c)
            var h = c.height > 0 ? c.height : (c.implicitHeight > 0 ? c.implicitHeight : 40)
            _staggerHeights.push(h)
            c.height = 0
            c.opacity = 0
            c.scale = root.scaleAmount
        }
        _advanceStagger()
    }

    function _advanceStagger() {
        _staggerIdx++
        if (_staggerIdx >= _staggerChildren.length) return
        var c = _staggerChildren[_staggerIdx]
        if (c) {
            c.height = _staggerHeights[_staggerIdx]
            c.opacity = 1
            c.scale = 1.0
        }
        if (_staggerIdx < _staggerChildren.length - 1)
            staggerPause.restart()
    }

    function dismiss() {
        if (!_open) return
        _open = false
        openAnim.stop()
        root.cleanupChildren()
        closeAnim.restart()
    }

    function positionRelative() {
        if (!anchor) return
        var parentItem = root.parent
        var globalPos = anchor.mapToItem(parentItem, 0, 0)
        var anchorW = anchor.width
        var anchorH = anchor.height
        var popW = popupBody.width
        var popH = popupBody.height
        var win = root.Window.window
        var margin = 8

        var px = 0, py = 0
        if (position === "below") {
            px = globalPos.x
            py = globalPos.y + anchorH + offset
        } else if (position === "above") {
            px = globalPos.x
            py = globalPos.y - popH - offset
        } else if (position === "left") {
            px = globalPos.x - popW - offset
            py = globalPos.y
        } else if (position === "right") {
            px = globalPos.x + anchorW + offset
            py = globalPos.y
        } else if (position === "center") {
            px = globalPos.x + (anchorW - popW) / 2
            py = globalPos.y + (anchorH - popH) / 2
        }

        if (win) {
            if (px + popW > win.width - margin) px = win.width - popW - margin
            if (px < margin) px = margin
            if (py + popH > win.height - margin) py = win.height - popH - margin
            if (py < margin) py = margin
        }

        root.x = Math.round(px)
        root.y = Math.round(py)
    }

    function setupStagger() {
        _contentChildren = []
        for (var i = 0; i < contentLayout.children.length; i++) {
            var child = contentLayout.children[i]
            if (child.visible !== false && child !== separatorItem && child !== dividerItem) {
                _contentChildren.push(child)
            }
        }
        for (var j = 0; j < _contentChildren.length; j++) {
            var c = _contentChildren[j]
            c.opacity = 0
            c.scale = root.scaleAmount
            c.height = 0
        }
        _staggerIdx = -1
        _staggerHeights = []
    }

    function _startStagger() {
        _staggerIdx = -1
        _staggerChildren = []
        for (var i = 0; i < _contentChildren.length; i++)
            _staggerChildren.push(_contentChildren[i])
        _advanceStagger()
    }

    function _advanceStagger() {
        _staggerIdx++
        if (_staggerIdx >= _staggerChildren.length) return
        var c = _staggerChildren[_staggerIdx]
        if (c) {
            var targetH = c._origImplicit > 0 ? c._origImplicit : (c._origHeight > 0 ? c._origHeight : 40)
            c.height = targetH
            c.opacity = 1
            c.scale = 1.0
            if (_staggerIdx === _staggerChildren.length - 1)
                c.clip = false
        }
        if (_staggerIdx < _staggerChildren.length - 1)
            staggerPause.restart()
    }

    SequentialAnimation {
        id: staggerPause
        PauseAnimation { duration: root.staggerDelay }
        onFinished: root._advanceStagger()
    }

    function repopAfterStagger() {
        Qt.callLater(function() {
            positionRelative()
        })
    }

    function cleanupChildren() {
        staggerPause.stop()
        for (var i = 0; i < _staggerChildren.length; i++) {
            var child = _staggerChildren[i]
            if (child) {
                child.height = _staggerHeights.length > i ? _staggerHeights[i] : child.height
                child.opacity = 1
                child.scale = 1.0
            }
        }
        _staggerChildren = []
        _staggerHeights = []
    }

    SequentialAnimation {
        id: openAnim

        ScriptAction {
            script: {
                if (root.staggerChildren) {
                    root.setupStagger()
                }
            }
        }

        ParallelAnimation {
            NumberAnimation { target: popupBody; property: "opacity"; from: 0; to: 1; duration: root.duration; easing.type: Easing.OutCubic }
            NumberAnimation { target: popupBody; property: "scale"; from: root.scaleAmount; to: 1.0; duration: root.duration; easing.type: Easing.OutCubic }
        }

        ScriptAction {
            script: {
                if (root.staggerChildren && _contentChildren.length > 0) {
                    root._startStagger()
                }
                root.opened()
            }
        }
    }

    SequentialAnimation {
        id: closeAnim

        ParallelAnimation {
            NumberAnimation { target: popupBody; property: "opacity"; from: 1; to: 0; duration: root.duration * 0.6; easing.type: Easing.InCubic }
            NumberAnimation { target: popupBody; property: "scale"; from: 1.0; to: root.scaleAmount * 0.95; duration: root.duration * 0.6; easing.type: Easing.InCubic }
        }

        ScriptAction {
            script: {
                root.cleanupChildren()
                root.visible = false
                root.closed()
            }
        }
    }

    Rectangle {
        id: popupBody
        x: 0
        y: 0
        implicitWidth: Math.min(Math.max(root.minWidth, contentLayout.implicitWidth + Theme.spSm * 2), root.maxWidth)
        implicitHeight: contentLayout.implicitHeight + Theme.spSm * 2
        radius: Theme.rXl
        color: Theme.palette.surfaceHigh
        border.width: 1
        border.color: Theme.palette.border

        opacity: 0
        scale: root.scaleAmount

        Behavior on implicitHeight { NumberAnimation { duration: root.staggerDelay * 2; easing.type: Easing.OutCubic } }

        layer.enabled: root.lifted > 0
        layer.effect: DropShadow {
            radius: root.lifted * 6 + 4; samples: root.lifted * 10 + 6
            color: Qt.rgba(0, 0, 0, 0.5)
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Theme.spSm
            spacing: 0

            Item {
                id: separatorItem
                visible: false
                implicitHeight: 0
                implicitWidth: 0
            }

            Item {
                id: dividerItem
                visible: root.dividerDots && contentLayout.children.length > 1
                Layout.fillWidth: true
                implicitHeight: Theme.spSm

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.parent.width * 0.5
                    height: 1
                    color: Theme.palette.border
                    visible: root.dividerDots
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: function(mouse) { mouse.accepted = false }
    }

    Connections {
        target: root.anchor
        function onXChanged() { if (root._open) root.positionRelative() }
        function onYChanged() { if (root._open) root.positionRelative() }
        function onWidthChanged() { if (root._open) root.positionRelative() }
        function onHeightChanged() { if (root._open) root.positionRelative() }
        function onVisibleChanged() { if (root._open && !root.anchor.visible) root.dismiss() }
    }

    Connections {
        target: root.Window.window
        function onWidthChanged() { if (root._open) root.positionRelative() }
        function onHeightChanged() { if (root._open) root.positionRelative() }
    }

    Item {
        id: dismissCatcher
        anchors.fill: parent
        z: -1

        MouseArea {
            id: outsideArea
            anchors.fill: parent
            anchors.margins: -9999
            enabled: root._open && root.closeOnPressOutside
            propagateComposedEvents: false
            onPressed: function(mouse) {
                var pos = outsideArea.mapToItem(root, mouse.x, mouse.y)
                if (!root.contains(pos)) {
                    root.dismiss()
                }
            }
        }
    }

    Keys.onEscapePressed: {
        if (root.closeOnEscape) root.dismiss()
    }
}
