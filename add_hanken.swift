import Foundation

let path = "SchoolFirst/Helpers/UIExtensions.swift"
var content = try! String(contentsOfFile: path)

let hankenEnum = """

enum HankenFont: String {
    case regular = "HankenGrotesk-Regular"
    case bold = "HankenGrotesk-Bold"
    case light = "HankenGrotesk-Light"
    case medium = "HankenGrotesk-Medium"
    case semiBold = "HankenGrotesk-SemiBold"
    case extraLight = "HankenGrotesk-ExtraLight"
    case extraBold = "HankenGrotesk-ExtraBold"
    case thin = "HankenGrotesk-Thin"
    case black = "HankenGrotesk-Black"
}

extension UIFont {
    static func hanken(_ style: HankenFont, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
"""

if !content.contains("enum HankenFont") {
    if let range = content.range(of: "extension UIFont {") {
        let insertIndex = content.range(of: "}", options: [], range: range.lowerBound..<content.endIndex)!.upperBound
        content.insert(contentsOf: hankenEnum, at: insertIndex)
        try! content.write(toFile: path, atomically: true, encoding: .utf8)
        print("Added HankenFont to UIExtensions.swift")
    } else {
        content.append(hankenEnum)
        try! content.write(toFile: path, atomically: true, encoding: .utf8)
        print("Appended HankenFont to UIExtensions.swift")
    }
} else {
    print("Already exists")
}
