import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property var values: []
    property var colors: []
    property var labels: []
    property string label: ""
    property color textColor: Theme.palette.textBright
    property color strokeColor: Theme.palette.surfaceHigh
    property real strokeWidth: 2
    property real innerRatio: 0.0
    property bool showLabels: true
    property bool showLegend: false
    property real animationDuration: Theme.animSlow
    property real startAngle: -90

    implicitWidth: 260
    implicitHeight: 260

    onValuesChanged: { canvas.requestPaint() }

    function total() {
        var t = 0
        if (!root.values) return 0
        for (var i = 0; i < root.values.length; i++)
            t += Math.max(0, root.values[i])
        return t
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: Theme.spMd

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.clearRect(0, 0, w, h)

            var data = root.values
            if (!data || data.length === 0 || total() === 0) return

            var cx = w / 2
            var cy = h / 2
            var outerR = Math.min(cx, cy) - Theme.spSm
            var innerR = outerR * root.innerRatio

            var defaultColors = [
                Theme.palette.accent,
                Theme.palette.chartAlt,
                Theme.palette.chart3,
                Theme.palette.chart4,
                Theme.palette.chart5,
                Theme.palette.chart6
            ]

            var tot = total()
            var angle = root.startAngle
            var snapAngle = 0.02

            for (var i = 0; i < data.length; i++) {
                if (data[i] <= 0) continue
                var sliceAngle = (data[i] / tot) * 360
                var endAngle = angle + sliceAngle - snapAngle

                var c = i < root.colors.length ? root.colors[i] : defaultColors[i % defaultColors.length]

                ctx.beginPath()
                if (root.innerRatio > 0) {
                    var midAngle = (angle + endAngle) / 2 * Math.PI / 180
                    var midR = (outerR + innerR) / 2
                    var lx = cx + Math.cos(midAngle) * midR
                    var ly = cy + Math.sin(midAngle) * midR
                    ctx.arc(cx, cy, outerR, angle * Math.PI / 180, endAngle * Math.PI / 180, false)
                    ctx.arc(lx, ly, 0, 0, Math.PI * 2, true)
                    ctx.arc(cx, cy, innerR, endAngle * Math.PI / 180, angle * Math.PI / 180, true)
                } else {
                    ctx.moveTo(cx, cy)
                    ctx.arc(cx, cy, outerR, (angle - 90) * Math.PI / 180, (endAngle - 90) * Math.PI / 180, false)
                    ctx.closePath()
                }

                ctx.fillStyle = c
                ctx.fill()

                if (root.strokeWidth > 0) {
                    ctx.strokeStyle = root.strokeColor
                    ctx.lineWidth = root.strokeWidth
                    ctx.stroke()
                }

                if (root.showLabels && sliceAngle > 15) {
                    var labelAngle = (angle + endAngle) / 2 * Math.PI / 180
                    var labelR = root.innerRatio > 0 ? (outerR + innerR) / 2 : outerR * 0.65
                    var lx2 = cx + Math.cos(labelAngle) * labelR
                    var ly2 = cy + Math.sin(labelAngle) * labelR
                    ctx.fillStyle = root.innerRatio > 0 ? root.textColor : Theme.palette.onAccent
                    ctx.font = Theme.fsSm + "px " + Theme.fontSans
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText(data[i].toFixed(0), lx2, ly2)
                }

                angle += sliceAngle
            }

            if (root.showLegend) {
                var lyPos = h + Theme.spMd
                ctx.font = Theme.fsXs + "px " + Theme.fontSans
                var lxPos = 0
                for (var li = 0; li < data.length; li++) {
                    var lc = li < root.colors.length ? root.colors[li] : defaultColors[li % defaultColors.length]
                    var llabel = li < root.labels.length ? root.labels[li] : ""
                    var tw = ctx.measureText(llabel).width
                    if (lxPos + tw + 24 > w) { lxPos = 0; lyPos += Theme.fsXs + Theme.spSm }
                    ctx.fillStyle = lc
                    ctx.fillRect(lxPos, lyPos - Theme.fsXs + 2, 10, 10)
                    ctx.fillStyle = root.textColor
                    ctx.textAlign = "left"
                    ctx.fillText(llabel, lxPos + 14, lyPos)
                    lxPos += tw + 24 + Theme.spMd
                }
            }
        }
    }
}
