//
//  MultiColorCalendarCell.swift
//  SchoolFirst
//

import UIKit
import FSCalendar

class MultiColorCalendarCell: FSCalendarCell {
    
    private let topColorLayer = CAShapeLayer()
    private let bottomColorLayer = CAShapeLayer()
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        topColorLayer.fillColor = UIColor.systemPurple.cgColor
        bottomColorLayer.fillColor = UIColor.systemOrange.cgColor
        
        contentView.layer.insertSublayer(bottomColorLayer, below: titleLabel.layer)
        contentView.layer.insertSublayer(topColorLayer, below: titleLabel.layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = 38
        let rect = CGRect(
            x: (contentView.bounds.width - size) / 2,
            y: (contentView.bounds.height - size) / 2,
            width: size,
            height: size
        )
        
        let radius: CGFloat = 8
        
        // Top half (purple)
        let topPath = UIBezierPath(
            roundedRect: CGRect(x: rect.origin.x, y: rect.origin.y, width: size, height: size / 2),
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        topColorLayer.path = topPath.cgPath
        
        // Bottom half (orange)
        let bottomPath = UIBezierPath(
            roundedRect: CGRect(x: rect.origin.x, y: rect.origin.y + size / 2, width: size, height: size / 2),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        bottomColorLayer.path = bottomPath.cgPath
        
        // Bring title to front
        contentView.bringSubviewToFront(titleLabel)
    }
    
    func showMultiColor(_ show: Bool) {
        topColorLayer.isHidden = !show
        bottomColorLayer.isHidden = !show
    }
}
