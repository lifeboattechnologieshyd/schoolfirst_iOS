//
//  Fontextensionfile.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 24/09/26.


import UIKit

extension UIFont {
    
    // MARK: - Hanken Grotesk Weight Enum
    
    enum HankenGroteskWeight: String {
        case black      = "HankenGrotesk-Black"
        case bold       = "HankenGrotesk-Bold"
        case extraBold  = "HankenGrotesk-ExtraBold"
        case extraLight = "HankenGrotesk-ExtraLight"
        case light      = "HankenGrotesk-Light"
        case medium     = "HankenGrotesk-Medium"
        case regular    = "HankenGrotesk-Regular"
        case semiBold   = "HankenGrotesk-SemiBold"
        case thin       = "HankenGrotesk-Thin"
        
        /// Fallback system weight in case font file loading fails
        var systemWeight: UIFont.Weight {
            switch self {
            case .black:      return .black
            case .bold:       return .bold
            case .extraBold:  return .heavy
            case .extraLight: return .ultraLight
            case .light:      return .light
            case .medium:     return .medium
            case .regular:    return .regular
            case .semiBold:   return .semibold
            case .thin:       return .thin
            }
        }
    }
    
    // MARK: - Main Custom Font Loader
    
    static func hankenGrotesk(_ weight: HankenGroteskWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? .systemFont(ofSize: size, weight: weight.systemWeight)
    }
    
    // MARK: - Convenience Static Methods
    
    static func hankenBlack(size: CGFloat) -> UIFont {
        return hankenGrotesk(.black, size: size)
    }
    
    static func hankenBold(size: CGFloat) -> UIFont {
        return hankenGrotesk(.bold, size: size)
    }
    
    static func hankenExtraBold(size: CGFloat) -> UIFont {
        return hankenGrotesk(.extraBold, size: size)
    }
    
    static func hankenExtraLight(size: CGFloat) -> UIFont {
        return hankenGrotesk(.extraLight, size: size)
    }
    
    static func hankenLight(size: CGFloat) -> UIFont {
        return hankenGrotesk(.light, size: size)
    }
    
    static func hankenMedium(size: CGFloat) -> UIFont {
        return hankenGrotesk(.medium, size: size)
    }
    
    static func hankenRegular(size: CGFloat) -> UIFont {
        return hankenGrotesk(.regular, size: size)
    }
    
    static func hankenSemiBold(size: CGFloat) -> UIFont {
        return hankenGrotesk(.semiBold, size: size)
    }
    
    static func hankenThin(size: CGFloat) -> UIFont {
        return hankenGrotesk(.thin, size: size)
    }
}
