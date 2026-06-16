pragma Singleton
import QtQuick

QtObject {
    id: theme

    property bool darkMode: true
    property string accentColor: "#FFFFFF"

    function hexToRgb(hex) {
        var c = hex.replace("#", "")
        return {
            r: parseInt(c.substring(0, 2), 16) / 255,
            g: parseInt(c.substring(2, 4), 16) / 255,
            b: parseInt(c.substring(4, 6), 16) / 255
        }
    }

    function rgbToHex(r, g, b) {
        var toHex = function(v) {
            var h = Math.round(Math.max(0, Math.min(255, v * 255))).toString(16)
            return h.length === 1 ? "0" + h : h
        }
        return "#" + toHex(r) + toHex(g) + toHex(b)
    }

    function rgbToHls(r, g, b) {
        var mx = Math.max(r, g, b), mn = Math.min(r, g, b)
        var h, l = (mx + mn) / 2, s
        if (mx === mn) {
            h = 0; s = 0
        } else {
            var d = mx - mn
            s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn)
            if (mx === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6
            else if (mx === g) h = ((b - r) / d + 2) / 6
            else h = ((r - g) / d + 4) / 6
        }
        return { h: h, l: l, s: s }
    }

    function hlsToRgb(h, l, s) {
        var r, g, b
        if (s === 0) {
            r = l; g = l; b = l
        } else {
            var hue2rgb = function(p, q, t) {
                if (t < 0) t += 1
                if (t > 1) t -= 1
                if (t < 1/6) return p + (q - p) * 6 * t
                if (t < 1/2) return q
                if (t < 2/3) return p + (q - p) * (2/3 - t) * 6
                return p
            }
            var q = l < 0.5 ? l * (1 + s) : l + s - l * s
            var p = 2 * l - q
            r = hue2rgb(p, q, h + 1/3)
            g = hue2rgb(p, q, h)
            b = hue2rgb(p, q, h - 1/3)
        }
        return { r: r, g: g, b: b }
    }

    function hexToHls(hex) {
        var c = hexToRgb(hex)
        return rgbToHls(c.r, c.g, c.b)
    }

    function hlsToHex(h, l, s) {
        var c = hlsToRgb(h, l, s)
        return rgbToHex(c.r, c.g, c.b)
    }

    function clamp(v, mn, mx) { return Math.max(mn, Math.min(mx, v)) }

    function applyAlpha(hex, alpha) {
        var c = hexToRgb(hex)
        return Qt.rgba(c.r, c.g, c.b, alpha)
    }

    function isLight(hex) {
        var c = hexToRgb(hex)
        return c.r * 0.299 + c.g * 0.587 + c.b * 0.114 > 0.5
    }

    function getTone(hue, chroma, toneVal) {
        var lightness = toneVal / 100.0
        var c = hlsToRgb(hue, lightness, chroma)
        return rgbToHex(c.r, c.g, c.b)
    }

    function generateMaterialTheme(accentHex, isDark) {
        var hls = hexToHls(accentHex)
        var sourceH = hls.h
        var sourceS = hls.s

        var palettes = {
            accent1:  { hue: sourceH, chroma: Math.min(sourceS, 0.48) },
            accent2:  { hue: sourceH, chroma: Math.min(sourceS, 0.16) },
            accent3:  { hue: (sourceH + 60/360.0) % 1.0, chroma: Math.min(sourceS, 0.38) },
            neutral1: { hue: sourceH, chroma: Math.min(sourceS, 0.10) },
            neutral2: { hue: sourceH, chroma: Math.min(sourceS, 0.18) }
        }

        var a1 = function(t) { return getTone(palettes.accent1.hue, palettes.accent1.chroma, t) }
        var a2 = function(t) { return getTone(palettes.accent2.hue, palettes.accent2.chroma, t) }
        var n1 = function(t) { return getTone(palettes.neutral1.hue, palettes.neutral1.chroma, t) }
        var n2 = function(t) { return getTone(palettes.neutral2.hue, palettes.neutral2.chroma, t) }
        var err = function(t) { return getTone(0.0, 0.8, t) }
        var suc = function(t) { return getTone(0.33, 0.7, t) }

        if (isDark) {
            var primary           = a1(80)
            var onPrimary         = a1(20)
            var primaryContainer  = a1(30)
            var onPrimaryContainer= a1(90)
            var secondary         = a2(80)
            var secondaryContainer= a2(30)
            var bg                = n1(6)
            var onBg              = n1(90)
            var surface           = n1(6)
            var onSurface         = n1(90)
            var surfaceVariant    = n2(30)
            var onSurfaceVariant  = n2(80)
            var outline           = n2(50)
            var surfaceHigh       = n1(10)
            var surfaceAlt        = n1(4)

            return {
                bg: bg,
                surface: surface,
                surfaceHigh: surfaceHigh,
                surfaceAlt: surfaceAlt,
                sidebarBg: surface,
                border: outline,
                borderFocus: primary,
                borderMid: n2(40),
                divider: n2(20),
                accent: primary,
                accentContainer: primaryContainer,
                accentDim: a1(60),
                onAccent: onPrimary,
                textBright: onSurface,
                textDim: onSurfaceVariant,
                onSurface: onSurface,
                onSurfaceMid: n1(70),
                onSurfaceDim: n1(50),
                error: err(80),
                errorContainer: err(30),
                errorText: err(80),
                success: suc(75),
                successDim: applyAlpha(suc(75), 0.2),
                green: suc(75),
                blue: getTone(0.59, 0.6, 75),
                orange: getTone(0.10, 0.7, 80),
                purple: getTone(0.75, 0.6, 75),
                warn: getTone(0.10, 0.7, 80),
                island: n1(4),
                highlightBg: a1(20),
                shadow: "#00000088",
                overlayDim: applyAlpha("#000000", 0.20),
                overlayBase: applyAlpha("#000000", 0.25),
                overlayModal: applyAlpha("#000000", 0.50),
                overlayPanel: Qt.rgba(0.08, 0.08, 0.09, 0.95),
                surfaceOverlay: applyAlpha("#FFFFFF", 0.02),
                surfaceHover: applyAlpha("#FFFFFF", 0.04),
                surfaceActive: applyAlpha("#FFFFFF", 0.06),
                surfacePressed: applyAlpha("#FFFFFF", 0.08),
                surfaceRaised: applyAlpha("#FFFFFF", 0.12),
                toggleOn: primary,
                toggleOff: n2(30),
                toggleKnob: "#000000",
                toggleKnobOff: applyAlpha("#FFFFFF", 0.35),
                trafficRed: "#FF5F57",
                trafficYellow: "#FFBD2E",
                trafficGreen: "#28CA41",
                trafficRedDim: "#4A0000",
                trafficYellowDim: "#4A3600",
                trafficGreenDim: "#003400",
                delete: n1(50),
                deleteHover: "#FFFFFF",
                deleteBg: "transparent",
                deleteBgHover: applyAlpha("#FFFFFF", 0.10),
                dropdown: n1(10),
                dropdownHover: n1(15),
                dropdownText: onSurface,
                dropdownTextDim: onSurfaceVariant,
                dropdownBorder: outline
            }
        } else {
            var lprimary           = a1(40)
            var lonPrimary         = a1(100)
            var lprimaryContainer  = a1(90)
            var lonPrimaryContainer= a1(10)
            var lsecondary         = a2(40)
            var lsecondaryContainer= a2(90)
            var lbg                = n1(99)
            var lonBg              = n1(10)
            var lsurface           = n1(98)
            var lonSurface         = n1(10)
            var lsurfaceVariant    = n2(90)
            var lonSurfaceVariant  = n2(30)
            var loutline           = n2(50)
            var lsurfaceHigh       = n1(96)
            var lsurfaceAlt        = n1(92)

            return {
                bg: lbg,
                surface: lsurface,
                surfaceHigh: lsurfaceHigh,
                surfaceAlt: lsurfaceAlt,
                sidebarBg: lsurface,
                border: loutline,
                borderFocus: lprimary,
                borderMid: n2(60),
                divider: n2(85),
                accent: lprimary,
                accentContainer: lprimaryContainer,
                accentDim: a1(50),
                onAccent: lonPrimary,
                textBright: lonSurface,
                textDim: lonSurfaceVariant,
                onSurface: lonSurface,
                onSurfaceMid: n1(40),
                onSurfaceDim: n1(60),
                error: err(40),
                errorContainer: err(90),
                errorText: err(40),
                success: suc(45),
                successDim: applyAlpha(suc(45), 0.15),
                green: suc(45),
                blue: getTone(0.59, 0.6, 45),
                orange: getTone(0.10, 0.7, 40),
                purple: getTone(0.75, 0.6, 45),
                warn: getTone(0.10, 0.7, 40),
                island: lsurface,
                highlightBg: a1(95),
                shadow: "#00000022",
                overlayDim: applyAlpha("#000000", 0.08),
                overlayBase: applyAlpha("#000000", 0.05),
                overlayModal: applyAlpha("#000000", 0.25),
                overlayPanel: Qt.rgba(0.95, 0.95, 0.96, 0.98),
                surfaceOverlay: applyAlpha("#000000", 0.03),
                surfaceHover: applyAlpha("#000000", 0.04),
                surfaceActive: applyAlpha("#000000", 0.06),
                surfacePressed: applyAlpha("#000000", 0.08),
                surfaceRaised: applyAlpha("#000000", 0.02),
                toggleOn: lprimary,
                toggleOff: n2(70),
                toggleKnob: "#FFFFFF",
                toggleKnobOff: applyAlpha("#000000", 0.35),
                trafficRed: "#FF5F57",
                trafficYellow: "#FFBD2E",
                trafficGreen: "#28CA41",
                trafficRedDim: "#FFC0C0",
                trafficYellowDim: "#FFE0A0",
                trafficGreenDim: "#A0E0A0",
                delete: n1(50),
                deleteHover: "#000000",
                deleteBg: "transparent",
                deleteBgHover: applyAlpha("#000000", 0.06),
                dropdown: lsurface,
                dropdownHover: lsurfaceVariant,
                dropdownText: lonSurface,
                dropdownTextDim: lonSurfaceVariant,
                dropdownBorder: loutline
            }
        }
    }

    readonly property var darkPalette: ({
        bg:              "#000000",
        surface:         "#141414",
        surfaceHigh:     "#1A1A1A",
        surfaceAlt:      "#101010",
        sidebarBg:       "#141414",
        border:          "#2A2A2A",
        borderFocus:     "#FFFFFF",
        borderMid:       "#3A3A3A",
        divider:         "#1E1E1E",
        accent:          "#FFFFFF",
        accentContainer: "#2A2A2A",
        accentDim:       "#A0A0A0",
        onAccent:        "#000000",
        textBright:      "#E5E5E5",
        textDim:         "#9CA3AF",
        onSurface:       "#FFFFFF",
        onSurfaceMid:    "#AAAAAA",
        onSurfaceDim:    "#666666",
        error:           "#FF453A",
        errorContainer:  "#2D0A09",
        errorText:       "#FF453A",
        success:         "#4ADE80",
        successDim:      Qt.rgba(74/255, 222/255, 128/255, 0.2),
        green:           "#32D74B",
        blue:            "#5294E2",
        orange:          "#FF9F0A",
        purple:          "#7C3AED",
        warn:            "#FF9F0A",
        island:          "#0D0D14",
        highlightBg:     "#2D1B69",
        shadow:          "#00000088",
        overlayDim:      Qt.rgba(0, 0, 0, 0.2),
        overlayBase:     Qt.rgba(0, 0, 0, 0.25),
        overlayModal:    Qt.rgba(0, 0, 0, 0.5),
        overlayPanel:    Qt.rgba(0.08, 0.08, 0.09, 0.95),
        surfaceOverlay:  Qt.rgba(1, 1, 1, 0.02),
        surfaceHover:    Qt.rgba(1, 1, 1, 0.04),
        surfaceActive:   Qt.rgba(1, 1, 1, 0.06),
        surfacePressed:  Qt.rgba(1, 1, 1, 0.08),
        surfaceRaised:   Qt.rgba(1, 1, 1, 0.12),
        toggleOn:        "#FFFFFF",
        toggleOff:       "#1E1E1E",
        toggleKnob:      "#000000",
        toggleKnobOff:   Qt.rgba(1, 1, 1, 0.35),
        trafficRed:      "#FF5F57",
        trafficYellow:   "#FFBD2E",
        trafficGreen:    "#28CA41",
        trafficRedDim:   "#4A0000",
        trafficYellowDim:"#4A3600",
        trafficGreenDim: "#003400",
        delete:          "#666666",
        deleteHover:     "#FFFFFF",
        deleteBg:        "transparent",
        deleteBgHover:   Qt.rgba(1, 1, 1, 0.1),
        dropdown:        "#1E1E1E",
        dropdownHover:   "#2A2A2A",
        dropdownText:    "#E5E5E5",
        dropdownTextDim: "#9CA3AF",
        dropdownBorder:  "#3A3A3A",
        chartAlt:        "#4ADE80",
        chart3:          "#FF9F0A",
        chart4:          "#7C3AED",
        chart5:          "#FF453A",
        chart6:          "#32D74B"
    })

    readonly property var lightPalette: ({
        bg:              "#F5F5F5",
        surface:         "#FFFFFF",
        surfaceHigh:     "#FAFAFA",
        surfaceAlt:      "#F0F0F0",
        sidebarBg:       "#FFFFFF",
        border:          "#D4D4D4",
        borderFocus:     "#000000",
        borderMid:       "#C0C0C0",
        divider:         "#E8E8E8",
        accent:          "#000000",
        accentContainer: "#E8E8E8",
        accentDim:       "#666666",
        onAccent:        "#FFFFFF",
        textBright:      "#1A1A1A",
        textDim:         "#666666",
        onSurface:       "#000000",
        onSurfaceMid:    "#555555",
        onSurfaceDim:    "#999999",
        error:           "#DC3545",
        errorContainer:  "#FFE0E0",
        errorText:       "#DC3545",
        success:         "#28A745",
        successDim:      Qt.rgba(40/255, 167/255, 69/255, 0.15),
        green:           "#28A745",
        blue:            "#007BFF",
        orange:          "#FD7E14",
        purple:          "#6F42C1",
        warn:            "#FFC107",
        island:          "#FFFFFF",
        highlightBg:     "#E0D4F5",
        shadow:          "#00000022",
        overlayDim:      Qt.rgba(0, 0, 0, 0.08),
        overlayBase:     Qt.rgba(0, 0, 0, 0.05),
        overlayModal:    Qt.rgba(0, 0, 0, 0.25),
        overlayPanel:    Qt.rgba(0.95, 0.95, 0.96, 0.98),
        surfaceOverlay:  Qt.rgba(0, 0, 0, 0.03),
        surfaceHover:    Qt.rgba(0, 0, 0, 0.04),
        surfaceActive:   Qt.rgba(0, 0, 0, 0.06),
        surfacePressed:  Qt.rgba(0, 0, 0, 0.08),
        surfaceRaised:   Qt.rgba(0, 0, 0, 0.02),
        toggleOn:        "#000000",
        toggleOff:       "#D0D0D0",
        toggleKnob:      "#FFFFFF",
        toggleKnobOff:   Qt.rgba(0, 0, 0, 0.35),
        trafficRed:      "#FF5F57",
        trafficYellow:   "#FFBD2E",
        trafficGreen:    "#28CA41",
        trafficRedDim:   "#FFC0C0",
        trafficYellowDim:"#FFE0A0",
        trafficGreenDim: "#A0E0A0",
        delete:          "#999999",
        deleteHover:     "#000000",
        deleteBg:        "transparent",
        deleteBgHover:   Qt.rgba(0, 0, 0, 0.06),
        dropdown:        "#FFFFFF",
        dropdownHover:   "#F0F0F0",
        dropdownText:    "#1A1A1A",
        dropdownTextDim: "#666666",
        dropdownBorder:  "#D4D4D4",
        chartAlt:        "#28A745",
        chart3:          "#FD7E14",
        chart4:          "#6F42C1",
        chart5:          "#DC3545",
        chart6:          "#17A2B8"
    })

    property var palette: buildPalette()

    function setAccent(color) {
        accentColor = color
        palette = buildPalette()
        persistTheme()
        dispatchState()
        themeChanged()
        try { Hooks.runThemeHooks(palette) } catch(e) {}
    }

    function toggleTheme() {
        darkMode = !darkMode
        palette = buildPalette()
        persistTheme()
        dispatchState()
        themeChanged()
        try { Hooks.runThemeHooks(palette) } catch(e) {}
    }

    function setTheme(isDark) {
        if (darkMode === isDark) return
        darkMode = isDark
        palette = buildPalette()
        persistTheme()
        dispatchState()
        themeChanged()
        try { Hooks.runThemeHooks(palette) } catch(e) {}
    }

    signal themeChanged()

    function buildPalette() {
        if (accentColor === "#FFFFFF" || accentColor === "#000000") {
            var base = darkMode ? darkPalette : lightPalette
            var p = ({})
            for (var k in base) p[k] = base[k]
            p.accent = accentColor
            if (darkMode) {
                p.accentContainer = Qt.lighter(accentColor, 0.15)
                p.onAccent = "#000000"
            } else {
                p.accentContainer = Qt.lighter(accentColor, 1.8)
                p.onAccent = "#FFFFFF"
            }
            return p
        }

        try {
            return generateMaterialTheme(accentColor, darkMode)
        } catch(e) {
            var fallback = darkMode ? darkPalette : lightPalette
            var fp = ({})
            for (var k in fallback) fp[k] = fallback[k]
            return fp
        }
    }

    function persistTheme() {
        if (typeof SharedSettings === "undefined") return
        SharedSettings.darkMode = darkMode
        SharedSettings.accentColor = accentColor
        SharedSettings.themeName = themeName
    }

    function loadPersistedTheme() {
        if (typeof SharedSettings === "undefined") return
        darkMode = SharedSettings.darkMode
        accentColor = SharedSettings.accentColor
        themeName = SharedSettings.themeName
        palette = buildPalette()
        dispatchState()
        themeChanged()
    }
    }

    function dispatchState() {
        try { State.set("theme", {darkMode: darkMode, accentColor: accentColor}) } catch(e) {}
        try { IPC.broadcast("theme_changed", {darkMode: darkMode, accentColor: accentColor}) } catch(e) {}
    }

    function setupIpcListener() {
        try {
            IPC.onMessage("theme_changed", function(data) {
                if (!data) return
                if (data.darkMode !== undefined && theme.darkMode !== data.darkMode)
                    theme.setTheme(data.darkMode)
                if (data.accentColor !== undefined && theme.accentColor !== data.accentColor)
                    theme.setAccent(data.accentColor)
            })
        } catch(e) {}
    }

    Component.onCompleted: {
        setupIpcListener()
        loadPersistedTheme()
    }
    property real fontScale: 1.0
    property real spacingScale: 1.0
    property real cornerScale: 1.0
    property bool animationsEnabled: true
    property string trafficLightStyle: "iconic"

    readonly property int animFast:  120
    readonly property int animNorm:  200
    readonly property int animSlow:  280

    function configOverrides(cfg) {
        if (cfg.fontScale !== undefined) fontScale = cfg.fontScale
        if (cfg.spacingScale !== undefined) spacingScale = cfg.spacingScale
        if (cfg.cornerScale !== undefined) cornerScale = cfg.cornerScale
        if (cfg.animationsEnabled !== undefined) animationsEnabled = cfg.animationsEnabled
        if (cfg.trafficLightStyle !== undefined) trafficLightStyle = cfg.trafficLightStyle
    }

    readonly property int rXs:     Math.max(1, Math.round(3 * cornerScale))
    readonly property int rSm:     Math.max(1, Math.round(4 * cornerScale))
    readonly property int rMd:     Math.max(1, Math.round(5 * cornerScale))
    readonly property int rLg:     Math.max(1, Math.round(6 * cornerScale))
    readonly property int rXl:     Math.max(1, Math.round(8 * cornerScale))
    readonly property int rPill:   Math.max(1, Math.round(18 * cornerScale))
    readonly property int rCard:   Math.max(1, Math.round(10 * cornerScale))
    readonly property int rBtn:    Math.max(1, Math.round(8 * cornerScale))
    readonly property int rWindow: Math.max(1, Math.round(12 * cornerScale))

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontSans: "Gothic A1"

    readonly property int fontWeightHeader:    Font.Black
    readonly property int fontWeightSubheader: Font.Medium
    readonly property int fontWeightText:      Font.Normal
    readonly property int fontWeightSubtitle:  Font.Light

    readonly property int fsXs:     Math.max(1, Math.round(12 * fontScale))
    readonly property int fsSm:     Math.max(1, Math.round(14 * fontScale))
    readonly property int fsBase:   Math.max(1, Math.round(16 * fontScale))
    readonly property int fsMd:     Math.max(1, Math.round(18 * fontScale))
    readonly property int fsLg:     Math.max(1, Math.round(20 * fontScale))
    readonly property int fsXl:     Math.max(1, Math.round(24 * fontScale))
    readonly property int fs2xl:    Math.max(1, Math.round(28 * fontScale))
    readonly property int fs3xl:    Math.max(1, Math.round(32 * fontScale))
    readonly property int fs4xl:    Math.max(1, Math.round(36 * fontScale))
    readonly property int fs5xl:    Math.max(1, Math.round(42 * fontScale))
    readonly property int fs6xl:    Math.max(1, Math.round(52 * fontScale))
    readonly property int fs7xl:    Math.max(1, Math.round(68 * fontScale))
    readonly property int fs8xl:    Math.max(1, Math.round(96 * fontScale))

    readonly property int headH:  Math.round(40 * spacingScale)
    readonly property int btnH:   Math.round(30 * spacingScale)
    readonly property int btnSm:  Math.round(26 * spacingScale)
    readonly property int inputH: Math.round(36 * spacingScale)

    readonly property int spXs:   Math.max(1, Math.round(2 * spacingScale))
    readonly property int spSm:   Math.max(1, Math.round(4 * spacingScale))
    readonly property int spMd:   Math.max(1, Math.round(6 * spacingScale))
    readonly property int spLg:   Math.max(1, Math.round(8 * spacingScale))
    readonly property int spXl:   Math.max(1, Math.round(10 * spacingScale))
    readonly property int sp2xl:  Math.max(1, Math.round(12 * spacingScale))
    readonly property int sp3xl:  Math.max(1, Math.round(16 * spacingScale))

    readonly property int bpSm:   500
    readonly property int bpMd:   720
    readonly property int bpLg:   960

    function responsiveScale(width) {
        if (width <= 0) return 1.0
        if (width < bpSm) return 0.82
        if (width < bpMd) return 0.92
        return 1.0
    }

    function responsiveSpacing(width, baseSpacing) {
        return Math.max(1, Math.round(baseSpacing * responsiveScale(width)))
    }

    function isMobile(width) {
        return width > 0 && width < bpSm
    }
}
