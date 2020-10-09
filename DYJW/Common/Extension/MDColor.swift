//
//  MDColor.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

extension Int {
    var rgbColor: UIColor {
        return self.rgbColor(alpha: 1)
    }
    
    func rgbColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat(self >> 16) / 255.0
        let green = CGFloat((self >> 8) & 0xFF) / 255.0
        let blue = CGFloat(self & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    static let md: MDColorContainer = MDColorContainer()
    
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .light: return light
                case .dark: return dark
                case .unspecified: return light
                @unknown default: return light
                }
            }
        } else {
            return light
        }
    }
}

enum MDColorLevel {
    case level50
    case level100
    case level200
    case level300
    case level400
    case level500
    case level600
    case level700
    case level800
    case level900
}

enum MDColorAccentLevel {
    case A100
    case A200
    case A400
    case A700
}

struct MDColorContainer {
    
    enum ColorName: CaseIterable {
        case red
        case pink
        case purple
        case deepPurple
        case indigo
        case blue
        case lightBlue
        case cyan
        case teal
        case green
        case lightGreen
        case lime
        case yellow
        case amber
        case orange
        case deepOrange
        case brown
        case grey
        case blueGrey
    }
    
    enum AccentColorName: CaseIterable {
        case red
        case pink
        case purple
        case deepPurple
        case indigo
        case blue
        case lightBlue
        case cyan
        case teal
        case green
        case lightGreen
        case lime
        case yellow
        case amber
        case orange
        case deepOrange
    }
    
    func color(named colorName: ColorName, _ level: MDColorLevel) -> UIColor {
        switch colorName {
        case .red:          return red(level)
        case .pink:         return pink(level)
        case .purple:       return purple(level)
        case .deepPurple:   return deepPurple(level)
        case .indigo:       return indigo(level)
        case .blue:         return blue(level)
        case .lightBlue:    return lightBlue(level)
        case .cyan:         return cyan(level)
        case .teal:         return teal(level)
        case .green:        return green(level)
        case .lightGreen:   return lightGreen(level)
        case .lime:         return lime(level)
        case .yellow:       return yellow(level)
        case .amber:        return amber(level)
        case .orange:       return orange(level)
        case .deepOrange:   return deepOrange(level)
        case .brown:        return brown(level)
        case .grey:         return grey(level)
        case .blueGrey:     return blueGrey(level)
        }
    }
    
    func color(named colorName: AccentColorName, _ level: MDColorAccentLevel) -> UIColor {
        switch colorName {
        case .red:          return red(level)
        case .pink:         return pink(level)
        case .purple:       return purple(level)
        case .deepPurple:   return deepPurple(level)
        case .indigo:       return indigo(level)
        case .blue:         return blue(level)
        case .lightBlue:    return lightBlue(level)
        case .cyan:         return cyan(level)
        case .teal:         return teal(level)
        case .green:        return green(level)
        case .lightGreen:   return lightGreen(level)
        case .lime:         return lime(level)
        case .yellow:       return yellow(level)
        case .amber:        return amber(level)
        case .orange:       return orange(level)
        case .deepOrange:   return deepOrange(level)
        }
    }
    
    func red(_ level: MDColorLevel) -> UIColor { return MDRed.color(of: level) }
    func red(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDRed.color(of: accentLevel) }
    
    func pink(_ level: MDColorLevel) -> UIColor { return MDPink.color(of: level) }
    func pink(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDPink.color(of: accentLevel) }
    
    func purple(_ level: MDColorLevel) -> UIColor { return MDPurple.color(of: level) }
    func purple(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDPurple.color(of: accentLevel) }
    
    func deepPurple(_ level: MDColorLevel) -> UIColor { return MDDeepPurple.color(of: level) }
    func deepPurple(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDDeepPurple.color(of: accentLevel) }
    
    func indigo(_ level: MDColorLevel) -> UIColor { return MDIndigo.color(of: level) }
    func indigo(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDIndigo.color(of: accentLevel) }
    
    func blue(_ level: MDColorLevel) -> UIColor { return MDBlue.color(of: level) }
    func blue(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDBlue.color(of: accentLevel) }
    
