import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property var values: []
    property color lineColor: Theme.palette.accent
    property color fillColor: Qt.rgba(0.29, 0.56, 0.85, 0.12)
    property real lineWidth: 1.5
    property bool fillArea: true
    property bool smooth: true
    property color latestColor: Theme.palette.accent
    property bool showLatest: true

    implicitWidth: 120
    implicitHeight: 32

    onValuesChanged: { canvas.requestPaint() }

    function computeMax() {
        if (!root.values || root.values.length === 0) return 1
        var m = root.values[0]
        for (var i = 1; i < root.values.length; i++)
            if (root.values[i] > m) m = root.values[i]
        return m > 0 ? m * 1.1 : 1
    }

    function computeMin() {
        if (!root.values || root.values.length === 0) return 0
        var m = root.values[0]
        for (var i = 1; i < root.values.length; i++)
            if (root.values[i] < m) m = root.values[i]
        return m > 0 ? 0 : m * 1.1
    }

    Canvas {
        id: canvas
        anchors.fill: parent

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
                points.push({
                    x: i * stepX,
                    y: h - ((data[i] - lo) / range) * h
                })
            }

            if (root.fillArea) {
                ctx.beginPath()
                if (root.smooth) {
                    ctx.moveTo(points[0].x, points[0].y)
                    for (var fi = 1; fi < points.length - 1; fi++) {
                        var xc = (points[fi].x + points[fi + 1].x) / 2
                        var yc = (points[fi].y + points[fi + 1].y) / 2
                        ctx.quadraticCurveTo(points[fi].x, points[fi].y, xc, yc)
                    }
                    ctx.lineTo(points[count - 1].x, points[count - 1].y)
                } else {
                    ctx.moveTo(points[0].x, points[0].y)
                    for (var li = 1; li < points.length; li++)
                        ctx.lineTo(points[li].x, points[li].y)
                }
                ctx.lineTo(points[count - 1].x, h)
                ctx.lineTo(points[0].x, h)
                ctx.closePath()
                ctx.fillStyle = root.fillColor
                ctx.fill()
            }

            ctx.beginPath()
            if (root.smooth) {
                ctx.moveTo(points[0].x, points[0].y)
                for (var si = 1; si < points.length - 1; si++) {
                    var xc2 = (points[si].x + points[si + 1].x) / 2
                    var yc2 = (points[si].y + points[si + 1].y) / 2
                    ctx.quadraticCurveTo(points[si].x, points[si].y, xc2, yc2)
                }
                ctx.lineTo(points[count - 1].x, points[count - 1].y)
            } else {
                ctx.moveTo(points[0].x, points[0].y)
                for (var li2 = 1; li2 < points.length; li2++)
                    ctx.lineTo(points[li2].x, points[li2].y)
            }
            ctx.strokeStyle = root.lineColor
            ctx.lineWidth = root.lineWidth
            ctx.stroke()

            if (root.showLatest && points.length > 0) {
                var last = points[points.length - 1]
                ctx.beginPath()
                ctx.arc(last.x, last.y, 2.5, 0, Math.PI * 2)
                ctx.fillStyle = root.latestColor
                ctx.fill()
            }
        }
    }
}
