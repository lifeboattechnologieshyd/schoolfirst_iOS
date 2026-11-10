//
//  Homescreen.swift
//  SchoolFirst
//
//  Created by vamshi krishna
//

import UIKit
import SwiftUI // Added for SwiftUI integration

class Homescreen: UIViewController {

    // MARK: - MODULE DATA
    var modulesData: [[String: String]] = [
        ["title": "Profile", "image": "profileimage"],
        ["title": "Bulletin", "image": "Bulletinimage"],
        ["title": "Homework", "image": "Homeworkimage"],
        ["title": "Fee", "image": "Feeimage"],
        ["title": "Time Table", "image": "Timetableimage"],
        ["title": "Attendance", "image": "Attendanceimage"],
        ["title": "Exams", "image": "Examsimage"],
        ["title": "Gallery", "image": "Galleryimage"],
        ["title": "Transport", "image": "Transportimage"],
        ["title": "Calendar", "image": "Calendarimage"],
        ["title": "Remarks", "image": "Remarksimage"],
        ["title": "Contact us", "image": "Contact Us image"],
        ["title": "Events", "image": "Eventsimage"],
        ["title": "PTM", "image": "PTMimage 1"],
        ["title": "Portofolio", "image": "Portofolioimg"],
        ["title": "Feedback", "image": "Feedbackimage 1"]
    ]

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - SWIFTUI INTEGRATION
    private func setupSwiftUI() {
        // Convert dictionary to SwiftUI models
        let appModules = modulesData.compactMap { dict -> AppModule? in
            guard let title = dict["title"], let image = dict["image"] else { return nil }
            return AppModule(title: title, image: image)
        }
        
        // ✅ NEW: Initialize ViewModel
        let viewModel = HomeViewModel()
        
        let swiftUIView = HomeScreenSwiftUIView(
            viewModel: viewModel, // Passed ViewModel
            modules: appModules,
            onModuleTapped: { [weak self] moduleTitle in
                self?.handleModuleSelection(title: moduleTitle)
            },
            onFamilyZoneTapped: { [weak self] in
                // ✅ Navigate back to HomeController when Family Zone is tapped
                self?.navigateBackToHomeController()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }

    // MARK: - NAVIGATION TO FAMILY ZONE
    private func navigateBackToHomeController() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - MODULE ROUTING
    private func handleModuleSelection(title: String) {
        switch title {
        case "Profile": navigateToStudentProfile()
        case "Calendar": navigateToCalendar()
        case "PTM": navigateToPTM()
        case "Fee": navigateToParentfeeVC()
        case "Homework": navigateToHomework()
        case "Portofolio": navigateToPortofolio()
        case "Feedback": navigateToFeedback()
        case "Gallery": navigateToGallery()
        case "Remarks": navigateToRemarks()
        case "Contact us": navigateToContactus()
        case "Bulletin": navigateToBulletin()
        case "Exams": navigateToExams()
        case "Time Table": navigateToTimetable()
        case "Events": navigateToEvents()
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
        print("👨‍🎓 Student ID: \(studentId)")
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

    private func showTransportNotOptedVC() {
        print("🔥 TRANSPORT NOT OPTED NAVIGATION STARTED")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: TransportnotoptedVC
        if let sbVC = storyboard.instantiateViewController(
            withIdentifier: "TransportnotoptedVC"
        ) as? TransportnotoptedVC {
            vc = sbVC
        } else {
            vc = TransportnotoptedVC()
        }
        pushNotOptedVC(vc)
    }

    private func pushNotOptedVC(_ vc: TransportnotoptedVC) {
        vc.hidesBottomBarWhenPushed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }

            let doPush = { [weak self] in
                guard let self = self else { return }
                if let nav = self.navigationController {
                    nav.setNavigationBarHidden(true, animated: false)
                    nav.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }

            let blocker = self.presentedViewController ?? self.navigationController?.presentedViewController

            if let blocker = blocker {
                blocker.dismiss(animated: false, completion: doPush)
            } else {
                doPush()
            }
        }
    }

    private func navigateToTransportViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideLoader()

            guard let nav = self.navigationController else {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
                return
            }

            if nav.topViewController === viewController { return }

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
        }
    }

    // MARK: - NAVIGATION HELPERS

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
   
    private func navigateToPTM() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let PTMVC = storyboard.instantiateViewController(withIdentifier: "PTMhomeVC") as? PTMhomeVC {
            PTMVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(PTMVC, animated: true)
            } else {
                PTMVC.modalPresentationStyle = .fullScreen
                present(PTMVC, animated: true)
            }
        }
    }
    
    private func navigateToBulletin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let Bulletin = storyboard.instantiateViewController(withIdentifier: "BulletinlistVC") as? BulletinlistVC {
            Bulletin.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(Bulletin, animated: true)
            } else {
                Bulletin.modalPresentationStyle = .fullScreen
                present(Bulletin, animated: true)
            }
        }
    }

    private func navigateToHomework() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeworkVC = storyboard.instantiateViewController(withIdentifier: "HomeworkVC") as? HomeworkVC {
            homeworkVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(homeworkVC, animated: true)
            } else {
                homeworkVC.modalPresentationStyle = .fullScreen
                present(homeworkVC, animated: true)
            }
        }
    }
    
    private func navigateToFeedback() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let FeedbackVC = storyboard.instantiateViewController(withIdentifier: "FeedbackoverviewVC") as? FeedbackoverviewVC {
            FeedbackVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(FeedbackVC, animated: true)
            } else {
                FeedbackVC.modalPresentationStyle = .fullScreen
                present(FeedbackVC, animated: true)
            }
        }
    }

    private func navigateToCalendar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalenderVC") as? CalenderVC {
            calendarVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(calendarVC, animated: true)
            } else {
                calendarVC.modalPresentationStyle = .fullScreen
                present(calendarVC, animated: true)
            }
        }
    }

    private func navigateToAttendance() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let AttendancedashboardVC = storyboard.instantiateViewController(withIdentifier: "StudentAttendanceDashboardVC") as? attendancedashboardVC {
            AttendancedashboardVC.studentNameAndGradeInfo = "\(UserManager.shared.resolvedStudentName) | \(UserManager.shared.resolvedGradeSection)"
            AttendancedashboardVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
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
                nav.pushViewController(StudentportfolioVC, animated: true)
            } else {
                StudentportfolioVC.modalPresentationStyle = .fullScreen
                present(StudentportfolioVC, animated: true)
            }
        }
    }

    private func navigateToParentfeeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "FeedashboardVC") as? FeedashboardVC {
            paymentVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(paymentVC, animated: true)
            } else {
                paymentVC.modalPresentationStyle = .fullScreen
                present(paymentVC, animated: true)
            }
        }
    }

    private func navigateToGallery() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let galleryVC = storyboard.instantiateViewController(withIdentifier: "GalleryhomeVC") as? GalleryhomeVC {
            galleryVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(galleryVC, animated: true)
            } else {
                galleryVC.modalPresentationStyle = .fullScreen
                present(galleryVC, animated: true)
            }
        }
    }
    
    private func navigateToRemarks() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let RemarksVC = storyboard.instantiateViewController(withIdentifier: "RemarksVC") as? RemarksVC {
            RemarksVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(RemarksVC, animated: true)
            } else {
                RemarksVC.modalPresentationStyle = .fullScreen
                present(RemarksVC, animated: true)
            }
        }
    }
    
    private func navigateToExams() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let ExamVC = storyboard.instantiateViewController(withIdentifier: "ExamhomeVC") as? ExamhomeVC {
            ExamVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(ExamVC, animated: true)
            } else {
                ExamVC.modalPresentationStyle = .fullScreen
                present(ExamVC, animated: true)
            }
        }
    }
    
    private func navigateToTimetable() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let TimetableVC = storyboard.instantiateViewController(withIdentifier: "TodaytimetableVC") as? TodaytimetableVC {
            TimetableVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(TimetableVC, animated: true)
            } else {
                TimetableVC.modalPresentationStyle = .fullScreen
                present(TimetableVC, animated: true)
            }
        }
    }
    
    private func navigateToContactus() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let Contactus = storyboard.instantiateViewController(withIdentifier: "ContactschooldashboardVC") as? ContactschooldashboardVC {
            Contactus.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(Contactus, animated: true)
            } else {
                Contactus.modalPresentationStyle = .fullScreen
                present(Contactus, animated: true)
            }
        }
    }
    
    private func navigateToEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let Events = storyboard.instantiateViewController(withIdentifier: "EventsdashboardVC") as? EventsdashboardVC {
            Events.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(Events, animated: true)
            } else {
                Events.modalPresentationStyle = .fullScreen
                present(Events, animated: true)
            }
        }
    }
}
