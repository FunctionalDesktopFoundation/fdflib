import QtQuick
import QtQuick.Controls

Text {
    id: root

    property string variant: "body"
    property string colorKey: "textBright"
    property alias bold: root.font.bold

    font.family: {
        switch (variant) {
            case "mono":  case "icon":  return Theme.fontMono
            default:                     return Theme.fontSans
        }
    }
    font.pixelSize: {
        switch (variant) {
            case "xs":       return Theme.fsXs
            case "sm":       return Theme.fsSm
            case "base":     return Theme.fsBase
            case "md":       return Theme.fsMd
            case "lg":       return Theme.fsLg
            case "heading":  return Theme.fsXl
            case "title":    return Theme.fs2xl
            case "hero":     return Theme.fs3xl
            case "mono":     return Theme.fsBase
            case "icon":     return Theme.fsXl
            default:         return Theme.fsBase
        }
    }
    font.weight: {
        switch (variant) {
            case "title":    case "heading": case "hero":  return Theme.fontWeightHeader
            case "lg":       case "md":                    return Theme.fontWeightSubheader
            case "sm":                                     return Theme.fontWeightSubtitle
            case "mono":                                   return Font.Bold
            default:                                       return Theme.fontWeightText
        }
    }
    color: {
        var c = Theme.palette
        switch (colorKey) {
            case "bright":    return c.textBright
            case "dim":       return c.textDim
            case "accent":    return c.accent
            case "onSurface": return c.onSurface
            case "error":     return c.error
            case "success":   return c.success
            case "blue":      return c.blue
            default:          return c.textBright
        }
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: root.text
}
