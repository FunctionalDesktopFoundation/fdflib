import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FDF

Rectangle {
    id: root

    property string title: ""
    property bool showBack: false
    property bool showForward: false
    property bool showRefresh: true
    property var pageView: null
    property alias leftItems: leftRow.data
    property alias rightItems: rightRow.data
    property bool collapsed: width < root.breakpoint
    property int breakpoint: Theme.bpSm
    property alias menuOpen: menuDrawer.visible
    property bool refreshing: false

    implicitHeight: Theme.headH
    color: Theme.palette.surface
    z: 10

    onPageViewChanged: {
        if (pageView) {
            pageView.pageSwitched.connect(function() {
                root.title = pageView.currentTitle
                root.showBack = pageView.canGoBack
                root.showForward = pageView.canGoForward
            })
            pageView.pagePushed.connect(function() {
                root.showBack = true
            })
            pageView.pagePopped.connect(function() {
                root.showBack = pageView.canGoBack
            })
        }
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1; color: Theme.palette.borderMid
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spLg
        anchors.rightMargin: Theme.spLg
        spacing: Theme.spMd

        RowLayout {
            id: leftRow
            spacing: Theme.spXs

            FButton {
                visible: root.showBack && !root.collapsed
                icon: "\uf053"
                variant: "ghost"
                onClicked: root.pageView ? root.pageView.goBack() : root.goBack()
            }

            FButton {
                visible: root.showForward && !root.collapsed
                icon: "\uf054"
                variant: "ghost"
                onClicked: root.pageView ? root.pageView.goForward() : root.goForward()
            }
        }

        Label {
            visible: !root.collapsed
            text: root.title
            variant: "heading"
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        FButton {
            visible: root.showRefresh && !root.collapsed
            icon: "\uf021"
            variant: "ghost"
            busy: root.refreshing
            onClicked: {
                root.refreshing = true
                if (root.pageView) root.pageView.refresh()
                refreshAnim.restart()
            }
        }

        FButton {
            visible: root.collapsed
            icon: "\uf0c9"
            variant: "ghost"
            onClicked: menuDrawer.open()
        }

        RowLayout {
            id: rightRow
            spacing: Theme.spSm
            Layout.alignment: Qt.AlignRight
        }
    }

    SequentialAnimation {
        id: refreshAnim
        PauseAnimation { duration: 800 }
        onFinished: root.refreshing = false
    }

    Drawer {
        id: menuDrawer
        width: 260
        height: parent.parent ? parent.parent.height : 400
        edge: Qt.LeftEdge
        dim: true

        background: Rectangle { color: Theme.palette.surface }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.sp2xl
            spacing: Theme.spMd

            Label { text: root.title; variant: "heading" }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.border }

            FButton {
                visible: root.showBack
                icon: "\uf053"
                variant: "ghost"
                onClicked: { root.pageView ? root.pageView.goBack() : root.goBack(); menuDrawer.close() }
            }
                FButton {
                    visible: root.showRefresh
                    icon: "\uf021"
                    variant: "ghost"
                    onClicked: {
                        if (root.pageView) root.pageView.refresh()
                        root.refreshing = true
                        refreshAnim.restart()
                        menuDrawer.close()
                    }
                }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.palette.border }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                children: root.leftItems
            }
        }
    }

    signal goBack()
    signal goForward()
    function open() { menuDrawer.open() }
    function close() { menuDrawer.close() }
}
