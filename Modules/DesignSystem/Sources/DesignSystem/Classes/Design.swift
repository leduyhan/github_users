import UIKit

public enum Design {
    public enum Colors {
        public static let black500 = UIColor(hex: "000000")
        public static let white500 = UIColor(hex: "FFFFFF")
        public static let gray400 = UIColor(hex: "E5E5E5")
        public static let gray = UIColor.gray
        public static let blue = UIColor(hex: "0000FF")
    }
    
    public enum Typography {
        // Regular
        public static let regular12 = UIFont(name: "Lato-Regular", size: 12)!
        public static let regular13 = UIFont(name: "Lato-Regular", size: 13)!
        public static let regular14 = UIFont(name: "Lato-Regular", size: 14)!
        public static let regular16 = UIFont(name: "Lato-Regular", size: 16)!
        
        // Semibold
        public static let semibold13 = UIFont(name: "Lato-Semibold", size: 13)!
        public static let semibold14 = UIFont(name: "Lato-Semibold", size: 14)!
        public static let semibold16 = UIFont(name: "Lato-Semibold", size: 16)!
        public static let semibold18 = UIFont(name: "Lato-Semibold", size: 18)!
        public static let semibold24 = UIFont(name: "Lato-Semibold", size: 24)!
        
        // Bold
        public static let bold14 = UIFont(name: "Lato-Bold", size: 14)!
        public static let bold20 = UIFont(name: "Lato-Bold", size: 20)!
        public static let bold24 = UIFont(name: "Lato-Bold", size: 24)!
    }
    
    public static func initialize() {
        UIFont.registerFonts()
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        var red, green, blue, alpha: CGFloat
        
        switch length {
        case 6:
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
            alpha = 1.0
            
        case 8:
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
            
        default:
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIFont {
    static func registerFonts() {
        guard let bundle = Bundle(for: BundleToken.self).resourceBundle(forClass: BundleToken.self, bundleName: "DesignSystem") else { return }

        let fontNames = ["Lato-Regular", "Lato-Semibold", "Lato-Bold"]
        fontNames.forEach { name in
            guard let fontURL = bundle.url(forResource: name, withExtension: "ttf") else { return }
            
            do {
                let data = try Data(contentsOf: fontURL)
                let provider = CGDataProvider(data: data as CFData)
                let font = CGFont(provider!)!
                var error: Unmanaged<CFError>?
                _ = CTFontManagerRegisterGraphicsFont(font, &error)
            } catch { }
        }
    }
}

private final class BundleToken {}

private extension Bundle {
    func resourceBundle(forClass: AnyClass, bundleName: String) -> Bundle? {
        guard let url = resourceURL?.appendingPathComponent("\(bundleName).bundle") else { return nil }
        return Bundle(url: url)
    }
}