    func lightBlue(_ level: MDColorLevel) -> UIColor { return MDLightBlue.color(of: level) }
    func lightBlue(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDLightBlue.color(of: accentLevel) }
    
    func cyan(_ level: MDColorLevel) -> UIColor { return MDCyan.color(of: level) }
    func cyan(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDCyan.color(of: accentLevel) }
    
    func teal(_ level: MDColorLevel) -> UIColor { return MDTeal.color(of: level) }
    func teal(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDTeal.color(of: accentLevel) }
    
    func green(_ level: MDColorLevel) -> UIColor { return MDGreen.color(of: level) }
    func green(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDGreen.color(of: accentLevel) }
    
    func lightGreen(_ level: MDColorLevel) -> UIColor { return MDLightGreen.color(of: level) }
    func lightGreen(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDLightGreen.color(of: accentLevel) }
    
    func lime(_ level: MDColorLevel) -> UIColor { return MDLime.color(of: level) }
    func lime(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDLime.color(of: accentLevel) }
    
    func yellow(_ level: MDColorLevel) -> UIColor { return MDYellow.color(of: level) }
    func yellow(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDYellow.color(of: accentLevel) }
    
    func amber(_ level: MDColorLevel) -> UIColor { return MDAmber.color(of: level) }
    func amber(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDAmber.color(of: accentLevel) }
    
    func orange(_ level: MDColorLevel) -> UIColor { return MDOrange.color(of: level) }
    func orange(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDOrange.color(of: accentLevel) }
    
    func deepOrange(_ level: MDColorLevel) -> UIColor { return MDDeepOrange.color(of: level) }
    func deepOrange(_ accentLevel: MDColorAccentLevel) -> UIColor { return MDDeepOrange.color(of: accentLevel) }
    
    func brown(_ level: MDColorLevel) -> UIColor { return MDBrown.color(of: level) }
    
    func grey(_ level: MDColorLevel) -> UIColor { return MDGrey.color(of: level) }
    
    func blueGrey(_ level: MDColorLevel) -> UIColor { return MDBlueGrey.color(of: level) }
}

protocol MDColorPalette {
    static func color(of level: MDColorLevel) -> UIColor
}

protocol MDColorAccentPalette {
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor
}

// MARK: - Red
struct MDRed: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:  return 0xfde0dc.rgbColor
        case .level100: return 0xf9bdbb.rgbColor
        case .level200: return 0xf69988.rgbColor
        case .level300: return 0xf36c60.rgbColor
        case .level400: return 0xe84e40.rgbColor
        case .level500: return 0xe51c23.rgbColor
        case .level600: return 0xdd191d.rgbColor
        case .level700: return 0xd01716.rgbColor
        case .level800: return 0xc41411.rgbColor
        case .level900: return 0xb0120a.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xff7997.rgbColor
        case .A200: return 0xff5177.rgbColor
        case .A400: return 0xff2d6f.rgbColor
        case .A700: return 0xe00032.rgbColor
        }
    }
}

// MARK:- Pink
struct MDPink: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:  return 0xfce4ec.rgbColor
        case .level100: return 0xf8bbd0.rgbColor
        case .level200: return 0xf48fb1.rgbColor
        case .level300: return 0xf06292.rgbColor
        case .level400: return 0xec407a.rgbColor
        case .level500: return 0xe91e63.rgbColor
        case .level600: return 0xd81b60.rgbColor
        case .level700: return 0xc2185b.rgbColor
        case .level800: return 0xad1457.rgbColor
        case .level900: return 0x880e4f.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xff80ab.rgbColor
        case .A200: return 0xff4081.rgbColor
        case .A400: return 0xf50057.rgbColor
        case .A700: return 0xc51162.rgbColor
        }
    }
}


// MARK:- Purple
struct MDPurple: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xf3e5f5.rgbColor
        case .level100:  return 0xe1bee7.rgbColor
        case .level200:  return 0xce93d8.rgbColor
        case .level300:  return 0xba68c8.rgbColor
        case .level400:  return 0xab47bc.rgbColor
        case .level500:  return 0x9c27b0.rgbColor
        case .level600:  return 0x8e24aa.rgbColor
        case .level700:  return 0x7b1fa2.rgbColor
        case .level800:  return 0x6a1b9a.rgbColor
        case .level900:  return 0x4a148c.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xea80fc.rgbColor
        case .A200: return 0xe040fb.rgbColor
        case .A400: return 0xd500f9.rgbColor
        case .A700: return 0xaa00ff.rgbColor
        }
    }
}

