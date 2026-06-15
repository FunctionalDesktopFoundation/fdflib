import QtQuick
import QtQuick.Controls
import FDF

Input {
    id: root

    property alias query: root.text
    property bool showClear: true

    signal searched(string query)
    signal cleared()

    placeholderText: "Search..."
    leftPadding: Theme.sp2xl
    rightPadding: root.showClear ? Theme.sp2xl : Theme.spLg

    FIcon {
        anchors { left: parent.left; leftMargin: Theme.spMd; verticalCenter: parent.verticalCenter }
        icon: "\uf002"
        pixelSize: Theme.fsSm
        color: Theme.palette.textDim
    }

    FButton {
        visible: root.showClear && root.text !== ""
        anchors { right: parent.right; rightMargin: Theme.spXs; verticalCenter: parent.verticalCenter }
        icon: "\uf00d"
        variant: "ghost"
        fontSize: Theme.fsBase
        onClicked: {
            root.text = ""
            root.cleared()
            root.searched("")
        }
    }

    onAccepted: root.searched(root.text)

    Accessible.role: Accessible.Search
    Accessible.name: root.placeholderText
}
