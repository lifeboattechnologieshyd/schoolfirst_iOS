//
//  BusAnnotationView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/08/26.
//

import MapKit

class BusAnnotationView: MKAnnotationView {

    private var currentRotation: CGFloat = 0

    // MARK: - Init
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        if let busImage = UIImage(named: "bus icon") {
            image = resizeImage(busImage, targetSize: CGSize(width: 45, height: 45))
        } else {
            image = createBusIconWithBackground()
        }

        centerOffset   = CGPoint(x: 0, y: -(image?.size.height ?? 0) / 2)
        canShowCallout = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: - Rotate Bus Smoothly (Shortest Path)
    func rotate(degrees: Double) {
        let targetRadians = CGFloat(degrees * .pi / 180)
        
        // Find shortest angle
        var delta = targetRadians - currentRotation
        while delta > .pi { delta -= 2 * .pi }
        while delta < -.pi { delta += 2 * .pi }
        let newRotation = currentRotation + delta

        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(rotationAngle: newRotation)
        }
        currentRotation = newRotation
    }

    // MARK: - Resize Image Helper
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // MARK: - SF Symbol Bus with White Circle Background
    private func createBusIconWithBackground() -> UIImage {
        let size     = CGSize(width: 45, height: 45)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let context = ctx.cgContext
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
            context.setStrokeColor(UIColor.systemBlue.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))

            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
            let busIcon = UIImage(systemName: "bus.fill", withConfiguration: config)?
                .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)

            if let busIcon = busIcon {
                let iconSize = CGSize(width: 26, height: 26)
                let origin   = CGPoint(x: (size.width - iconSize.width) / 2,
                                       y: (size.height - iconSize.height) / 2)
                busIcon.draw(in: CGRect(origin: origin, size: iconSize))
            }
        }
    }
}
