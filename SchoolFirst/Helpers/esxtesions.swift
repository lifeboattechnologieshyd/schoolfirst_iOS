//
//  esxtesions.swift
//
//  Created by vamshi krishna on 21/05/26.
//

import UIKit

// MARK: - UIView Extension

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
            layer.masksToBounds = false
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
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable var shadowRadiusIB: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOffsetWidthIB: CGFloat {
        get { return layer.shadowOffset.width }
        set {
            layer.shadowOffset = CGSize(
                width: newValue,
                height: layer.shadowOffset.height
            )
        }
    }
    
    @IBInspectable var shadowOffsetHeightIB: CGFloat {
        get { return layer.shadowOffset.height }
        set {
            layer.shadowOffset = CGSize(
                width: layer.shadowOffset.width,
                height: newValue
            )
        }
    }
}

// MARK: - UIButton Tap Effect Extension

extension UIButton {
    
    func applyTapEffect() {
        
        addTarget(
            self,
            action: #selector(buttonPressed),
            for: .touchDown
        )
        
        addTarget(
            self,
            action: #selector(buttonReleased),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
    }
    
    @objc private func buttonPressed() {
        
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(
                scaleX: 0.95,
                y: 0.95
            )
            self.alpha = 0.8
        }
    }
    
    @objc private func buttonReleased() {
        
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}
