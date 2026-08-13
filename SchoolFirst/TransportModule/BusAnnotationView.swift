//
//  BusAnnotationView.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 10/08/26.
//


import MapKit

class BusAnnotationView: MKAnnotationView {

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

        // ── Option 1: Custom bus image from Assets ────────────────────
        if let busImage = UIImage(named: "bus_icon") {
            image = resizeImage(busImage, targetSize: CGSize(width: 50, height: 50))
        } else {
            // ── Option 2: SF Symbol fallback with white circle bg ────
            image = createBusIconWithBackground()
        }

        centerOffset   = CGPoint(x: 0, y: -(image?.size.height ?? 0) / 2)
        canShowCallout = true
    }

    // MARK: - Rotate bus based on movement direction
    func rotate(degrees: Double) {
        let radians = CGFloat(degrees * .pi / 180)
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
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
        let size     = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let context = ctx.cgContext

            // ── White circle background ──────────────────────────
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(origin: .zero, size: size))

            // ── Blue border ──────────────────────────────────────
            context.setStrokeColor(UIColor.systemBlue.cgColor)
            context.setLineWidth(2)
            context.strokeEllipse(in: CGRect(
                x: 1, y: 1,
                width : size.width  - 2,
                height: size.height - 2
            ))

            // ── Draw bus SF Symbol centered ──────────────────────
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            let busIcon = UIImage(systemName: "bus.fill", withConfiguration: config)?
                          .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)

            if let busIcon = busIcon {
                let iconSize = CGSize(width: 30, height: 30)
                let origin   = CGPoint(
                    x: (size.width  - iconSize.width)  / 2,
                    y: (size.height - iconSize.height) / 2
                )
                busIcon.draw(in: CGRect(origin: origin, size: iconSize))
            }
        }
    }
}
