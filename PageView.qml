import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var pages: []
    property int currentIndex: 0
    property string currentTitle: pages.length > 0 ? pages[currentIndex].title : ""

    readonly property bool canGoBack: currentIndex > 0
    readonly property bool canGoForward: currentIndex < pages.length - 1
    readonly property int depth: pages.length

    implicitWidth: _activeItem ? _activeItem.implicitWidth : 400
    implicitHeight: _activeItem ? _activeItem.implicitHeight : 300

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    clip: true

    signal pagePushed(int index, var page)
    signal pagePopped(int index)
    signal pageSwitched(int index, var page)
    signal refreshed()

    property int _activeLoader: 0
    property Item _outItem: null
    property Item _activeItem: loader0.item ? loader0.item : loader1.item
    property bool _transitioning: false

    function push(page) {
        if (_transitioning) return
        var entry = typeof page === "string" ? { title: page } : page
        pages.push(entry)
        var newIdx = pages.length - 1
        currentIndex = newIdx
        _doTransition(newIdx, root.width, -root.width)
        root.pagePushed(newIdx, entry)
    }

    function pop() {
        if (_transitioning || !canGoBack) return
        pages.pop()
        var newIdx = pages.length - 1
        currentIndex = newIdx
        _doTransition(newIdx, -root.width, root.width)
        root.pagePopped(newIdx)
    }

    function goBack() {
        if (_transitioning || !canGoBack) return
        currentIndex--
        _doTransition(currentIndex, -root.width, root.width)
        root.pageSwitched(currentIndex, pages[currentIndex])
    }

    function goForward() {
        if (_transitioning || !canGoForward) return
        currentIndex++
        _doTransition(currentIndex, root.width, -root.width)
        root.pageSwitched(currentIndex, pages[currentIndex])
    }

    function goTo(index) {
        if (index < 0 || index >= pages.length || index === currentIndex || _transitioning) return
        var delta = index - currentIndex
        var fromX = delta > 0 ? root.width : -root.width
        var outTo = delta > 0 ? -root.width : root.width
        currentIndex = index
        _doTransition(index, fromX, outTo)
        root.pageSwitched(index, pages[index])
    }

    function replace(page) {
        if (_transitioning) return
        if (pages.length === 0) { push(page); return }
        pages[pages.length - 1] = typeof page === "string" ? { title: page } : page
        _doTransition(currentIndex, 0, -root.width)
        root.pageSwitched(root.currentIndex, pages[root.currentIndex])
    }

    function refresh() {
        if (_transitioning) return
        _doTransition(currentIndex, 0, -root.width)
        root.refreshed()
    }

    function _doTransition(index, fromX, outTo) {
        if (_transitioning) return
        _transitioning = true

        var oldLoaderIdx = _activeLoader
        var newLoaderIdx = 1 - _activeLoader

        var oldLdr = oldLoaderIdx === 0 ? loader0 : loader1
        var newLdr = newLoaderIdx === 0 ? loader0 : loader1

        var comp = pages.length > 0 ? pages[index].component : null

        _outItem = oldLdr.item

        newLdr.sourceComponent = comp
        newLdr.visible = true

        var newItem = newLdr.item
        if (newItem) {
            newItem.x = fromX
        }

        if (_outItem && newItem) {
            _outItem.z = 1
            newItem.z = 2

            outAnimX.target = _outItem
            outAnimX.to = outTo

            inAnimX.target = newItem
            inAnimX.to = 0

            animOutIn.start()
        } else if (newItem) {
            newItem.z = 1
            inAnimX.target = newItem
            inAnimX.to = 0
            inAnimX.start()
            Qt.callLater(root._finishTransition)
        } else {
            Qt.callLater(root._finishTransition)
        }

        _activeLoader = newLoaderIdx
    }

    function _finishTransition() {
        var oldLoaderIdx = 1 - _activeLoader
        var oldLdr = oldLoaderIdx === 0 ? loader0 : loader1
        if (oldLdr.item) oldLdr.item.z = 1
        oldLdr.sourceComponent = null
        oldLdr.visible = false
        _outItem = null
        _transitioning = false
    }

    ParallelAnimation {
        id: animOutIn
        NumberAnimation { id: outAnimX; property: "x"; duration: Theme.animNorm; easing.type: Easing.OutCubic }
        NumberAnimation { id: inAnimX; property: "x"; duration: Theme.animNorm; easing.type: Easing.OutCubic }
        onFinished: root._finishTransition()
    }

    Loader {
        id: loader0
        width: parent.width
        height: parent.height
        visible: _activeLoader === 0
        clip: true
        z: 1

        Binding { target: loader0.item; property: "width"; value: loader0.width; when: loader0.item }
        Binding { target: loader0.item; property: "height"; value: loader0.height; when: loader0.item }
    }

    Loader {
        id: loader1
        width: parent.width
        height: parent.height
        visible: _activeLoader === 1
        clip: true
        z: 1

        Binding { target: loader1.item; property: "width"; value: loader1.width; when: loader1.item }
        Binding { target: loader1.item; property: "height"; value: loader1.height; when: loader1.item }
    }

    Component.onCompleted: {
        if (pages.length > 0) {
            var ldr = _activeLoader === 0 ? loader0 : loader1
            ldr.sourceComponent = pages[currentIndex].component
        }
    }
}
