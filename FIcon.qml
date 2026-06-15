import QtQuick
import QtQuick.Controls
import FDF

Item {
    id: root

    property string icon: ""
    property int pixelSize: Theme.fsMd
    property color color: Theme.palette.onSurface
    property string fontFamily: Theme.fontMono

    property bool _isImage: icon.startsWith("/") || icon.startsWith("./") || icon.startsWith("file://") || icon.startsWith("http://") || icon.startsWith("https://")
    property bool _isFont: !_isImage && icon.length > 0 && icon.charCodeAt(0) >= 0xE000
    property string _xdgPath: ""

    implicitWidth: {
        if (_isImage) return imageItem.implicitWidth || pixelSize + 4
        if (_xdgPath) return imageItem.implicitWidth || pixelSize + 4
        return fontItem.implicitWidth
    }
    implicitHeight: {
        if (_isImage) return imageItem.implicitHeight || pixelSize + 4
        if (_xdgPath) return imageItem.implicitHeight || pixelSize + 4
        return fontItem.implicitHeight
    }

    onIconChanged: resolveIcon()

    function resolveIcon() {
        if (!icon || _isImage || _isFont) {
            _xdgPath = ""
            return
        }
        if (typeof bridge !== "undefined" && typeof bridge.xdgIconPath === "function") {
            _xdgPath = bridge.xdgIconPath(icon)
        } else {
            _xdgPath = xdgJsFallback(icon)
        }
    }

    function xdgJsFallback(name) {
        var dirs = bridge ? [
            bridge.homeDir() + "/.icons",
            bridge.homeDir() + "/.local/share/icons",
            "/usr/share/icons",
            "/usr/local/share/icons"
        ] : []
        var themes = ["hicolor", "Adwaita", "Papirus", "gnome", "Breeze"]
        var sizes = ["scalable", "48x48", "32x32", "24x24", "22x22", "16x16", "64x64"]
        var categories = ["apps", "actions", "places", "devices", "mimetypes", "status", "emblems"]
        var exts = [".svg", ".svgz", ".png", ".xpm"]

        if (typeof _xdgCache === "undefined") {
            _xdgCache = ({})
            _xdgCacheHits = ({})
        }
        if (_xdgCache[name]) return _xdgCache[name]

        for (var ti = 0; ti < themes.length; ti++) {
            for (var di = 0; di < dirs.length; di++) {
                var td = dirs[di] + "/" + themes[ti]
                if (bridge && !bridge.fileExists(td)) continue
                for (var si = 0; si < sizes.length; si++) {
                    for (var ci = 0; ci < categories.length; ci++) {
                        for (var ei = 0; ei < exts.length; ei++) {
                            var p = td + "/" + sizes[si] + "/" + categories[ci] + "/" + name + exts[ei]
                            if (bridge && bridge.fileExists(p)) {
                                _xdgCache[name] = p
                                return p
                            }
                        }
                    }
                }
                for (var ei2 = 0; ei2 < exts.length; ei2++) {
                    var p2 = td + "/" + name + exts[ei2]
                    if (bridge && bridge.fileExists(p2)) {
                        _xdgCache[name] = p2
                        return p2
                    }
                }
            }
        }
        _xdgCache[name] = ""
        return ""
    }

    Image {
        id: imageItem
        visible: (_isImage || _xdgPath) && status !== Image.Error
        source: _isImage ? root.icon : _xdgPath
        sourceSize.width: root.pixelSize + 4
        sourceSize.height: root.pixelSize + 4
        fillMode: Image.PreserveAspectFit
        smooth: true
        anchors.centerIn: parent
    }

    Text {
        id: fontItem
        visible: !_isImage && !_xdgPath && root.icon !== ""
        text: root.icon
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        color: root.color
        anchors.centerIn: parent
    }
}
