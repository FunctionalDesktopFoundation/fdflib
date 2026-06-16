import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property var values: []
    property string label: ""
    property color lineColor: Theme.palette.accent
    property color fillColor: Qt.rgba(0.29, 0.56, 0.85, 0.15)
    property color gridColor: Theme.palette.divider
    property color textColor: Theme.palette.textDim
    property color pointColor: Theme.palette.accent
    property real lineWidth: 2
    property real pointSize: 4
    property bool showPoints: true
    property bool showLabels: true
    property bool showGrid: true
    property bool fillArea: true
    property bool smooth: true
    property real minValue: 0
    property real maxValue: 0
    property real gridLines: 4
    property real animationDuration: Theme.animSlow

    implicitWidth: 320
    implicitHeight: 200

    onValuesChanged: { canvas.requestPaint() }
    onMinValueChanged: { canvas.requestPaint() }
    onMaxValueChanged: { canvas.requestPaint() }

    function computeMax() {
        if (root.maxValue > root.minValue) return root.maxValue
        if (!root.values || root.values.length === 0) return 1
        var m = root.values[0]
        for (var i = 1; i < root.values.length; i++)
            if (root.values[i] > m) m = root.values[i]
        return m > 0 ? m * 1.1 : 1
    }

    function computeMin() {
        if (root.maxValue > root.minValue) return root.minValue
        if (!root.values || root.values.length === 0) return 0
        var m = root.values[0]
        for (var i = 1; i < root.values.length; i++)
            if (root.values[i] < m) m = root.values[i]
        return m > 0 ? 0 : m * 1.1
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.topMargin: Theme.spMd
        anchors.bottomMargin: Theme.spLg + (root.showLabels ? Theme.fsSm : 0)
        anchors.leftMargin: root.showLabels ? Theme.fsXl + Theme.spSm : Theme.spSm
        anchors.rightMargin: Theme.spMd

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.clearRect(0, 0, w, h)

            var data = root.values
            if (!data || data.length < 2) return

            var lo = computeMin()
            var hi = computeMax()
            var range = hi - lo
            if (range === 0) range = 1

            var count = data.length
            var stepX = w / (count - 1)

            var points = []
            for (var i = 0; i < count; i++) {
                var px = i * stepX
                var py = h - ((data[i] - lo) / range) * h
                points.push({ x: px, y: py })
            }

            if (root.showGrid) {
                ctx.strokeStyle = root.gridColor
                ctx.lineWidth = 1
                for (var g = 0; g <= root.gridLines; g++) {
                    var gy = h - (g / root.gridLines) * h
                    ctx.beginPath()
                    ctx.moveTo(0, gy)
                    ctx.lineTo(w, gy)
                    ctx.stroke()

                    if (root.showLabels) {
                        var gv = lo + (g / root.gridLines) * range
                        ctx.fillStyle = root.textColor
                        ctx.font = Theme.fsXs + "px " + Theme.fontSans
                        ctx.textAlign = "right"
                        ctx.fillText(gv.toFixed(1), -Theme.spSm, gy + Theme.fsXs / 3)
                    }
                }
            }

            var lineFn = root.smooth ? drawSmoothPath : drawLinearPath

            if (root.fillArea) {
                ctx.beginPath()
                lineFn(ctx, points, lo, range)
                ctx.lineTo(points[count - 1].x, h)
                ctx.lineTo(points[0].x, h)
                ctx.closePath()
                ctx.fillStyle = root.fillColor
                ctx.fill()
            }

            ctx.beginPath()
            ctx.strokeStyle = root.lineColor
            ctx.lineWidth = root.lineWidth
            lineFn(ctx, points, lo, range)
            ctx.stroke()

            if (root.showPoints) {
                for (var p = 0; p < points.length; p++) {
                    ctx.beginPath()
                    ctx.arc(points[p].x, points[p].y, root.pointSize, 0, Math.PI * 2)
                    ctx.fillStyle = root.pointColor
                    ctx.fill()
                    ctx.strokeStyle = Theme.palette.surfaceHigh
                    ctx.lineWidth = 1.5
                    ctx.stroke()
                }
            }

            if (root.showLabels) {
                ctx.fillStyle = root.textColor
                ctx.font = Theme.fsXs + "px " + Theme.fontSans
                ctx.textAlign = "center"
                for (var li = 0; li < count; li++) {
                    if (count <= 8 || li % Math.ceil(count / 8) === 0 || li === count - 1) {
                        ctx.fillText(li.toString(), points[li].x, h + Theme.fsSm + Theme.spSm)
                    }
                }
            }
        }

        function drawLinearPath(ctx, pts) {
            ctx.moveTo(pts[0].x, pts[0].y)
            for (var i = 1; i < pts.length; i++)
                ctx.lineTo(pts[i].x, pts[i].y)
        }

        function drawSmoothPath(ctx, pts) {
            ctx.moveTo(pts[0].x, pts[0].y)
            for (var i = 1; i < pts.length - 1; i++) {
                var xc = (pts[i].x + pts[i + 1].x) / 2
                var yc = (pts[i].y + pts[i + 1].y) / 2
                ctx.quadraticCurveTo(pts[i].x, pts[i].y, xc, yc)
            }
            ctx.lineTo(pts[pts.length - 1].x, pts[pts.length - 1].y)
        }
    }
}
