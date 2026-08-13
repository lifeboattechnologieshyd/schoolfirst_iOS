//
//  Homescreen.swift
//  SchoolFirst
//

import UIKit

class Homescreen: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var StudentGadeLbl: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    
    @IBOutlet weak var ProfileEditButton: UIButton!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var ContainerView: UIView!
    
    // MARK: - MODULE DATA
    
    var modulesData: [[String: String]] = [
        
        [
            "title" : "Profile",
            "image" : "studentprofile"
        ],
        
        [
            "title" : "Bulletin",
            "image" : "bulletin"
        ],
        
        [
            "title" : "Homework",
            "image" : "homework"
        ],
        
        [
            "title" : "Fee",
            "image" : "feemanagement"
        ],
        
        [
            "title" : "Time Table",
            "image" : "time_table"
        ],
        
        [
            "title" : "Attendance",
            "image" : "attedence"
        ],
        
        [
            "title" : "Exams",
            "image" : "exams"
        ],
        
        [
            "title" : "Gallery",
            "image" : "gallery 1"
        ],
        
        [
            "title" : "Transport",
            "image" : "transport"
        ],
        
        [
            "title" : "Calendar",
            "image" : "calender"
        ],
        
        [
            "title" : "Remarks",
            "image" : "Remarks"
        ],
        
        [
            "title" : "Contact us",
            "image" : "communicate"
        ],
        
        [
            "title" : "Events",
            "image" : "event"
        ],
        
        [
            "title" : "PTM",
            "image" : "PTMimage"
        ],
        [
            "title" : "Portofolio",
            "image" : "Portofolioimg"
        ]
    ]
    
    // MARK: - CARD DATA
    
    var cardData: [[String: String]] = [
        
        [
            "title" : "HOMEWORK",
            "value" : "85%",
            "subtitle" : "35/30"
        ],
        
        [
            "title" : "ATTENDANCE",
            "value" : "92.5%",
            "subtitle" : "15/180 Absents"
        ],
        
        [
            "title" : "FEES",
            "value" : "Paid",
            "subtitle" : "No Dues"
        ],
        
        [
            "title" : "GRADE",
            "value" : "A+",
            "subtitle" : "Rank #2"
        ]
    ]
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupContainer()
        setupCollectionView()
        
        // MAKE COLLECTIONVIEW SCROLLABLE
        CollectionView.isScrollEnabled = true
        CollectionView.alwaysBounceVertical = true
        CollectionView.showsVerticalScrollIndicator = false
        ProfileImageView.backgroundColor = .clear
        
        StudentnameLbl.text = UserManager.shared.resolvedStudentName
        StudentGadeLbl.text   = UserManager.shared.resolvedGradeSection
    }
    
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        // If Homescreen was pushed from EdutainmentVC
        navigationController?.popViewController(animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // HIDE DEFAULT NAVIGATION BAR
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createCards()
    }
}

// MARK: - COLLECTIONVIEW SETUP

extension Homescreen {
    
    private func setupCollectionView() {
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        CollectionView.backgroundColor = .clear
        
        CollectionView.register(
            UINib(
                nibName: "ModulesCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "ModulesCollectionViewCell"
        )
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        
        layout.minimumLineSpacing = 14
        
        layout.minimumInteritemSpacing = 12
        
        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0
        )
        
        layout.itemSize = CGSize(
            width: 100,
            height: 140
        )
        
        CollectionView.collectionViewLayout = layout
    }
    private func setupBackButton() {

        BackButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Back Button Action

    @objc private func backButtonTapped() {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {

            let storyboard = UIStoryboard(
                name: "Main",
                bundle: nil
            )

            if let homeVC = storyboard.instantiateViewController(
                withIdentifier: "EdutainmentVC"
            ) as? EdutainmentVC {

                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true)
            }
        }
    }

    // MARK: - Notif
}

// MARK: - COLLECTIONVIEW METHODS

