//
//  esxtesions.swift
//  
//
//  Created by vamshi krishna on 21/05/26.
//




import UIKit

extension UIView {
    
    // MARK: - Border
    @IBInspectable var borderWidthIB: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColorIB: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // MARK: - Corner Radius
    @IBInspectable var cornerRadiusIB: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = false   // ⚠️ Important for shadow
        }
    }
    
    // MARK: - Shadow
    @IBInspectable var shadowColorIB: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacityIB: Float {
        get { return layer.shadowOpacity }
        set {
            layer.shadowOpacity = newValue
            layer.masksToBounds = false   // ⚠️ must for shadow
        }
    }
    
    @IBInspectable var shadowRadiusIB: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOffsetWidthIB: CGFloat {
        get { return layer.shadowOffset.width }
        set {
            layer.shadowOffset = CGSize(width: newValue, height: layer.shadowOffset.height)
        }
    }
    
    @IBInspectable var shadowOffsetHeightIB: CGFloat {
        get { return layer.shadowOffset.height }
        set {
            layer.shadowOffset = CGSize(width: layer.shadowOffset.width, height: newValue)
        }
    }
}

