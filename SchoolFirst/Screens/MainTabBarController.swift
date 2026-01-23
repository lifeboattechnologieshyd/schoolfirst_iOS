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
    let middleLabel = UILabel()  // ✅ Label for middle button
    let homeIndex = 2
    let gapOffset: CGFloat = 10
    
    private var tabBarShapeLayer: CAShapeLayer?
    private var customTabBarView: UIView!
    private var tabButtons: [UIButton] = []
    
    // ✅ Tab bar customization
    let tabBarBottomMargin: CGFloat = 1
    let tabBarCustomHeight: CGFloat = 60
    
    // ✅ Tab items data (icon name, title)
    let tabItems: [(icon: String, title: String)] = [
        ("calendar_tab", "Calendar"),
        ("courses_tab", "CourseEdemy"),
        ("", ""),  // Middle - will be set dynamically
        ("edutain_tab", "Edutain"),
        ("profile_tab", "Profile")
    ]
    
    // ✅ Colors
    let selectedColor = UIColor(red: 0.043, green: 0.337, blue: 0.604, alpha: 1)
    let normalColor = UIColor.gray
    
    // ✅ Track if school user
    var isSchoolUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // ✅ Hide default tab bar completely
        tabBar.isHidden = true
        
        // ✅ Create custom tab bar
        setupCustomTabBar()
        setupCircleButton()
        setupMiddleLabel()
        
        for vc in viewControllers ?? [] {
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
        
        // ✅ Update middle tab title & circle image dynamically
        updateMiddleTabTitleAndImage()
        updateTabSelection()
    }
    
    // ✅ Create completely custom tab bar
    func setupCustomTabBar() {
        customTabBarView = UIView()
        customTabBarView.backgroundColor = .clear
        view.addSubview(customTabBarView)
        
        addTabBarShape()
        createTabButtons()
    }
    
    func positionCustomTabBar() {
        let bottomInset = view.safeAreaInsets.bottom
        customTabBarView.frame = CGRect(
            x: 0,
            y: view.bounds.height - tabBarCustomHeight - tabBarBottomMargin - bottomInset,
            width: view.bounds.width,
            height: tabBarCustomHeight
        )
        
        addTabBarShape()
        positionTabButtons()
    }
    
    func createTabButtons() {
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        for (index, item) in tabItems.enumerated() {
            // Skip middle (circle button area)
            if index == homeIndex {
                let emptyButton = UIButton()
                emptyButton.isUserInteractionEnabled = false
                tabButtons.append(emptyButton)
                continue
            }
            
            let button = createTabButton(
                icon: item.icon,
                title: item.title,
                tag: index
            )
            customTabBarView.addSubview(button)
            tabButtons.append(button)
        }
    }
    
    // ✅ Create tab button with icon and title
    func createTabButton(icon: String, title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        // ✅ Vertical stack: icon on top, label below
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        // ✅ Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = normalColor
        iconImageView.tag = 100
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // ✅ Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = normalColor
        titleLabel.textAlignment = .center
        titleLabel.tag = 101
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -2)
        ])
        
        return button
    }
    
    func positionTabButtons() {
        let buttonWidth = view.bounds.width / CGFloat(tabItems.count)
        let buttonHeight = tabBarCustomHeight
        
        for (index, button) in tabButtons.enumerated() {
            if index == homeIndex { continue }
            
            button.frame = CGRect(
                x: CGFloat(index) * buttonWidth,
                y: 0,
                width: buttonWidth,
                height: buttonHeight
            )
        }
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateTabSelection()
        
        if let nav = viewControllers?[sender.tag] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        circleButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    // ✅ Update tab selection highlighting
    func updateTabSelection() {
        for (index, button) in tabButtons.enumerated() {
            if index == homeIndex { continue }
            
            let isSelected = (index == selectedIndex)
            
            if let stackView = button.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                
                if let iconView = stackView.arrangedSubviews.first as? UIImageView {
                    iconView.tintColor = isSelected ? selectedColor : normalColor
                }
                
                if let label = stackView.arrangedSubviews.last as? UILabel {
                    label.textColor = isSelected ? selectedColor : normalColor
                    label.font = UIFont.systemFont(ofSize: 10, weight: isSelected ? .semibold : .medium)
                }
            }
        }
        
        // ✅ Update circle button and middle label
        if selectedIndex == homeIndex {
            circleButton.layer.borderColor = selectedColor.cgColor
            middleLabel.textColor = selectedColor
            middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        } else {
            circleButton.layer.borderColor = UIColor.clear.cgColor
            middleLabel.textColor = normalColor
            middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        }
    }
    
    func addTabBarShape() {
        tabBarShapeLayer?.removeFromSuperlayer()
        
        guard customTabBarView != nil else { return }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createDipPath()
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowOpacity = 0.15
        shapeLayer.shadowRadius = 16
        shapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        shapeLayer.shadowColor = UIColor.black.cgColor
        
        customTabBarView.layer.insertSublayer(shapeLayer, at: 0)
        tabBarShapeLayer = shapeLayer
    }
    
    func createDipPath() -> CGPath {
        let w = view.bounds.width
        let h: CGFloat = tabBarCustomHeight
        let mid = w / 2
        let r: CGFloat = 24
        let dipW: CGFloat = w * 0.26
        let dipD: CGFloat = 26
        
        let p = UIBezierPath()
        
        p.move(to: CGPoint(x: r, y: 0))
        p.addQuadCurve(to: CGPoint(x: 0, y: r), controlPoint: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 0, y: h - r))
        p.addQuadCurve(to: CGPoint(x: r, y: h), controlPoint: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: w - r, y: h))
        p.addQuadCurve(to: CGPoint(x: w, y: h - r), controlPoint: CGPoint(x: w, y: h))
        p.addLine(to: CGPoint(x: w, y: r))
        p.addQuadCurve(to: CGPoint(x: w - r, y: 0), controlPoint: CGPoint(x: w, y: 0))
        
        let dipStart = mid + dipW / 2
        let dipEnd = mid - dipW / 2
        
        p.addLine(to: CGPoint(x: dipStart, y: 0))
        p.addQuadCurve(to: CGPoint(x: mid, y: dipD), controlPoint: CGPoint(x: mid + dipW / 4, y: dipD))
        p.addQuadCurve(to: CGPoint(x: dipEnd, y: 0), controlPoint: CGPoint(x: mid - dipW / 4, y: dipD))
        p.addLine(to: CGPoint(x: r, y: 0))
        p.close()
        
        return p.cgPath
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCustomTabBar()
        positionCircle()
        positionMiddleLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionCustomTabBar()
        positionCircle()
        positionMiddleLabel()
        updateVisibilityBasedOnDepth()
    }
    
    func setupCircleButton() {
        let size: CGFloat = 60
        circleButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleButton.layer.cornerRadius = size / 2
        circleButton.backgroundColor = .white
        
        circleButton.setImage(UIImage(named: "oasis_logo"), for: .normal)
        circleButton.imageView?.contentMode = .scaleAspectFit
        circleButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        circleButton.layer.borderWidth = 3
        circleButton.layer.borderColor = UIColor.clear.cgColor
        
        circleButton.layer.shadowOpacity = 0.25
        circleButton.layer.shadowRadius = 10
        circleButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        circleButton.layer.shadowColor = UIColor.black.cgColor
        
        circleButton.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)
        
        view.addSubview(circleButton)
        view.bringSubviewToFront(circleButton)
    }
    
    // ✅ Setup middle label
    func setupMiddleLabel() {
        middleLabel.text = "MySchool"  // Default, will be updated
        middleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        middleLabel.textColor = normalColor
        middleLabel.textAlignment = .center
        middleLabel.adjustsFontSizeToFitWidth = true
        middleLabel.minimumScaleFactor = 0.7
        
        customTabBarView.addSubview(middleLabel)
    }
    
    // ✅ Position middle label below the dip
    func positionMiddleLabel() {
        guard customTabBarView != nil else { return }
        
        let labelWidth: CGFloat = 80
        let labelHeight: CGFloat = 14
        
        middleLabel.frame = CGRect(
            x: (view.bounds.width - labelWidth) / 2,
            y: tabBarCustomHeight - labelHeight - 8,
            width: labelWidth,
            height: labelHeight
        )
    }
    
    func positionCircle() {
        guard customTabBarView != nil else { return }
        
        let tabFrame = customTabBarView.frame
        let circleHalf = circleButton.bounds.height / 2

        circleButton.center = CGPoint(
            x: tabFrame.midX,
            y: tabFrame.minY - circleHalf + gapOffset
        )
        
        view.bringSubviewToFront(circleButton)
    }
    
    @objc func circleTapped() {
        selectedIndex = homeIndex
        updateTabSelection()
        
        if let nav = viewControllers?[homeIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        circleButton.layer.borderColor = selectedColor.cgColor
    }
    
    func updateVisibilityBasedOnDepth() {
        guard let nav = viewControllers?[selectedIndex] as? UINavigationController else { return }
        
        let isRoot = (nav.viewControllers.count == 1)
        
        if isRoot {
            customTabBarView.isHidden = false
            circleButton.isHidden = false
            middleLabel.isHidden = false
            circleButton.alpha = 1
            circleButton.isUserInteractionEnabled = true
        } else {
            customTabBarView.isHidden = true
            circleButton.isHidden = true
            middleLabel.isHidden = true
            circleButton.alpha = 0
            circleButton.isUserInteractionEnabled = false
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            updateTabSelection()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        updateTabSelection()
        updateVisibilityBasedOnDepth()
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        DispatchQueue.main.async {
            self.updateVisibilityBasedOnDepth()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        updateVisibilityBasedOnDepth()
    }
    
    // ✅ LOGIC FROM YOUR OLD CODE - Update middle tab title & circle image dynamically
    func updateMiddleTabTitleAndImage() {
        
        isSchoolUser = false
        
        // ✅ Check if user has students with school
        if UserManager.shared.user?.students?.count ?? 0 > 0 {
            let first_student = UserManager.shared.user?.students?.first!
            if let school = first_student?.school {
                isSchoolUser = true
                // ✅ Load school logo into circle button
                circleButton.loadImage(url: school.smallLogo ?? "")
            }
        }
        
        // ✅ If not school user, use MyPlan image
        if !isSchoolUser {
            circleButton.setImage(UIImage(named: "MyPlan"), for: .normal)
        }
        
        // ✅ Update middle label text based on user type
        middleLabel.text = isSchoolUser ? "MySchool" : "MyPlan"
        
        // ✅ Clear button title (we use separate label)
        circleButton.setTitle("", for: .normal)
    }
}
