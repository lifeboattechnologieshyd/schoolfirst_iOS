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

    // MARK: - Tab Configuration (Figma Design)
    // Tab items matching Figma: Calendar | Edutainment | Home | Feels | Profile
    let tabItems: [(icon: String, title: String, systemIcon: String)] = [
        ("Calendar vector icon", "Calendar",    "calendar"),
        ("Feels emotion symbol", "Edutainment", "face.smiling"),
        ("Vector 1",               "Home",        "house"),
        ("Vocabee play vector icon", "Feels",   "play.circle"),
        ("Profile vector icon",  "Profile",     "person")
    ]

    let homeIndex = 2   // "Home" is in the center

    // MARK: - Colors
    let selectedColor   = UIColor(red: 0.043, green: 0.337, blue: 0.859, alpha: 1) // blue
    let normalColor     = UIColor(red: 0.42,  green: 0.46,  blue: 0.54,  alpha: 1) // gray
    let selectedBgColor = UIColor(red: 0.043, green: 0.337, blue: 0.859, alpha: 0.10)

    // MARK: - Layout constants
    let tabBarCustomHeight:  CGFloat = 72   // height of the floating pill container
    let tabBarSideInset:     CGFloat = 16   // horizontal margin from screen edge
    let tabBarBottomInset:   CGFloat = 12   // gap above home-indicator

    // MARK: - Private state
    private var customTabBarView: UIView!
    private var pillBgView: UIView!          // rounded pill background
    private var tabButtons: [UIButton] = []
    private var isTabBarSetup = false
    var isSchoolUser = false

    // MARK: - Life-cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        hideNativeTabBar()

        if !isTabBarSetup {
            setupCustomTabBar()
            isTabBarSetup = true
        }

        for vc in viewControllers ?? [] {
            if let nav = vc as? UINavigationController { nav.delegate = self }
        }

        updateTabSelection(to: selectedIndex)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNativeTabBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNativeTabBar()
        layoutCustomTabBar()
        updateVisibilityBasedOnDepth()
        bringTabBarToFront()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideNativeTabBar()
        layoutCustomTabBar()
    }

    // MARK: - Native tab bar suppression

    func hideNativeTabBar() {
        tabBar.isHidden = true
        tabBar.alpha = 0
        tabBar.isUserInteractionEnabled = false
        tabBar.frame.origin.y = UIScreen.main.bounds.height + 100
    }

    // MARK: - Build custom tab bar

    func setupCustomTabBar() {
        // Outer container (clear, same width as screen)
        customTabBarView = UIView()
        customTabBarView.backgroundColor = .clear
        customTabBarView.tag = 999
        view.addSubview(customTabBarView)

        // Rounded pill card (white, shadow)
        pillBgView = UIView()
        pillBgView.backgroundColor = .white
        pillBgView.layer.cornerRadius = 28
        pillBgView.layer.shadowColor   = UIColor.black.cgColor
        pillBgView.layer.shadowOpacity = 0.10
        pillBgView.layer.shadowRadius  = 16
        pillBgView.layer.shadowOffset  = CGSize(width: 0, height: 4)
        customTabBarView.addSubview(pillBgView)

        buildTabButtons()
    }

    func buildTabButtons() {
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()

        for (index, item) in tabItems.enumerated() {
            let btn = makeFigmaTabButton(item: item, tag: index)
            pillBgView.addSubview(btn)
            tabButtons.append(btn)
        }
    }

    // Creates a vertical stack (icon pill + label) matching the Figma tab style
    func makeFigmaTabButton(item: (icon: String, title: String, systemIcon: String), tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

        // --- icon background pill (shows only when selected) ---
        let iconBg = UIView()
        iconBg.backgroundColor = selectedBgColor
        iconBg.layer.cornerRadius = 16
        iconBg.alpha = 0
        iconBg.isUserInteractionEnabled = false
        iconBg.tag = 200          // to find it later
        btn.addSubview(iconBg)

        // --- icon image ---
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        iconView.tag = 100

        // Try asset first, then SF Symbol
        if let assetImg = UIImage(named: item.icon) {
            iconView.image = assetImg.withRenderingMode(.alwaysTemplate)
        } else if let sfImg = UIImage(systemName: item.systemIcon) {
            iconView.image = sfImg.withRenderingMode(.alwaysTemplate)
        }
        iconView.tintColor = normalColor
        btn.addSubview(iconView)

        // --- label ---
        let lbl = UILabel()
        lbl.text = item.title
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = normalColor
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        lbl.isUserInteractionEnabled = false
        lbl.tag = 101
        btn.addSubview(lbl)

        // --- auto-layout ---
        iconBg.translatesAutoresizingMaskIntoConstraints  = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        lbl.translatesAutoresizingMaskIntoConstraints      = false

        NSLayoutConstraint.activate([
            // icon pill: 44 × 32, centred horizontally, sits in the top part of the button
            iconBg.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            iconBg.topAnchor.constraint(equalTo: btn.topAnchor, constant: 8),
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 32),

            // icon image inside the pill
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            // label below the pill
            lbl.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 3),
            lbl.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            lbl.leadingAnchor.constraint(greaterThanOrEqualTo: btn.leadingAnchor, constant: 2),
            lbl.trailingAnchor.constraint(lessThanOrEqualTo: btn.trailingAnchor, constant: -2)
        ])

        return btn
    }

    // MARK: - Layout (called every time bounds change)

    func layoutCustomTabBar() {
        guard customTabBarView != nil, customTabBarView.superview != nil else { return }

        let totalH    = tabBarCustomHeight
        let sideInset = tabBarSideInset
        let w         = view.bounds.width - sideInset * 2

        // Position matches the Homescreen SwiftUI tab bar:
        // 12pt from the true screen bottom (ignores safe area, same as .ignoresSafeArea + .padding(.bottom,12))
        customTabBarView.frame = CGRect(
            x: sideInset,
            y: view.bounds.height - totalH - tabBarBottomInset,
            width: w,
            height: totalH
        )

        // Pill fills the container
        pillBgView.frame = customTabBarView.bounds

        // Distribute tab buttons equally inside the pill
        let btnW = w / CGFloat(tabItems.count)
        for (index, btn) in tabButtons.enumerated() {
            btn.frame = CGRect(x: btnW * CGFloat(index), y: 0, width: btnW, height: totalH)
        }
    }

    // MARK: - Selection

    @objc func tabButtonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        selectedIndex = newIndex
        updateTabSelection(to: newIndex)

        if let nav = viewControllers?[newIndex] as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
    }

    func updateTabSelection(to selectedIdx: Int) {
        for (index, btn) in tabButtons.enumerated() {
            let isSelected = (index == selectedIdx)

            // Icon pill background
            if let iconBg = btn.subviews.first(where: { $0.tag == 200 }) {
                iconBg.alpha = isSelected ? 1 : 0
            }
            // Icon tint
            if let iconView = btn.subviews.first(where: { $0.tag == 100 }) as? UIImageView {
                iconView.tintColor = isSelected ? selectedColor : normalColor
            }
            // Label
            if let lbl = btn.subviews.first(where: { $0.tag == 101 }) as? UILabel {
                lbl.textColor = isSelected ? selectedColor : normalColor
                lbl.font = UIFont.systemFont(ofSize: 10, weight: isSelected ? .semibold : .medium)
            }
        }
    }

    override var selectedIndex: Int {
        didSet { updateTabSelection(to: selectedIndex) }
    }

    // MARK: - Visibility helpers

    func bringTabBarToFront() {
        view.bringSubviewToFront(customTabBarView)
    }

    func updateVisibilityBasedOnDepth() {
        guard let nav = viewControllers?[selectedIndex] as? UINavigationController else { return }
        let isRoot = (nav.viewControllers.count == 1)
        customTabBarView?.isHidden = !isRoot
        hideNativeTabBar()
    }

    // MARK: - Delegate

    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        updateTabSelection(to: selectedIndex)
        updateVisibilityBasedOnDepth()
        hideNativeTabBar()
    }

    func navigationController(_ navigationController: UINavigationController,
                               willShow viewController: UIViewController,
                               animated: Bool) {
        DispatchQueue.main.async {
            self.updateVisibilityBasedOnDepth()
            self.hideNativeTabBar()
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                               didShow viewController: UIViewController,
                               animated: Bool) {
        updateVisibilityBasedOnDepth()
        hideNativeTabBar()
    }

    // MARK: - Unused legacy stubs (kept so callers don't break)

    // These were part of the old "circle button" Home design.
    // They are no longer used but kept to avoid breaking any
    // call-sites that might reference them from other files.

    var isSchoolUserUnused: Bool { isSchoolUser }

    func updateMiddleTabTitleAndImage() {
        // No-op — the centre tab is now a standard flat tab (no floating circle).
    }
}
