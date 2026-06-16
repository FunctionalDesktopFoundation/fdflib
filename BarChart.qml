import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property var values: []
    property string label: ""
    property color barColor: Theme.palette.accent
    property color barColorAlt: Theme.palette.chartAlt
    property color gridColor: Theme.palette.divider
    property color textColor: Theme.palette.textDim
    property real barSpacing: 0.3
    property real cornerRadius: 2
    property bool showLabels: true
    property bool showGrid: true
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
        return m > 0 ? m * 1.15 : 1
    }

    function computeMin() {
        if (root.maxValue > root.minValue) return root.minValue
        if (!root.values || root.values.length === 0) return 0
        var m = root.values[0]
        for (var i = 1; i < root.values.length; i++)
            if (root.values[i] < m) m = root.values[i]
        return m > 0 ? 0 : m * 1.15
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
            if (!data || data.length === 0) return

            var lo = computeMin()
            var hi = computeMax()
            var range = hi - lo
            if (range === 0) range = 1

            var count = data.length
            var barArea = w / count
            var barW = barArea * (1 - root.barSpacing)
            var pad = barArea * root.barSpacing / 2

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

            for (var i = 0; i < count; i++) {
                var v = data[i]
                var barH = ((v - lo) / range) * h
                var bx = i * barArea + pad
                var by = h - barH

                ctx.fillStyle = i % 2 === 0 ? root.barColor : root.barColorAlt
                ctx.beginPath()
                var r = Math.min(root.cornerRadius, barW / 2)
                ctx.moveTo(bx + r, by)
                ctx.lineTo(bx + barW - r, by)
                ctx.arcTo(bx + barW, by, bx + barW, by + r, r)
                ctx.lineTo(bx + barW, h)
                ctx.lineTo(bx, h)
                ctx.lineTo(bx, by + r)
                ctx.arcTo(bx, by, bx + r, by, r)
                ctx.closePath()
                ctx.fill()

                if (root.showLabels) {
                    ctx.fillStyle = root.textColor
                    ctx.font = Theme.fsXs + "px " + Theme.fontSans
                    ctx.textAlign = "center"
                    ctx.fillText(v.toFixed(1), bx + barW / 2, by - Theme.spSm)
                }
            }
        }
    }
}