// MARK:- Deep Purple
struct MDDeepPurple: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xede7f6.rgbColor
        case .level100:  return 0xd1c4e9.rgbColor
        case .level200:  return 0xb39ddb.rgbColor
        case .level300:  return 0x9575cd.rgbColor
        case .level400:  return 0x7e57c2.rgbColor
        case .level500:  return 0x673ab7.rgbColor
        case .level600:  return 0x5e35b1.rgbColor
        case .level700:  return 0x512da8.rgbColor
        case .level800:  return 0x4527a0.rgbColor
        case .level900:  return 0x311b92.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xb388ff.rgbColor
        case .A200: return 0x7c4dff.rgbColor
        case .A400: return 0x651fff.rgbColor
        case .A700: return 0x6200ea.rgbColor
        }
    }
}

// MARK:- Indigo
struct MDIndigo: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xe8eaf6.rgbColor
        case .level100:  return 0xc5cae9.rgbColor
        case .level200:  return 0x9fa8da.rgbColor
        case .level300:  return 0x7986cb.rgbColor
        case .level400:  return 0x5c6bc0.rgbColor
        case .level500:  return 0x3f51b5.rgbColor
        case .level600:  return 0x3949ab.rgbColor
        case .level700:  return 0x303f9f.rgbColor
        case .level800:  return 0x283593.rgbColor
        case .level900:  return 0x1a237e.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0x8c9eff.rgbColor
        case .A200: return 0x536dfe.rgbColor
        case .A400: return 0x3d5afe.rgbColor
        case .A700: return 0x304ffe.rgbColor
        }
    }
}

// MARK:- Blue
struct MDBlue: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xe7e9fd.rgbColor
        case .level100:  return 0xd0d9ff.rgbColor
        case .level200:  return 0xafbfff.rgbColor
        case .level300:  return 0x91a7ff.rgbColor
        case .level400:  return 0x738ffe.rgbColor
        case .level500:  return 0x5677fc.rgbColor
        case .level600:  return 0x4e6cef.rgbColor
        case .level700:  return 0x455ede.rgbColor
        case .level800:  return 0x3b50ce.rgbColor
        case .level900:  return 0x2a36b1.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xa6baff.rgbColor
        case .A200: return 0x6889ff.rgbColor
        case .A400: return 0x4d73ff.rgbColor
        case .A700: return 0x4d69ff.rgbColor
        }
    }
}

// MARK:- Light Blue
struct MDLightBlue: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xe1f5fe.rgbColor
        case .level100:  return 0xb3e5fc.rgbColor
        case .level200:  return 0x81d4fa.rgbColor
        case .level300:  return 0x4fc3f7.rgbColor
        case .level400:  return 0x29b6f6.rgbColor
        case .level500:  return 0x03a9f4.rgbColor
        case .level600:  return 0x039be5.rgbColor
        case .level700:  return 0x0288d1.rgbColor
        case .level800:  return 0x0277bd.rgbColor
        case .level900:  return 0x01579b.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0x80d8ff.rgbColor
        case .A200: return 0x40c4ff.rgbColor
        case .A400: return 0x00b0ff.rgbColor
        case .A700: return 0x0091ea.rgbColor
        }
    }
}

// MARK:- Cyan
struct MDCyan: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xe0f7fa.rgbColor
        case .level100:  return 0xb2ebf2.rgbColor
        case .level200:  return 0x80deea.rgbColor
        case .level300:  return 0x4dd0e1.rgbColor
        case .level400:  return 0x26c6da.rgbColor
        case .level500:  return 0x00bcd4.rgbColor
        case .level600:  return 0x00acc1.rgbColor
        case .level700:  return 0x0097a7.rgbColor
        case .level800:  return 0x00838f.rgbColor
        case .level900:  return 0x006064.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0x84ffff.rgbColor
        case .A200: return 0x18ffff.rgbColor
        case .A400: return 0x00e5ff.rgbColor
        case .A700: return 0x00b8d4.rgbColor
        }
    }
}

