//
//  esxtesions.swift
//  
//
//  Created by vamshi krishna on 21/05/26.
//




import UIKit

extension UIView {
    
    // MARK: - Border
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // MARK: - Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = false   // ⚠️ Important for shadow
        }
    }
    
    // MARK: - Shadow
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set {
            layer.shadowOpacity = newValue
            layer.masksToBounds = false   // ⚠️ must for shadow
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOffsetWidth: CGFloat {
        get { return layer.shadowOffset.width }
        set {
            layer.shadowOffset = CGSize(width: newValue, height: layer.shadowOffset.height)
        }
    }
    
    @IBInspectable var shadowOffsetHeight: CGFloat {
        get { return layer.shadowOffset.height }
        set {
            layer.shadowOffset = CGSize(width: layer.shadowOffset.width, height: newValue)
        }
    }
}

