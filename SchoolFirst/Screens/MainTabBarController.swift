//
//  MainTabBarController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//

import UIKit
import Kingfisher

class MainTabBarController: UITabBarController {

    let centerButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ Apply custom U-dip tab bar
        setValue(UTabBarWithDip(), forKey: "tabBar")

        updateTabBarIcons()
        setupCenterButton()

        // ✅ ✅ MySchool tab title color (#0B569A)
        if let items = tabBar.items, items.count > 2 {

            let mySchoolItem = items[2]

            // Normal (gray)
            mySchoolItem.setTitleTextAttributes([
                .foregroundColor: UIColor.gray
            ], for: .normal)

            // Selected (#0B569A)
            mySchoolItem.setTitleTextAttributes([
                .foregroundColor: UIColor(
                    red: 0.043, green: 0.337, blue: 0.604, alpha: 1
                )
            ], for: .selected)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCenterButton()
    }

    // =========================================================
    // ✅ YOUR ORIGINAL FUNCTION
    // =========================================================
    func updateTabBarIcons()  {
        guard let url = UserManager.shared.user?.schools.first?.smallLogo else { return }

        Task {
            if let tabBarItems = tabBar.items {
                let url = URL(string: url)!
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 28, height: 28), mode: .aspectFit)

                do {
                    let result = try await KingfisherManager.shared.retrieveImage(with: url, options: [.processor(processor)])
                    let image = result.image.withRenderingMode(.alwaysOriginal)

                    tabBarItems[2].image = image
                    tabBarItems[2].selectedImage = image
                } catch {
                    print("❌ Failed to load image: \(error)")
                }
            }
        }
    }

    // =========================================================
    // ✅ FLOATING CIRCLE BUTTON
    // =========================================================
    func setupCenterButton() {

        let size: CGFloat = 55

        centerButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        centerButton.layer.cornerRadius = size / 2
        centerButton.backgroundColor = .white

        centerButton.setImage(UIImage(named: "oasis_logo"), for: .normal)
        centerButton.imageView?.contentMode = .scaleAspectFit
        centerButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        centerButton.layer.borderWidth = 3
        centerButton.layer.borderColor = UIColor(
            red: 0.043, green: 0.337, blue: 0.604, alpha: 1
        ).cgColor

        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.25
        centerButton.layer.shadowRadius = 12
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        centerButton.addTarget(self, action: #selector(selectCenterTab), for: .touchUpInside)

        view.addSubview(centerButton)
    }

    func positionCenterButton() {
        centerButton.center = CGPoint(
            x: tabBar.center.x,
            y: tabBar.frame.origin.y - 30   // ✅ Perfect inside dip
        )
    }

    @objc func selectCenterTab() {
        selectedIndex = 2
    }
}



// =======================================================================
// ✅ CUSTOM TAB BAR WITH U-DIP (FULLY FIXED POSITION)
// =======================================================================

class UTabBarWithDip: UITabBar {

    private var shapeLayer: CAShapeLayer?

    // ✅ FIXED → no up/down bouncing of the tab bar
    override func layoutSubviews() {
        super.layoutSubviews()

        guard let superview = self.superview else { return }

        var f = self.frame

        let safeBottom = self.window?.safeAreaInsets.bottom ?? superview.safeAreaInsets.bottom

        let desiredY = superview.bounds.height - f.height - safeBottom

        if abs(f.origin.y - desiredY) > 0.5 {
            f.origin.y = desiredY
            self.frame = f
        }
    }

    override func draw(_ rect: CGRect) {
        addShape()
    }

    private func addShape() {

        let shape = CAShapeLayer()
        shape.path = createDipPath()
        shape.fillColor = UIColor.white.cgColor

        shape.shadowColor = UIColor.black.cgColor
        shape.shadowOpacity = 0.12
        shape.shadowOffset = CGSize(width: 0, height: -3)
        shape.shadowRadius = 18

        if let old = shapeLayer {
            layer.replaceSublayer(old, with: shape)
        } else {
            layer.insertSublayer(shape, at: 0)
        }
        
        shapeLayer = shape
    }

    func createDipPath() -> CGPath {

        let width = bounds.width
        let height: CGFloat = 125
        let center = width / 2

        let dipWidth: CGFloat = 110
        let dipDepth: CGFloat = 40
        let cornerRadius: CGFloat = 30

        let path = UIBezierPath()

        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius),
                          controlPoint: CGPoint(x: 0, y: 0))

        path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))

        path.addQuadCurve(to: CGPoint(x: cornerRadius, y: height),
                          controlPoint: CGPoint(x: 0, y: height))

        path.addLine(to: CGPoint(x: width - cornerRadius, y: height))

        path.addQuadCurve(to: CGPoint(x: width, y: height - cornerRadius),
                          controlPoint: CGPoint(x: width, y: height))

        path.addLine(to: CGPoint(x: width, y: cornerRadius))

        path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0),
                          controlPoint: CGPoint(x: width, y: 0))

        // ✅ U-shaped dip
        let startX = center + dipWidth / 2
        let endX   = center - dipWidth / 2

        path.addLine(to: CGPoint(x: startX, y: 0))

        path.addQuadCurve(
            to: CGPoint(x: center, y: dipDepth),
            controlPoint: CGPoint(x: center + dipWidth/4, y: dipDepth)
        )

        path.addQuadCurve(
            to: CGPoint(x: endX, y: 0),
            controlPoint: CGPoint(x: center - dipWidth/4, y: dipDepth)
        )

        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        path.close()

        return path.cgPath
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = super.sizeThatFits(size)
        s.height = 60
        return s
    }
}

