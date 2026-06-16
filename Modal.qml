import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import FDF as FDF

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool showClose: true
    property int lifted: 0
    property real maxWidth: 480
    property string transitionType: "scale"
    property int transitionDuration: Theme.animNorm
    property real overlayOpacity: 0.55
    property bool slideWithContent: true

    default property alias content: contentColumn.data

    signal accepted()
    signal rejected()

    function open() { popup.open() }
    function close() { popup.close() }

    width: 0
    height: 0

    Popup {
        id: popup
        parent: root.parent
        x: parent ? (parent.width - width) / 2 : 0
        y: parent ? (parent.height - height) / 2 : 0
        modal: true
        dim: true
        closePolicy: Popup.CloseOnPressOutside
        padding: 0
        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
        width: root.width > 0 ? root.width : Math.min(parent.width * 0.85, root.maxWidth)
        height: root.height > 0 ? root.height : implicitHeight

        Overlay.modal: Rectangle {
            color: FDF.Theme.palette.overlayModal
            Behavior on opacity { NumberAnimation { duration: Theme.animNorm } }
        }

        enter: Transition {
            id: enterTrans
            enabled: root.transitionDuration > 0
            ParallelAnimation {
                NumberAnimation {
                    target: popup.contentItem; property: "opacity"
                    from: 0; to: 1; duration: root.transitionDuration; easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: popup.contentItem; property: "scale"
                    from: root.transitionType === "scale" ? 0.92 : (root.transitionType === "fade" ? 1.0 : 1.0)
                    to: 1.0; duration: root.transitionDuration; easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: popup.contentItem; property: "translateX"
                    from: root.transitionType === "slideUp" ? 0 : (root.transitionType === "slideRight" ? 48 : 0)
                    to: 0; duration: root.transitionDuration; easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: popup.contentItem; property: "translateY"
                    from: root.transitionType === "slideUp" ? 48 : (root.transitionType === "slideDown" ? -48 : 0)
                    to: 0; duration: root.transitionDuration; easing.type: Easing.OutCubic
                }
            }
        }

        exit: Transition {
            enabled: root.transitionDuration > 0
            ParallelAnimation {
                NumberAnimation {
                    target: popup.contentItem; property: "opacity"
                    from: 1; to: 0; duration: root.transitionDuration * 0.6; easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: popup.contentItem; property: "scale"
                    from: 1.0; to: root.transitionType === "scale" ? 0.95 : 1.0
                    duration: root.transitionDuration * 0.6; easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: popup.contentItem; property: "translateY"
                    from: 0; to: root.transitionType === "slideUp" ? 24 : 0
                    duration: root.transitionDuration * 0.6; easing.type: Easing.InCubic
                }
            }
        }

        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: FDF.Theme.rWindow

            layer.enabled: root.lifted > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.55)
                shadowBlur: Math.min(root.lifted * 0.15, 0.6)
                autoPaddingEnabled: true
            }
        }

        contentItem: Rectangle {
            id: cntItem
            color: FDF.Theme.palette.surfaceHigh
            radius: FDF.Theme.rWindow
            clip: true

            property real translateX: 0
            property real translateY: 0
            transform: Translate { x: cntItem.translateX; y: cntItem.translateY }

            implicitWidth: Math.min(root.parent ? root.parent.width * 0.85 : root.maxWidth, root.maxWidth)
            implicitHeight: contentColumn.implicitHeight + (headerBar.visible ? headerBar.implicitHeight : 0) + FDF.Theme.spLg

            Item {
                anchors.fill: parent

                Rectangle {
                    id: headerBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 32
                    z: 2
                    color: FDF.Theme.palette.surface
                    topLeftRadius: FDF.Theme.rWindow
                    topRightRadius: FDF.Theme.rWindow
                    visible: root.title !== "" || root.showClose

                    FDF.Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: FDF.Theme.spMd
                        text: root.title
                        variant: "bold"
                        elide: Text.ElideRight
                    }

                    FDF.FButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: FDF.Theme.spXs
                        visible: root.showClose
                        icon: "\uf00d"
                        variant: "ghost"
                        noBorder: true
                        fontSize: FDF.Theme.fsSm
                        implicitWidth: 20; implicitHeight: 20
                        onClicked: { root.rejected(); popup.close() }
                    }
                }

                Rectangle {
                    id: divider
                    anchors.top: headerBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    z: 2
                    visible: headerBar.visible
                    color: FDF.Theme.palette.divider
                }

                ColumnLayout {
                    id: contentColumn
                    anchors.top: (divider.visible ? divider.bottom : headerBar.bottom)
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: FDF.Theme.spLg
                    anchors.rightMargin: FDF.Theme.spLg
                    anchors.topMargin: FDF.Theme.spLg
                    anchors.bottomMargin: FDF.Theme.spLg
                    spacing: FDF.Theme.spMd
                }
            }
        }

        Shortcut {
            sequence: "Enter"
            enabled: popup.opened
            onActivated: { root.accepted(); popup.close() }
        }
    }
}
