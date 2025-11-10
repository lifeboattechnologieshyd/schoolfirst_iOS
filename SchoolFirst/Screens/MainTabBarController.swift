//
//  MainTabBarController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//
import UIKit

class MainTabBarController: UITabBarController,
                            UITabBarControllerDelegate,
                            UINavigationControllerDelegate {

    let circleButton = UIButton(type: .custom)
    let homeIndex = 2
    let gapOffset: CGFloat = -10     // Gap between circle & tab bar

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

<<<<<<< HEAD
        setValue(UTabBarWithDip(), forKey: "tabBar")
=======
        // ✅ Use custom fixed tab bar
        let fixedTabBar = UTabBarFixedDip()
        setValue(fixedTabBar, forKey: "tabBar")
>>>>>>> bcb857823d88470db1c71c46ba58f3c143707d04

        setupCircleButton()
        disableMiddleTabItem()

        // ✅ Tell tab bar about circle for hitTest
        if let dip = tabBar as? UTabBarFixedDip {
            dip.circleButtonRef = circleButton
        }

        // ✅ Assign delegate for all navigation controllers
        for vc in viewControllers ?? [] {
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionCircle()
        updateVisibilityBasedOnDepth()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCircle()
    }

     //   Disable middle tab item
     func disableMiddleTabItem() {
        if let items = tabBar.items, items.count > homeIndex {
            items[homeIndex].isEnabled = false
            items[homeIndex].image = UIImage()
            items[homeIndex].selectedImage = UIImage()
        }
    }

     //   Setup floating circle button
     func setupCircleButton() {

        let size: CGFloat = 62
        circleButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleButton.layer.cornerRadius = size/2
        circleButton.backgroundColor = .white

        circleButton.setImage(UIImage(named: "oasis_logo"), for: .normal)
        circleButton.imageView?.contentMode = .scaleAspectFit
        circleButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        circleButton.layer.borderWidth = 3
        circleButton.layer.borderColor = UIColor.clear.cgColor   // ✅ Always clear by default

        circleButton.layer.shadowOpacity = 0.25
        circleButton.layer.shadowRadius = 10
        circleButton.layer.shadowOffset = CGSize(width: 0, height: 3)

        circleButton.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)

        tabBar.addSubview(circleButton)
        tabBar.bringSubviewToFront(circleButton)
    }

    func positionCircle() {
        circleButton.center = CGPoint(
            x: tabBar.bounds.midX,
            y: tabBar.bounds.minY + gapOffset
        )
    }

     //   Circle tap → Navigate Home
    //   ONLY here border becomes visible
     @objc func circleTapped() {

        selectedIndex = homeIndex

        if let nav = viewControllers?[homeIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }

        //   Border only on circle tap
        circleButton.layer.borderColor = UIColor(
            red: 0.043, green: 0.337, blue: 0.604, alpha: 1
        ).cgColor

        updateVisibilityBasedOnDepth()
    }

    // ----------------------------------------------------------------------
    // ✅ VISIBILITY LOGIC
    // ✅ Root screen → show tab bar + circle
    // ✅ Pushed screen → hide instantly (no flash)
    // ----------------------------------------------------------------------
    func updateVisibilityBasedOnDepth() {

        guard let nav = viewControllers?[selectedIndex] as? UINavigationController else { return }

        let isRoot = (nav.viewControllers.count == 1)

        if isRoot {
            tabBar.isHidden = false
            circleButton.isHidden = false
            circleButton.alpha = 1

        } else {
            tabBar.isHidden = true
            circleButton.isHidden = true
            circleButton.alpha = 0
        }
    }

    // ----------------------------------------------------------------------
    // ✅ Tab bar item tapped
    // ✅ ALWAYS remove border here
    // ----------------------------------------------------------------------
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {

        // ❌ Clear border when user taps ANY tab bar item
        circleButton.layer.borderColor = UIColor.clear.cgColor

        updateVisibilityBasedOnDepth()
    }

    // ----------------------------------------------------------------------
    // ✅ NO FLASH FIX — Hide BEFORE push animation
    // ----------------------------------------------------------------------
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {

        DispatchQueue.main.async {
            self.updateVisibilityBasedOnDepth()
        }
    }

    // Backup hide after push
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {

        updateVisibilityBasedOnDepth()
    }
}




 // ✅ FIXED TAB BAR WITH FRAME LOCK (NO MOVEMENT)
// ✅ DIP SHAPE + CORRECT HEIGHT
 
class UTabBarFixedDip: UITabBar {

    var circleButtonRef: UIButton?
    private var shapeLayer: CAShapeLayer?

    // ✅ LOCK FRAME — stops tab bar moving up/down EVER
    override var frame: CGRect {
        get { return super.frame }
        set {
            var fixed = newValue

            if let superview = super.superview {
                let bottom = superview.safeAreaInsets.bottom
                fixed.origin.y = superview.bounds.height - fixed.height - bottom
            }

            super.frame = fixed
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func draw(_ rect: CGRect) {
        addShape()
    }

    private func addShape() {

        let shape = CAShapeLayer()
        shape.path = dipPath()
        shape.fillColor = UIColor.white.cgColor

        shape.shadowOpacity = 0.12
        shape.shadowRadius = 16
        shape.shadowOffset = CGSize(width: 0, height: -2)

        if let old = shapeLayer {
            layer.replaceSublayer(old, with: shape)
        } else {
            layer.insertSublayer(shape, at: 0)
        }

        shapeLayer = shape
    }

    // ✅ ONLY circle tappable in dip space
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if let circle = circleButtonRef {
            let converted = convert(point, to: circle)

            if circle.point(inside: converted, with: event) {
                return circle
            }
        }

        return super.hitTest(point, with: event)
    }

    // ✅ DIP PATH — Perfect shape
    func dipPath() -> CGPath {

        let w = bounds.width
        let h: CGFloat = 75        // ✅ tab bar height
        let mid = w / 2

        let dipW: CGFloat = 110
        let dipD: CGFloat = 28     // ✅ dip depth
        let r: CGFloat = 26        // ✅ corner radius

        let p = UIBezierPath()

        p.move(to: CGPoint(x: r, y: 0))
        p.addQuadCurve(to: CGPoint(x: 0, y: r),
                       controlPoint: CGPoint(x: 0, y: 0))

        p.addLine(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: w, y: h))
        p.addLine(to: CGPoint(x: w, y: r))

        p.addQuadCurve(to: CGPoint(x: w-r, y: 0),
                       controlPoint: CGPoint(x: w, y: 0))

        // DIP
        let start = mid + dipW/2
        let end   = mid - dipW/2

        p.addLine(to: CGPoint(x: start, y: 0))

        p.addQuadCurve(to: CGPoint(x: mid, y: dipD),
                       controlPoint: CGPoint(x: mid + dipW/4, y: dipD))

        p.addQuadCurve(to: CGPoint(x: end, y: 0),
                       controlPoint: CGPoint(x: mid - dipW/4, y: dipD))

        p.addLine(to: CGPoint(x: r, y: 0))
        p.close()

        return p.cgPath
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = super.sizeThatFits(size)
        s.height = 75        // ✅ Correct height
        return s
    }
}