extension Homescreen:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return modulesData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ModulesCollectionViewCell",
            for: indexPath
        ) as! ModulesCollectionViewCell
        
        let item = modulesData[indexPath.row]
        
        // TITLE
        
        cell.ModuleTitle.text = item["title"]
        
        // IMAGE
        
        cell.ImageView.image = UIImage(
            named: item["image"] ?? ""
        )
        
        // CELL DESIGN
        
        cell.view.backgroundColor = .white
        
        cell.view.layer.cornerRadius = 20
        
        cell.view.layer.cornerCurve = .continuous
        
        // SHADOW
        
        cell.layer.shadowColor = UIColor.black.cgColor
        
        cell.layer.shadowOpacity = 0.08
        
        cell.layer.shadowOffset = CGSize(
            width: 0,
            height: 2
        )
        
        cell.layer.shadowRadius = 8
        
        cell.layer.masksToBounds = false
        
        // IMAGE
        
        cell.ImageView.contentMode = .scaleAspectFit
        
        // TITLE
        
        cell.ModuleTitle.textAlignment = .center
        
        cell.ModuleTitle.numberOfLines = 2
        
        cell.ModuleTitle.font = UIFont.systemFont(
            ofSize: 14,
            weight: .semibold
        )
        
        cell.ModuleTitle.textColor = UIColor.darkGray
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.frame.width - 24) / 3
        return CGSize(width: width, height: 96)
    }
    
    // MARK: - DID SELECT ITEM
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = modulesData[indexPath.row]
        let title = item["title"] ?? ""
        
        switch title {
            
        case "Profile":
            navigateToStudentProfile()
            
        case "Calendar":
            navigateToCalendar()
        case "PTM":
            navigateToPTM()
        
        // ✅ ADDED: Fee module navigation
        case "Fee":
            navigateToParentfeeVC()
            
        // ADD MORE CASES HERE LATER FOR OTHER MODULES
        case "Homework":
            navigateToHomework()
            navigateToTransport()
        case "Portofolio":
            navigateToPortofolio()
            
        case "Transport":
            navigateToTransport()
            
        default:
            print("Tapped: \(title)")
        }
    }
    
    // MARK: - NAVIGATION
    
    @IBAction func ButtonTapped(_ sender: UIButton) {
        navigateToStudentProfile()
    }
    
    private func navigateToStudentProfile() {
        
        // OPTION 1: If StudentprofileVC is in Storyboard with identifier "StudentprofileVC"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let profileVC = storyboard.instantiateViewController(
            withIdentifier: "StudentprofileVC"
        ) as? StudentprofileVC {
            
            profileVC.hidesBottomBarWhenPushed = true
            
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(profileVC, animated: true)
            } else {
                profileVC.modalPresentationStyle = .fullScreen
                present(profileVC, animated: true)
            }
        }
    }
    
    @IBAction func ProfileEditButtonTapped(_ sender: UIButton) {
        navigateToEditProfile()
    }
    
    private func navigateToEditProfile() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let editVC = storyboard.instantiateViewController(
            withIdentifier: "StudentprofileVC"
        ) as? EditProfileVC {

            editVC.hidesBottomBarWhenPushed = true

            if let nav = navigationController {

                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(editVC, animated: true)

            } else {

                editVC.modalPresentationStyle = .fullScreen
                present(editVC, animated: true)
            }
        }
    }
    
    
    // MARK: - NAVIGATE TO CALENDAR
    
    private func navigateToPTM() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let PTMVC = storyboard.instantiateViewController(
            withIdentifier: "PTMhomeVC"
        ) as? PTMhomeVC {

            PTMVC.hidesBottomBarWhenPushed = true

            if let nav = navigationController {

                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(PTMVC, animated: true)

            } else {

                PTMVC.modalPresentationStyle = .fullScreen
                present(PTMVC, animated: true)
            }
        }
    }
    // MARK: - NAVIGATE TO TRANSPORT
    
    private func navigateToTransport() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let TRANSPORT = storyboard.instantiateViewController(
            withIdentifier: "TranportParentDashbordVC"
        ) as? TranportParentDashbordVC {

            TRANSPORT.hidesBottomBarWhenPushed = true

            if let nav = navigationController {

                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(TRANSPORT, animated: true)

            } else {

                TRANSPORT.modalPresentationStyle = .fullScreen
                present(TRANSPORT, animated: true)
            }
        }
    }

    
    private func navigateToCalendar() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let calendarVC = storyboard.instantiateViewController(
            withIdentifier: "CalenderVC"
        ) as? CalenderVC {
            
            calendarVC.hidesBottomBarWhenPushed = true
            
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(calendarVC, animated: true)
            } else {
                calendarVC.modalPresentationStyle = .fullScreen
                present(calendarVC, animated: true)
            }
        }
    }
    
    private func navigateToHomework() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let HomeworkVC = storyboard.instantiateViewController(
            withIdentifier: "HomeworkVC"
        ) as? HomeworkVC {
            
            HomeworkVC.hidesBottomBarWhenPushed = true
            
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(HomeworkVC, animated: true)
            } else {
                HomeworkVC.modalPresentationStyle = .fullScreen
                present(HomeworkVC, animated: true)
            }
        }
    }
    private func navigateToPortofolio() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let StudentportfolioVC = storyboard.instantiateViewController(
            withIdentifier: "StudentportfolioVC"
        ) as? StudentportfolioVC {
            
            StudentportfolioVC.hidesBottomBarWhenPushed = true
            
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(StudentportfolioVC, animated: true)
            } else {
                StudentportfolioVC.modalPresentationStyle = .fullScreen
                present(StudentportfolioVC, animated: true)
            }
        }
    }
    
    // MARK: - NAVIGATE TO PAYMENT GATEWAY ✅ NEWLY ADDED
    
    private func navigateToParentfeeVC() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let paymentVC = storyboard.instantiateViewController(
            withIdentifier: "ParentfeeVC"
        ) as? ParentfeeVC {
            
            paymentVC.hidesBottomBarWhenPushed = true
            
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(paymentVC, animated: true)
            } else {
                paymentVC.modalPresentationStyle = .fullScreen
                present(paymentVC, animated: true)
            }
        }
    }
}

