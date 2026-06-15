import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Rectangle {
    id: root
    color: Theme.palette.sidebarBg
    clip: true

    property alias contentItem: contentColumn.data
    default property alias content: contentColumn.data

    property int highlightIndex: -1
    property Item _selectedItem: null

    signal highlightChanged(int index, Item item)

    function highlightItem(item) {
        if (!item) return
        _selectedItem = item
        scrollToItem(item)
        _moveHighlight()
    }

    function _moveHighlight() {
        if (!_selectedItem) {
            indicator.visible = false
            return
        }
        var wasHidden = !indicator.visible
        indicator.visible = true
        var pos = _selectedItem.mapToItem(root, 0, 0)
        if (wasHidden || Math.abs(indicator.y - pos.y) < 2) {
            animIndicatorY.stop()
            animIndicatorHeight.stop()
            indicator.y = pos.y
            indicator.height = _selectedItem.height || 44
        } else {
            animIndicatorY.stop()
            animIndicatorHeight.stop()
            animIndicatorY.from = indicator.y
            animIndicatorY.to = pos.y
            animIndicatorHeight.from = indicator.height
            animIndicatorHeight.to = _selectedItem.height || 44
            if (isFinite(animIndicatorY.to) && !isNaN(animIndicatorY.to)) {
                animIndicatorY.start()
            }
            if (isFinite(animIndicatorHeight.to) && !isNaN(animIndicatorHeight.to)) {
                animIndicatorHeight.start()
            }
        }
    }

    function _snapIndicator() {
        if (!_selectedItem) return
        animIndicatorY.stop()
        animIndicatorHeight.stop()
        var pos = _selectedItem.mapToItem(root, 0, 0)
        indicator.y = pos.y
        indicator.height = _selectedItem.height || 44
    }

    property real _lastScrollTarget: -1
    property int _scrollFrameCount: 0

    function scrollToItem(item) {
        _scrollFrameCount++
        var frameCount = _scrollFrameCount
        if (!item || frameCount > 2) return
        var pos = item.mapToItem(scrollContent, 0, 0)
        if (!pos || isNaN(pos.y)) return
        var viewH = flickable.height
        var contentH = scrollContent.height
        var itemHeight = item.height || 44
        var targetY = pos.y - (viewH - itemHeight) / 2
        targetY = Math.max(0, Math.min(targetY, contentH - viewH))
        if (isNaN(targetY) || !isFinite(targetY)) return

        var currentY = flickable.contentY
        if (Math.abs(currentY - targetY) < 5) return
        if (Math.abs(targetY - _lastScrollTarget) < 1) return

        _lastScrollTarget = targetY
        scrollAnim.from = currentY
        scrollAnim.to = targetY
        scrollAnim.start()
    }

    onHighlightIndexChanged: {
        if (highlightIndex >= 0) {
            var item = _findItemByIndex(highlightIndex)
            if (item) {
                highlightItem(item)
                root.highlightChanged(highlightIndex, item)
            }
        } else {
            indicator.visible = false
        }
    }

    function _findItemByIndex(idx) {
        var items = []
        _collectItems(contentColumn, items)
        return idx >= 0 && idx < items.length ? items[idx] : null
    }

    function _collectItems(parent, items) {
        if (!parent) return
        var children = null
        try { children = parent.children } catch (e) { return }
        if (!children || children.length === undefined) return
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (typeof child.selected !== "undefined") {
                items.push(child)
            }
            _collectItems(child, items)
        }
    }

    function _scrollStep() {
        var items = []
        _collectItems(contentColumn, items)
        if (items.length === 0) return 44
        var viewH = flickable.height
        var contentY = flickable.contentY
        var totalH = 0
        var count = 0
        for (var i = 0; i < items.length; i++) {
            var h = items[i].height || 44
            var pos = items[i].mapToItem(scrollContent, 0, 0)
            var top = pos.y - contentY
            var bottom = top + h
            if (bottom > 0 && top < viewH) {
                totalH += h
                count++
            }
        }
        if (count === 0) return 44
        return Math.round(totalH / count)
    }

    function _scrollUpOne() {
        var step = _scrollStep()
        var targetY = flickable.contentY - step
        targetY = Math.max(0, targetY)
        scrollAnim.from = flickable.contentY
        scrollAnim.to = targetY
        scrollAnim.start()
    }

    function _scrollDownOne() {
        var step = _scrollStep()
        var maxY = Math.max(0, scrollContent.height - flickable.height)
        var targetY = flickable.contentY + step
        targetY = Math.min(maxY, targetY)
        scrollAnim.from = flickable.contentY
        scrollAnim.to = targetY
        scrollAnim.start()
    }

    function _selectNext() {
        var items = []
        _collectItems(contentColumn, items)
        if (highlightIndex < items.length - 1) {
            highlightIndex = highlightIndex + 1
        }
    }

    function _selectPrevious() {
        if (highlightIndex > 0) {
            highlightIndex = highlightIndex - 1
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: scrollContent.width
        contentHeight: scrollContent.height

        Item {
            id: scrollContent
            width: flickable.width
            height: Math.max(contentColumn.implicitHeight + Theme.spLg * 2, flickable.height)

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Theme.spLg
                anchors.rightMargin: Theme.spLg
                anchors.topMargin: Theme.spLg
                spacing: Theme.spSm
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    MouseArea {
        anchors.fill: flickable
        acceptedButtons: Qt.NoButton
        onWheel: function(wheel) {
            if (wheel.angleDelta.y !== 0) {
                wheel.accepted = true
                if (wheel.angleDelta.y < 0) {
                    _scrollDownOne()
                } else {
                    _scrollUpOne()
                }
            }
        }
    }

    Rectangle {
        id: indicator
        x: Theme.spLg
        y: 0
        width: parent.width - Theme.spLg * 2
        height: 44
        radius: Theme.rMd
        color: Theme.palette.surfaceActive
        visible: false
        z: 2
    }

    NumberAnimation {
        id: animIndicatorY
        target: indicator
        property: "y"
        duration: Theme.animNorm
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: animIndicatorHeight
        target: indicator
        property: "height"
        duration: Theme.animFast
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: scrollAnim
        target: flickable
        property: "contentY"
        duration: Theme.animSlow
        easing.type: Easing.OutCubic
    }

    Connections {
        target: flickable
        function onContentYChanged() {
            if (_selectedItem && indicator.visible) {
                _snapIndicator()
            }
        }
    }

    onWidthChanged: {
        if (_selectedItem) _snapIndicator()
    }

    Item {
        focus: true
        Keys.onUpPressed: _selectPrevious()
        Keys.onDownPressed: _selectNext()
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            if (highlightIndex >= 0) {
                var item = _findItemByIndex(highlightIndex)
                if (item) highlightItem(item)
            }
        })
    }
}