// MARK:- Teal
struct MDTeal: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xe0f2f1.rgbColor
        case .level100:  return 0xb2dfdb.rgbColor
        case .level200:  return 0x80cbc4.rgbColor
        case .level300:  return 0x4db6ac.rgbColor
        case .level400:  return 0x26a69a.rgbColor
        case .level500:  return 0x009688.rgbColor
        case .level600:  return 0x00897b.rgbColor
        case .level700:  return 0x00796b.rgbColor
        case .level800:  return 0x00695c.rgbColor
        case .level900:  return 0x004d40.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xa7ffeb.rgbColor
        case .A200: return 0x64ffda.rgbColor
        case .A400: return 0x1de9b6.rgbColor
        case .A700: return 0x00bfa5.rgbColor
        }
    }
}

// MARK:- Green
struct MDGreen: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xd0f8ce.rgbColor
        case .level100:  return 0xa3e9a4.rgbColor
        case .level200:  return 0x72d572.rgbColor
        case .level300:  return 0x42bd41.rgbColor
        case .level400:  return 0x2baf2b.rgbColor
        case .level500:  return 0x259b24.rgbColor
        case .level600:  return 0x0a8f08.rgbColor
        case .level700:  return 0x0a7e07.rgbColor
        case .level800:  return 0x056f00.rgbColor
        case .level900:  return 0x0d5302.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xa2f78d.rgbColor
        case .A200: return 0x5af158.rgbColor
        case .A400: return 0x14e715.rgbColor
        case .A700: return 0x12c700.rgbColor
        }
    }
}

// MARK:- Light Green
struct MDLightGreen: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xf1f8e9.rgbColor
        case .level100:  return 0xdcedc8.rgbColor
        case .level200:  return 0xc5e1a5.rgbColor
        case .level300:  return 0xaed581.rgbColor
        case .level400:  return 0x9ccc65.rgbColor
        case .level500:  return 0x8bc34a.rgbColor
        case .level600:  return 0x7cb342.rgbColor
        case .level700:  return 0x689f38.rgbColor
        case .level800:  return 0x558b2f.rgbColor
        case .level900:  return 0x33691e.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xccff90.rgbColor
        case .A200: return 0xb2ff59.rgbColor
        case .A400: return 0x76ff03.rgbColor
        case .A700: return 0x64dd17.rgbColor
        }
    }
}

// MARK:- Lime
struct MDLime: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xf9fbe7.rgbColor
        case .level100:  return 0xf0f4c3.rgbColor
        case .level200:  return 0xe6ee9c.rgbColor
        case .level300:  return 0xdce775.rgbColor
        case .level400:  return 0xd4e157.rgbColor
        case .level500:  return 0xcddc39.rgbColor
        case .level600:  return 0xc0ca33.rgbColor
        case .level700:  return 0xafb42b.rgbColor
        case .level800:  return 0x9e9d24.rgbColor
        case .level900:  return 0x827717.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xf4ff81.rgbColor
        case .A200: return 0xeeff41.rgbColor
        case .A400: return 0xc6ff00.rgbColor
        case .A700: return 0xaeea00.rgbColor
        }
    }
}

// MARK:- Yellow
struct MDYellow: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xfffde7.rgbColor
        case .level100:  return 0xfff9c4.rgbColor
        case .level200:  return 0xfff59d.rgbColor
        case .level300:  return 0xfff176.rgbColor
        case .level400:  return 0xffee58.rgbColor
        case .level500:  return 0xffeb3b.rgbColor
        case .level600:  return 0xfdd835.rgbColor
        case .level700:  return 0xfbc02d.rgbColor
        case .level800:  return 0xf9a825.rgbColor
        case .level900:  return 0xf57f17.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xffff8d.rgbColor
        case .A200: return 0xffff00.rgbColor
        case .A400: return 0xffea00.rgbColor
        case .A700: return 0xffd600.rgbColor
        }
    }
}