// MARK: - UI

extension Homescreen {
    
    private func setupContainer() {
        
        ContainerView.backgroundColor = UIColor(
            red: 0/255,
            green: 92/255,
            blue: 170/255,
            alpha: 1
        )
        
        ContainerView.layer.cornerRadius = 20
        
        ContainerView.clipsToBounds = true
    }
    
    private func createCards() {
        
        // REMOVE OLD VIEWS
        
        ContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        // CARD SETTINGS
        
        let horizontalPadding: CGFloat = 14
        
        let verticalPadding: CGFloat = 12
        
        let spacing: CGFloat = 12
        
        let cardWidth =
        (ContainerView.frame.width - (horizontalPadding * 2) - spacing) / 2
        
        let cardHeight: CGFloat = 85
        
        // TOTAL CONTENT HEIGHT
        
        let totalCardsHeight =
        (cardHeight * 2) + spacing
        
        // CENTER VERTICALLY
        
        let startY =
        (ContainerView.frame.height - totalCardsHeight) / 2
        
        for (index, item) in cardData.enumerated() {
            
            let row = index / 2
            
            let column = index % 2
            
            let x =
            horizontalPadding +
            CGFloat(column) * (cardWidth + spacing)
            
            let y =
            startY +
            CGFloat(row) * (cardHeight + spacing)
            
            // CARD VIEW
            
            let cardView = UIView(frame: CGRect(
                x: x,
                y: y,
                width: cardWidth,
                height: cardHeight
            ))
            
            cardView.backgroundColor = UIColor(
                red: 50/255,
                green: 115/255,
                blue: 185/255,
                alpha: 1
            )
            
            cardView.layer.cornerRadius = 18
            
            cardView.layer.borderWidth = 1
            
            cardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor
            
            ContainerView.addSubview(cardView)
            
            // TITLE LABEL
            
            let titleLabel = UILabel(frame: CGRect(
                x: 14,
                y: 10,
                width: cardWidth - 28,
                height: 15
            ))
            
            titleLabel.text = item["title"]
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            titleLabel.textColor = UIColor(
                white: 0.85,
                alpha: 1
            )
            
            cardView.addSubview(titleLabel)
            
            // VALUE LABEL
            
            let valueLabel = UILabel()
            
            valueLabel.font = UIFont.boldSystemFont(ofSize: 24)
            
            valueLabel.textColor = .white
            
            // FEES CARD
            
            if item["title"] == "FEES" {
                
                let greenDot = UIView(frame: CGRect(
                    x: 14,
                    y: 40,
                    width: 14,
                    height: 14
                ))
                
                greenDot.backgroundColor = .systemGreen
                
                greenDot.layer.cornerRadius = 7
                
                cardView.addSubview(greenDot)
                
                valueLabel.frame = CGRect(
                    x: 36,
                    y: 28,
                    width: cardWidth - 40,
                    height: 30
                )
                
                valueLabel.text = item["value"]
                
            } else {
                
                valueLabel.frame = CGRect(
                    x: 14,
                    y: 32,
                    width: cardWidth - 28,
                    height: 26
                )
                
                valueLabel.text = item["value"]
            }
            
            cardView.addSubview(valueLabel)
            
            // SUBTITLE
            
            let subtitleLabel = UILabel(frame: CGRect(
                x: 14,
                y: 62,
                width: cardWidth - 28,
                height: 15
            ))
            
            subtitleLabel.text = item["subtitle"]
            
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            
            subtitleLabel.textColor = .yellow
            
            cardView.addSubview(subtitleLabel)
        }
    }
}
