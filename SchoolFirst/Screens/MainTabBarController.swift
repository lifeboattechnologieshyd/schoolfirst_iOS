//
//  MainTabBarController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//

import UIKit
import Kingfisher

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    let centerButton = UIButton()
    let homeIndex = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        // ✅ Your custom dip tab bar
        setValue(UTabBarWithDip(), forKey: "tabBar")

        updateTabBarIcons()
        setupCenterButton()

        updateCircleVisibility()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ Keep circle aligned to tab bar always
        centerButton.center = CGPoint(
            x: tabBar.center.x,
            y: tabBar.frame.origin.y - 30
        )

        updateCircleVisibility()
    }

    // ============================================================
    // ✅ Tab bar middle icon should be invisible (fix duplicate issue)
    // ============================================================
    func updateTabBarIcons() {
        guard let items = tabBar.items else { return }

        let clear = UIImage()
        items[homeIndex].image = clear
        items[homeIndex].selectedImage = clear
    }

    // ============================================================
    // ✅ Floating Circle Button
    // ============================================================
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

        centerButton.addTarget(self, action: #selector(selectHomeTab), for: .touchUpInside)

        // ✅ Must be added to MAIN VIEW so tabbar height never changes
        view.addSubview(centerButton)
    }

    @objc func selectHomeTab() {
        selectedIndex = homeIndex
        updateCircleVisibility()
    }

    // ============================================================
    // ✅ FINAL VISIBILITY LOGIC (OPTION A)
    // ✅ Circle visible ALWAYS when tabbar visible
    // ✅ Circle hidden ONLY when tabbar hidden
    // ============================================================
    func updateCircleVisibility() {

        let tabBarVisible = (!tabBar.isHidden && tabBar.alpha > 0.01)

        // ✅ Circle behaves exactly like tab bar (constant)
        centerButton.isHidden = !tabBarVisible
    }

    // Tab switching
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {

        updateCircleVisibility()
    }
}


// =======================================================================
// ✅ CUSTOM U-DIP TAB BAR (UNCHANGED)
// =======================================================================

class UTabBarWithDip: UITabBar {

    private var shapeLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        // This keeps the tab bar at correct location
        guard let superview = self.superview else { return }

        var f = self.frame
        let safeBottom = self.window?.safeAreaInsets.bottom ?? superview.safeAreaInsets.bottom
        f.origin.y = superview.bounds.height - f.height - safeBottom
        self.frame = f
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
        let height: CGFloat = 60
        let center = width / 2

        let dipWidth: CGFloat = 110
        let dipDepth: CGFloat = 40
        let cornerRadius: CGFloat = 30

        let path = UIBezierPath()

        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius),
                          controlPoint: CGPoint(x: 0, y: 0))

        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: cornerRadius))

        path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0),
                          controlPoint: CGPoint(x: width, y: 0))

        // ✅ dip
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
        s.height = 60   // ✅ your fixed height
        return s
    }
}