// MARK:- Amber
struct MDAmber: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xfff8e1.rgbColor
        case .level100:  return 0xffecb3.rgbColor
        case .level200:  return 0xffe082.rgbColor
        case .level300:  return 0xffd54f.rgbColor
        case .level400:  return 0xffca28.rgbColor
        case .level500:  return 0xffc107.rgbColor
        case .level600:  return 0xffb300.rgbColor
        case .level700:  return 0xffa000.rgbColor
        case .level800:  return 0xff8f00.rgbColor
        case .level900:  return 0xff6f00.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xffe57f.rgbColor
        case .A200: return 0xffd740.rgbColor
        case .A400: return 0xffc400.rgbColor
        case .A700: return 0xffab00.rgbColor
        }
    }
}

// MARK:- Orange
struct MDOrange: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xfff3e0.rgbColor
        case .level100:  return 0xffe0b2.rgbColor
        case .level200:  return 0xffcc80.rgbColor
        case .level300:  return 0xffb74d.rgbColor
        case .level400:  return 0xffa726.rgbColor
        case .level500:  return 0xff9800.rgbColor
        case .level600:  return 0xfb8c00.rgbColor
        case .level700:  return 0xf57c00.rgbColor
        case .level800:  return 0xef6c00.rgbColor
        case .level900:  return 0xe65100.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xffd180.rgbColor
        case .A200: return 0xffab40.rgbColor
        case .A400: return 0xff9100.rgbColor
        case .A700: return 0xff6d00.rgbColor
        }
    }
}

// MARK:- Deep Orange
struct MDDeepOrange: MDColorPalette, MDColorAccentPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:   return 0xfbe9e7.rgbColor
        case .level100:  return 0xffccbc.rgbColor
        case .level200:  return 0xffab91.rgbColor
        case .level300:  return 0xff8a65.rgbColor
        case .level400:  return 0xff7043.rgbColor
        case .level500:  return 0xff5722.rgbColor
        case .level600:  return 0xf4511e.rgbColor
        case .level700:  return 0xe64a19.rgbColor
        case .level800:  return 0xd84315.rgbColor
        case .level900:  return 0xbf360c.rgbColor
        }
    }
    
    static func color(of accentLevel: MDColorAccentLevel) -> UIColor {
        switch accentLevel {
        case .A100: return 0xff9e80.rgbColor
        case .A200: return 0xff6e40.rgbColor
        case .A400: return 0xff3d00.rgbColor
        case .A700: return 0xdd2c00.rgbColor
        }
    }
}

// MARK:- Brown
struct MDBrown: MDColorPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:  return 0xefebe9.rgbColor
        case .level100: return 0xd7ccc8.rgbColor
        case .level200: return 0xbcaaa4.rgbColor
        case .level300: return 0xa1887f.rgbColor
        case .level400: return 0x8d6e63.rgbColor
        case .level500: return 0x795548.rgbColor
        case .level600: return 0x6d4c41.rgbColor
        case .level700: return 0x5d4037.rgbColor
        case .level800: return 0x4e342e.rgbColor
        case .level900: return 0x3e2723.rgbColor
        }
    }
}

// MARK:- Grey
struct MDGrey: MDColorPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:  return 0xfafafa.rgbColor
        case .level100: return 0xf5f5f5.rgbColor
        case .level200: return 0xeeeeee.rgbColor
        case .level300: return 0xe0e0e0.rgbColor
        case .level400: return 0xbdbdbd.rgbColor
        case .level500: return 0x9e9e9e.rgbColor
        case .level600: return 0x757575.rgbColor
        case .level700: return 0x616161.rgbColor
        case .level800: return 0x424242.rgbColor
        case .level900: return 0x212121.rgbColor
        }
    }
}

// MARK:- Blue Grey
struct MDBlueGrey: MDColorPalette {
    static func color(of level: MDColorLevel) -> UIColor {
        switch level {
        case .level50:  return 0xeceff1.rgbColor
        case .level100: return 0xcfd8dc.rgbColor
        case .level200: return 0xb0bec5.rgbColor
        case .level300: return 0x90a4ae.rgbColor
        case .level400: return 0x78909c.rgbColor
        case .level500: return 0x607d8b.rgbColor
        case .level600: return 0x546e7a.rgbColor
        case .level700: return 0x455a64.rgbColor
        case .level800: return 0x37474f.rgbColor
        case .level900: return 0x263238.rgbColor
        }
    }
}

