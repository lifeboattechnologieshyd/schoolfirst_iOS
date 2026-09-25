//
//  Homescreen.swift
//  SchoolFirst
//
//  Created by vamshi krishna
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
        ["title": "Profile", "image": "studentprofile"],
        ["title": "Bulletin", "image": "bulletin"],
        ["title": "Homework", "image": "homework"],
        ["title": "Fee", "image": "feemanagement"],
        ["title": "Time Table", "image": "time_table"],
        ["title": "Attendance", "image": "attedence"],
        ["title": "Exams", "image": "exams"],
        ["title": "Gallery", "image": "gallery 1"],
        ["title": "Transport", "image": "transport"],
        ["title": "Calendar", "image": "calender"],
        ["title": "Remarks", "image": "Remarks"],
        ["title": "Contact us", "image": "communicate"],
        ["title": "Events", "image": "event"],
        ["title": "PTM", "image": "PTMimage"],
        ["title": "Portofolio", "image": "Portofolioimg"]
    ]

    // MARK: - CARD DATA
    var cardData: [[String: String]] = [
        ["title": "HOMEWORK", "value": "85%", "subtitle": "35/30"],
        ["title": "ATTENDANCE", "value": "92.5%", "subtitle": "15/180 Absents"],
        ["title": "FEES", "value": "Paid", "subtitle": "No Dues"],
        ["title": "GRADE", "value": "A+", "subtitle": "Rank #2"]
    ]

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupContainer()
        setupCollectionView()

        CollectionView.isScrollEnabled = true
        CollectionView.alwaysBounceVertical = true
        CollectionView.showsVerticalScrollIndicator = false

        setupProfileImageViewStyle()

        StudentnameLbl.text = UserManager.shared.resolvedStudentName
        StudentGadeLbl.text = UserManager.shared.resolvedGradeSection

        loadStudentProfileImage()
    }

    @IBAction func BackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadStudentProfileImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ProfileImageView.layer.cornerRadius = ProfileImageView.frame.size.height / 2
        createCards()
    }
}

// MARK: - PROFILE IMAGE LOADER
extension Homescreen {

    private func setupProfileImageViewStyle() {
        ProfileImageView.backgroundColor = .clear
        ProfileImageView.contentMode = .scaleAspectFill
        ProfileImageView.clipsToBounds = true
        ProfileImageView.layer.borderWidth = 1.5
        ProfileImageView.layer.borderColor = UIColor.white.cgColor
    }

    private func loadStudentProfileImage() {
        let photoURLString = UserManager.shared.resolvedStudentPhotoURL
        guard !photoURLString.isEmpty, let url = URL(string: photoURLString) else {
            setProfilePlaceholder()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Error loading profile image: \(error.localizedDescription)")
                DispatchQueue.main.async { self.setProfilePlaceholder() }
                return
            }
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                DispatchQueue.main.async { self.setProfilePlaceholder() }
                return
            }
            DispatchQueue.main.async { self.ProfileImageView.image = downloadedImage }
        }.resume()
    }

    private func setProfilePlaceholder() {
        if let localAsset = UIImage(named: "studentprofile") {
            ProfileImageView.image = localAsset
        } else {
            ProfileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            ProfileImageView.tintColor = .lightGray
        }
    }
}

// MARK: - COLLECTIONVIEW SETUP
extension Homescreen {

    private func setupCollectionView() {
        CollectionView.delegate = self
        CollectionView.dataSource = self
        CollectionView.backgroundColor = .clear

        CollectionView.register(
            UINib(nibName: "ModulesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ModulesCollectionViewCell"
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 100, height: 140)
        CollectionView.collectionViewLayout = layout
    }

    private func setupBackButton() {
        BackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "EdutainmentVC") as? EdutainmentVC {
                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true)
            }
        }
    }
}

