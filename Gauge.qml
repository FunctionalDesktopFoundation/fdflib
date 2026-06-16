import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 100
    property string label: ""
    property string unit: ""
    property color activeColor: Theme.palette.accent
    property color trackColor: Theme.palette.surfaceActive
    property color textColor: Theme.palette.textBright
    property color labelColor: Theme.palette.textDim
    property real startAngle: -140
    property real spanAngle: 280
    property real strokeWidth: 12
    property real tickCount: 10
    property bool showTicks: true
    property bool showValue: true
    property real animationDuration: Theme.animSlow
    property int decimalPlaces: 0

    implicitWidth: 200
    implicitHeight: 200

    readonly property real ratio: Math.max(0, Math.min(1, (value - from) / (to - from)))

    onRatioChanged: { canvas.requestPaint() }

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: Theme.spMd

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.clearRect(0, 0, w, h)

            var cx = w / 2
            var cy = h / 2
            var r = Math.min(cx, cy) - root.strokeWidth
            var startRad = root.startAngle * Math.PI / 180
            var spanRad = root.spanAngle * Math.PI / 180

            ctx.lineCap = "round"

            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, startRad + spanRad, false)
            ctx.strokeStyle = root.trackColor
            ctx.lineWidth = root.strokeWidth
            ctx.stroke()

            var activeAngle = startRad + spanRad * root.ratio
            ctx.beginPath()
            ctx.arc(cx, cy, r, startRad, activeAngle, false)
            ctx.strokeStyle = root.activeColor
            ctx.lineWidth = root.strokeWidth
            ctx.stroke()

            if (root.showTicks) {
                ctx.strokeStyle = root.labelColor
                ctx.lineWidth = 1
                for (var t = 0; t <= root.tickCount; t++) {
                    var ta = startRad + (t / root.tickCount) * spanRad
                    var inner = r - root.strokeWidth / 2 - 6
                    var outer = r - root.strokeWidth / 2
                    ctx.beginPath()
                    ctx.moveTo(cx + Math.cos(ta) * inner, cy + Math.sin(ta) * inner)
                    ctx.lineTo(cx + Math.cos(ta) * outer, cy + Math.sin(ta) * outer)
                    ctx.stroke()
                }
            }

            if (root.showValue) {
                ctx.fillStyle = root.textColor
                ctx.font = Theme.fs2xl + "px " + Theme.fontSans
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText(root.value.toFixed(root.decimalPlaces), cx, cy - Theme.spSm)
            }

            if (root.unit !== "") {
                ctx.fillStyle = root.labelColor
                ctx.font = Theme.fsBase + "px " + Theme.fontSans
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText(root.unit, cx, cy + Theme.fsLg)
            }

            if (root.label !== "") {
                ctx.fillStyle = root.labelColor
                ctx.font = Theme.fsXs + "px " + Theme.fontSans
                ctx.textAlign = "center"
                ctx.textBaseline = "top"
                ctx.fillText(root.label, cx, r + root.strokeWidth + Theme.spMd)
            }
        }
    }
}
