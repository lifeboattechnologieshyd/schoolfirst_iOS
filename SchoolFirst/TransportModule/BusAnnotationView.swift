//
//  BusAnnotationView.swift
//  SchoolFirst
//

import MapKit

class BusAnnotationView: MKAnnotationView {

    private var currentRotation: CGFloat = 0
    private let busImageView = UIImageView()
    private var pulseLayers: [CAShapeLayer] = []

    // Overall annotation frame size (large enough to show pulse rings)
    private let containerSize: CGFloat = 90
    private let busSize = CGSize(width: 34, height: 40)

    /// ✅ FIX: Asset bus image faces RIGHT (east) by default.
    /// Heading 0° = North, so we subtract 90° to align the nose with travel direction.
    /// If bus still looks wrong, try: 0, -90, 90, or 180
    private let imageHeadingOffsetDegrees: Double = -90

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
        frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        backgroundColor = .clear
        isOpaque = false

        // Pulse rings BEHIND the bus (do not rotate)
        setupPulseLayers()

        // Bus image
        if let busImage = UIImage(named: "bustopview") {
            busImageView.image = resizeImage(busImage, targetSize: busSize)
        } else {
            busImageView.image = createBusIconWithBackground()
        }
        busImageView.contentMode = .scaleAspectFit
        busImageView.frame = CGRect(
            x: (containerSize - busSize.width) / 2,
            y: (containerSize - busSize.height) / 2,
            width: busSize.width,
            height: busSize.height
        )
        addSubview(busImageView)

        // Sit exactly on the blue line
        centerOffset   = .zero
        canShowCallout = true
    }

    // MARK: - Pulse Waves (Figma style)
    private func setupPulseLayers() {
        let pulseColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1).cgColor
        let center = CGPoint(x: containerSize / 2, y: containerSize / 2)

        for i in 0..<3 {
            let pulse = CAShapeLayer()
            let startSize: CGFloat = 28
            pulse.path = UIBezierPath(
                ovalIn: CGRect(origin: .zero, size: CGSize(width: startSize, height: startSize))
            ).cgPath
            pulse.bounds = CGRect(origin: .zero, size: CGSize(width: startSize, height: startSize))
            pulse.position = center
            pulse.fillColor = pulseColor
            pulse.opacity = 0
            layer.insertSublayer(pulse, at: 0)
            pulseLayers.append(pulse)

            addPulseAnimation(to: pulse, delay: Double(i) * 0.75)
        }
    }

    private func addPulseAnimation(to pulseLayer: CAShapeLayer, delay: Double) {
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.4
        scaleAnim.toValue   = 2.6

        let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnim.values   = [0.0, 0.55, 0.0]
        opacityAnim.keyTimes = [0.0, 0.25, 1.0]

        let group = CAAnimationGroup()
        group.animations            = [scaleAnim, opacityAnim]
        group.duration              = 2.25
        group.repeatCount           = .infinity
        group.beginTime             = CACurrentMediaTime() + delay
        group.isRemovedOnCompletion = false
        group.timingFunction        = CAMediaTimingFunction(name: .easeOut)

        pulseLayer.add(group, forKey: "pulse")
    }

    // MARK: - Rotate bus to face travel direction (with asset offset)
    func updateRotation(degrees: Double) {
        // Apply offset so image nose matches road heading
        let correctedDegrees = degrees + imageHeadingOffsetDegrees
        let targetRadians = CGFloat(correctedDegrees * .pi / 180)

        // Shortest-angle rotation (no full spins)
        var delta = targetRadians - currentRotation
        while delta > .pi  { delta -= 2 * .pi }
        while delta < -.pi { delta += 2 * .pi }
        let newRotation = currentRotation + delta

        // Only bus image rotates — pulse rings stay circular
        busImageView.transform = CGAffineTransform(rotationAngle: newRotation)
        currentRotation = newRotation
    }

    // MARK: - Resize Helper
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // MARK: - Fallback SF Symbol bus
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
                let origin = CGPoint(
                    x: (size.width - iconSize.width) / 2,
                    y: (size.height - iconSize.height) / 2
                )
                busIcon.draw(in: CGRect(origin: origin, size: iconSize))
            }
        }
    }
}