// MARK: - COLLECTIONVIEW METHODS
extension Homescreen: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modulesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModulesCollectionViewCell", for: indexPath) as! ModulesCollectionViewCell
        let item = modulesData[indexPath.row]

        cell.ModuleTitle.text = item["title"]
        cell.ImageView.image = UIImage(named: item["image"] ?? "")
        cell.view.backgroundColor = .white
        cell.view.layer.cornerRadius = 20
        cell.view.layer.cornerCurve = .continuous

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 8
        cell.layer.masksToBounds = false

        cell.ImageView.contentMode = .scaleAspectFit
        cell.ModuleTitle.textAlignment = .center
        cell.ModuleTitle.numberOfLines = 2
        cell.ModuleTitle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cell.ModuleTitle.textColor = UIColor.darkGray
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 24) / 3
        return CGSize(width: width, height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = modulesData[indexPath.row]
        let title = item["title"] ?? ""

        switch title {
        case "Profile": navigateToStudentProfile()
        case "Calendar": navigateToCalendar()
        case "PTM": navigateToPTM()
        case "Fee": navigateToParentfeeVC()
        case "Homework": navigateToHomework()
        case "Portofolio": navigateToPortofolio()
        case "Transport":
            print("🔥 Transport module selected")
            navigateToTransport()
        case "Attendance": navigateToAttendance()
        default: print("Tapped: \(title)")
        }
    }

    // MARK: - TRANSPORT NAVIGATION
    private func navigateToTransport() {
        print("🚍 navigateToTransport() called")

        let studentId = UserManager.shared.resolvedStudentID
        let schoolId = UserManager.shared.resolvedSchoolID
        print("👨🎓 Student ID: \(studentId)")
        print("🏫 School ID: \(schoolId)")

        guard !studentId.isEmpty, !schoolId.isEmpty else {
            print("⚠️ Student ID or School ID is empty ➡️ NO TRANSPORT")
            showTransportNotOptedVC()
            return
        }

        showLoader()

        NetworkManager.shared.request(
            urlString: API.TRANSPORT_BUS,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<StudentBusData>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let response):
                    print("🚍 Transport API response received | success: \(response.success)")
                    if response.success,
                       let data = response.data,
                       let bus = data.bus,
                       !(bus.vehicleNumber ?? "").isEmpty {
                        print("✅ Student has transport 🚌 \(bus.vehicleNumber ?? "N/A")")
                        self.showTransportDashboardVC(busData: data)
                    } else {
                        print("➡️ Treating this as NO TRANSPORT")
                        self.showTransportNotOptedVC()
                    }
                case .failure(let error):
                    print("❌ Transport API error: \(error.localizedDescription)")
                    print("➡️ Treating this as NO TRANSPORT")
                    self.showTransportNotOptedVC()
                }
            }
        }
    }

    // MARK: - TRANSPORT DASHBOARD
    private func showTransportDashboardVC(busData: StudentBusData) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let dashboardVC = storyboard.instantiateViewController(
            withIdentifier: "TranportParentDashbordVC"
        ) as? TranportParentDashbordVC else {
            print("❌ Could not instantiate TranportParentDashbordVC")
            return
        }
        dashboardVC.busData = busData
        dashboardVC.hidesBottomBarWhenPushed = true
        navigateToTransportViewController(dashboardVC)
    }

    // MARK: - TRANSPORT NOT OPTED
    private func showTransportNotOptedVC() {
        print("🔥 TRANSPORT NOT OPTED NAVIGATION STARTED")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: TransportnotoptedVC
        if let sbVC = storyboard.instantiateViewController(
            withIdentifier: "TransportnotoptedVC"
        ) as? TransportnotoptedVC {
            vc = sbVC
        } else {
            print("⚠️ Storyboard instantiate failed — using programmatic init")
            vc = TransportnotoptedVC()
        }

        pushNotOptedVC(vc)
    }

    // ✅ THE FIX:
    // NetworkManager presents an "Error" alert when the API returns 400.
    // UIKit SILENTLY IGNORES pushViewController while an alert is presenting
    // on the top VC — that is why your previous push never landed.
    // So: wait for the alert to appear, dismiss it, then push.
    private func pushNotOptedVC(_ vc: TransportnotoptedVC) {
        vc.hidesBottomBarWhenPushed = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }

            let doPush = { [weak self] in
                guard let self = self else { return }
                if let nav = self.navigationController {
                    nav.setNavigationBarHidden(true, animated: false)
                    nav.pushViewController(vc, animated: true)
                    print("✅ Pushed TransportnotoptedVC")
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    print("✅ Presented TransportnotoptedVC modally")
                }
            }

            // Dismiss the blocking "Error" alert (on self OR on the nav controller)
            let blocker = self.presentedViewController
                ?? self.navigationController?.presentedViewController

            if let blocker = blocker {
                print("⚠️ Dismissing blocking alert: \(type(of: blocker))")
                blocker.dismiss(animated: false, completion: doPush)
            } else {
                doPush()
            }
        }
    }

    // MARK: - COMMON TRANSPORT NAVIGATION
    private func navigateToTransportViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideLoader()

            guard let nav = self.navigationController else {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
                return
            }

            if nav.topViewController === viewController {
                print("⚠️ \(type(of: viewController)) is already visible")
                return
            }

            let transportScreenExists = nav.viewControllers.contains {
                $0 is TransportnotoptedVC || $0 is TranportParentDashbordVC
            }

            if transportScreenExists {
                let filtered = nav.viewControllers.filter {
                    !($0 is TransportnotoptedVC) && !($0 is TranportParentDashbordVC)
                }
                nav.setViewControllers(filtered, animated: false)
            }

            nav.setNavigationBarHidden(true, animated: false)
            nav.pushViewController(viewController, animated: true)
            print("✅ Pushed \(type(of: viewController))")
        }
    }

    // MARK: - NAVIGATION HELPERS
    @IBAction func ButtonTapped(_ sender: UIButton) { navigateToStudentProfile() }

    private func navigateToStudentProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "StudentprofileVC") as? StudentprofileVC {
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

    @IBAction func ProfileEditButtonTapped(_ sender: UIButton) { navigateToEditProfile() }

    private func navigateToEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
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

    private func navigateToPTM() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let PTMVC = storyboard.instantiateViewController(withIdentifier: "PTMhomeVC") as? PTMhomeVC {
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

    private func navigateToHomework() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeworkVC = storyboard.instantiateViewController(withIdentifier: "HomeworkVC") as? HomeworkVC {
            homeworkVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(homeworkVC, animated: true)
            } else {
                homeworkVC.modalPresentationStyle = .fullScreen
                present(homeworkVC, animated: true)
            }
        }
    }

    private func navigateToCalendar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalenderVC") as? CalenderVC {
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

    private func navigateToAttendance() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let AttendancedashboardVC = storyboard.instantiateViewController(withIdentifier: "AttendancedashboardVC") as? AttendancedashboardVC {
            AttendancedashboardVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                nav.pushViewController(AttendancedashboardVC, animated: true)
            } else {
                AttendancedashboardVC.modalPresentationStyle = .fullScreen
                present(AttendancedashboardVC, animated: true)
            }
        }
    }

    private func navigateToPortofolio() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let StudentportfolioVC = storyboard.instantiateViewController(withIdentifier: "StudentportfolioVC") as? StudentportfolioVC {
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

    private func navigateToParentfeeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "ParentfeeVC") as? ParentfeeVC {
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
        ContainerView.backgroundColor = UIColor(red: 0/255, green: 92/255, blue: 170/255, alpha: 1)
        ContainerView.layer.cornerRadius = 20
        ContainerView.clipsToBounds = true
    }

    private func createCards() {
        ContainerView.subviews.forEach { $0.removeFromSuperview() }

        let horizontalPadding: CGFloat = 14
        let spacing: CGFloat = 12
        let cardWidth = (ContainerView.frame.width - (horizontalPadding * 2) - spacing) / 2
        let cardHeight: CGFloat = 85
        let totalCardsHeight = (cardHeight * 2) + spacing
        let startY = (ContainerView.frame.height - totalCardsHeight) / 2

        for (index, item) in cardData.enumerated() {
            let row = index / 2
            let column = index % 2
            let x = horizontalPadding + CGFloat(column) * (cardWidth + spacing)
            let y = startY + CGFloat(row) * (cardHeight + spacing)

            let cardView = UIView(frame: CGRect(x: x, y: y, width: cardWidth, height: cardHeight))
            cardView.backgroundColor = UIColor(red: 50/255, green: 115/255, blue: 185/255, alpha: 1)
            cardView.layer.cornerRadius = 18
            cardView.layer.borderWidth = 1
            cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            ContainerView.addSubview(cardView)

            let titleLabel = UILabel(frame: CGRect(x: 14, y: 10, width: cardWidth - 28, height: 15))
            titleLabel.text = item["title"]
            titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
            titleLabel.textColor = UIColor(white: 0.85, alpha: 1)
            cardView.addSubview(titleLabel)

            let valueLabel = UILabel()
            valueLabel.font = UIFont.boldSystemFont(ofSize: 24)
            valueLabel.textColor = .white

            if item["title"] == "FEES" {
                let greenDot = UIView(frame: CGRect(x: 14, y: 40, width: 14, height: 14))
                greenDot.backgroundColor = .systemGreen
                greenDot.layer.cornerRadius = 7
                cardView.addSubview(greenDot)
                valueLabel.frame = CGRect(x: 36, y: 28, width: cardWidth - 40, height: 30)
                valueLabel.text = item["value"]
            } else {
                valueLabel.frame = CGRect(x: 14, y: 32, width: cardWidth - 28, height: 26)
                valueLabel.text = item["value"]
            }
            cardView.addSubview(valueLabel)

            let subtitleLabel = UILabel(frame: CGRect(x: 14, y: 62, width: cardWidth - 28, height: 15))
            subtitleLabel.text = item["subtitle"]
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            subtitleLabel.textColor = .yellow
            cardView.addSubview(subtitleLabel)
        }
    }
}
