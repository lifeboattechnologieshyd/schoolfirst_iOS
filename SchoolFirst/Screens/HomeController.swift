//
//  HomeController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/07/25.
//

import UIKit
import QPassLib
import SwiftUI

enum RowType {
    case modules
    case header
    case calendar
    case homework
    case news(Bulletin)
}

// MARK: - SwiftUI State Object
class HomeState: ObservableObject {
    @Published var promptTitle: String = "Loading..."
    @Published var promptSubtitle: String = "Small habits for a brighter tomorrow."
    @Published var profileImage: UIImage? = nil
    @Published var userProfileUrl: String = ""
    @Published var studentName: String = ""
    @Published var gradeSection: String = ""
    @Published var modules: [FamilyZoneModule] = []
    
    // **** ADDED: Active child dropdown state (same idea as HomeViewModel in School Zone) ****
    @Published var kids: [Student] = []
    @Published var selectedIndex: Int = 0
    @Published var isDropdownOpen: Bool = false
    
    // **** ADDED: Switch active child from the dropdown ****
    func switchKid(to index: Int) {
        guard kids.indices.contains(index) else { return }
        selectedIndex = index
        UserManager.shared.switchKid(to: index)
        
        // Update the Active child card (same format used in setupSwiftUI)
        let kid = kids[index]
        studentName = kid.name
        gradeSection = kid.grade.isEmpty ? "Grade - Section" : "Grade \(kid.grade)"
        
        isDropdownOpen = false
    }
}

// Helper struct for modules (Renamed to FamilyZoneModule to avoid conflict)
struct FamilyZoneModule: Identifiable {
    let id = UUID()
    let title: String
    let image: String
}

class HomeController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var bannerVw: UIView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var calenderimg: UIImageView!
    @IBOutlet weak var lblCalenderPrompt: UILabel!
    
    @IBOutlet weak var lblCalenderTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var heightOfSegment: NSLayoutConstraint!
    
    // MARK: - VARIABLES
    var schoolImages = [
        [
            "Curriculumimage",
            "Assessmentsimage",
            "P-Tipsimage",
            "Calendarimage 1",
            "Feelsimage",
            "VocabBeeimage",
            "Coursesimage",
            "Edutainmentimage",
            "Ed Storeimage",
        ],
        [
            "school_building",
            "news",
            "event",
            "attendence",
            "homework",
            "time_table",
            "fee",
            "school_bus",
            "gallery",
        ]
    ]
    
    var schoolNames = [
        [
            "Curriculum",
            "Assessments",
            "P-Tips",
            "Calendar",
            "Feels",
            "Vocabbees",
            "Courses",
            "Edutainment",
            "Ed Store"
        ],
        [
            "My School",
            "Bulletin",
            "Events",
            "Attendance",
            "Homework",
            "Time Table",
            "Fee",
            "School Bus",
            "Gallery",
         ]
    ]
    
    var dashboard_url = ""
    var banners = [Banner]()
    var homework = [Homework]()
    var calender = [LifeSkillPrompt]()
    var profile_url = ""
    var rows: [RowType] = []
    var hasHomework: Bool = false
    var schooluser: Bool = false
    var newsList: [Bulletin] = []
    
    // SwiftUI State
    var homeState = HomeState()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Hide Segment Control natively
        segmentControl.isHidden = true
        heightOfSegment.constant = 0
        
        if UserManager.shared.selectedSchool == nil {
            schooluser = false
        } else {
            schooluser = true
        }
        
        // Remove School Zone (index 1) to only show Family Zone (index 0)
        schoolNames.removeLast()
        schoolImages.removeLast()

        self.getCalender()
        self.getBanners()
        
        self.colVw.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        colVw.delegate = self
        colVw.dataSource = self
        self.colVw.isScrollEnabled = false
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.colVw.addGestureRecognizer(swipeLeft)
        
        // Embed the new SwiftUI View over the existing UI
        setupSwiftUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - SWIFTUI INTEGRATION
    func setupSwiftUI() {
        homeState.studentName = UserManager.shared.selectedKid?.name ?? "Student Name"
        let grade = UserManager.shared.selectedKid?.grade ?? ""
        homeState.gradeSection = grade.isEmpty ? "Grade - Section" : "Grade \(grade)"
        homeState.userProfileUrl = UserManager.shared.user?.profileImage ?? ""
        
        // **** ADDED: Load kids list + currently selected kid for the Active child dropdown ****
        homeState.kids = UserManager.shared.kids
        if let current = UserManager.shared.selectedKid,
           let idx = homeState.kids.firstIndex(where: { $0.qpass_id == current.qpass_id }) {
            homeState.selectedIndex = idx
        }
        
        // Populate modules safely (Explicitly typed to avoid compiler confusion)
        if let names = schoolNames.first, let images = schoolImages.first {
            let modulesData = zip(names, images).map { (name: String, image: String) -> FamilyZoneModule in
                return FamilyZoneModule(title: name, image: image)
            }
            homeState.modules = modulesData
        }
        
        let swiftUIView = FamilyZoneSwiftUIView(
            state: homeState,
            onModuleTapped: { [weak self] index in
                self?.onSelectItems(index: index, selectedIndex: 0)
            },
            onSchoolZoneTapped: { [weak self] in
                // ✅ Updated to navigate to Homescreen instead of QPass
                self?.navigateToHomescreen()
            },
            onCalendarTapped: { [weak self] in
                self?.navigateToCalendar()
            },
            onProfilePicTapped: { [weak self] in
                self?.showProfilePicOptions()
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
    
    // ✅ NEW: Added navigation function to Homescreen
    func navigateToHomescreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Make sure "Homescreen" is the exact Storyboard ID for your Homescreen View Controller
        if let homescreenVC = storyboard.instantiateViewController(withIdentifier: "Homescreen") as? Homescreen {
            homescreenVC.hidesBottomBarWhenPushed = true
            if let nav = navigationController {
                nav.pushViewController(homescreenVC, animated: true)
            } else {
                homescreenVC.modalPresentationStyle = .fullScreen
                present(homescreenVC, animated: true)
            }
        } else {
            print("❌ Could not instantiate Homescreen. Check storyboard ID.")
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // ✅ Updated to navigate to Homescreen
            self.navigateToHomescreen()
        }
    }
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        let index: Int = sender.selectedSegmentIndex
        if index == 1 {
            // ✅ Updated to navigate to Homescreen
            self.navigateToHomescreen()
            sender.selectedSegmentIndex = 0
            return
        }
        let pageWidth: CGFloat = colVw.bounds.width
        let targetOffsetX: CGFloat = CGFloat(index) * pageWidth
        let maxOffset = colVw.contentSize.width - pageWidth
        let finalOffset = max(0, min(targetOffsetX, maxOffset))
        colVw.setContentOffset(CGPoint(x: finalOffset, y: 0), animated: true)
    }
    
    @IBAction func onClickImage(_ sender: UITapGestureRecognizer) {
        showProfilePicOptions()
    }
    
    func showProfilePicOptions() {
        let alert = UIAlertController(title: "Update Profile Picture", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in self.openCamera() }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func getBanners() {
        showLoader()
        NetworkManager.shared.request(urlString: API.BANNER, method: .GET) { (result: Result<APIResponse<[Banner]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.banners = data
                    }
                }
            case .failure(let error):
                print("⚠️ getBanners silently failed: \(error)")
            }
        }
    }
    
    func getCalender() {
        showLoader()
        self.calender = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayString = dateFormatter.string(from: Date())
        let specificDateUrl = API.BROADCAST_CALENDER + "/" + todayString
        
        NetworkManager.shared.request(urlString: specificDateUrl, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success, let content = info.data?.first {
                    self.hideLoader()
                    DBManager.shared.calender = content
                    DispatchQueue.main.async { self.setupCalendar(content: content) }
                    return
                }
                self.fetchBulkCalendar(todayString: todayString)
            case .failure:
                self.fetchBulkCalendar(todayString: todayString)
            }
        }
    }
    
    private func fetchBulkCalendar(todayString: String) {
        NetworkManager.shared.request(urlString: API.BROADCAST_CALENDER, method: .GET, parameters: ["limit": 400, "page": 1]) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if let data = info.data {
                    self.calender = data
                    if let todaysEntry = data.first(where: { $0.date == todayString }) {
                        DBManager.shared.calender = todaysEntry
                        DispatchQueue.main.async { self.setupCalendar(content: todaysEntry) }
                    } else {
                        self.showHomeFallbackMessage(for: todayString)
                    }
                }
            case .failure:
                self.showHomeFallbackMessage(for: todayString)
            }
        }
    }
    
    private func showHomeFallbackMessage(for dateString: String) {
        let fallbackPrompt = LifeSkillPrompt(
            id: "fallback",
            date: dateString,
            prompt: "Stay tuned! Exciting things are on the horizon at SchoolFirst. Everyday in 2026 brings something extraordinary. See you soon!",
            benefit: "Coming Soon",
            youtubeVideoURL: "",
            description: "We are preparing exciting new activities for you. Check back soon!",
            image: ""
        )
        DBManager.shared.calender = fallbackPrompt
        DispatchQueue.main.async { self.setupCalendar(content: fallbackPrompt) }
    }
    
    func setupCalendar(content: LifeSkillPrompt) {
        // Sync to SwiftUI view
        homeState.promptTitle = content.prompt
        homeState.promptSubtitle = content.description ?? "Small habits for a brighter tomorrow."
        
        // Keep old native bindings safe
        lblCalenderTitle?.text = content.prompt
        if content.id == "fallback" {
            lblCalenderPrompt?.text = content.prompt
        } else {
            lblCalenderPrompt?.text = "Today's Prompt: " + content.prompt
        }
    }
    
    func upload_user_name(image: UIImage){
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            FileUploader.uploadFile(
                urlString: "",
                fileData: imageData,
                fileName: "profile.jpg",
                mimeType: "image/jpeg",
                headers: ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "ACCESSTOKEN")! )"]) { (result: Result<APIResponse<[UploadResponse]>, UploadError>) in
                    switch result {
                    case .success(let info):
                        if info.success {
                            if let data = info.data?.first {
                                self.profile_url = data.fileURL
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        }
    }

    func launchQPass() {
        let domain = "ppsfqpassdev"
        if let student = UserManager.shared.selectedKid,
           let qpassId = student.qpass_id,
           let sessionToken = student.student_access_token {
            QPassManager.shared.launchMFE(domain: domain, authToken: qpassId, sessionToken: sessionToken)
        }
    }
    
    @objc func navigateToCalendar() {
        let vc = storyboard?.instantiateViewController(identifier: "CalendarViewController") as! CalendarViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            userImage?.image = image
            homeState.profileImage = image // Updates SwiftUI View Profile Pic
            self.upload_user_name(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func checkKidsAndNavigate(completion: @escaping () -> Void) {
        let kids = UserManager.shared.kids
        if kids.isEmpty {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                addKidVC.onKidAdded = { [weak self] in completion() }
                self.present(addKidVC, animated: true, completion: nil)
            }
        } else {
            completion()
        }
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.schoolNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.config(name: self.schoolNames[indexPath.row], imageName: self.schoolImages[indexPath.row])
        cell.onSelectModule = { index in
            if self.segmentControl.isHidden {
                self.onSelectItems(index: index, selectedIndex: 0)
            } else {
                self.onSelectItems(index: index, selectedIndex: self.segmentControl.selectedSegmentIndex)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: colVw.frame.size.width, height: colVw.frame.size.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        segmentControl.selectedSegmentIndex = pageIndex
    }
    
    func FamilyZoneItemSelection(index: Int){
        switch index {
        case 0:
            let stbd = UIStoryboard(name: "curriculum", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "CurriculumController") as! CurriculumController
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = storyboard?.instantiateViewController(identifier: "AssessmentsViewController") as! AssessmentsViewController
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let stbd = UIStoryboard(name: "PTips", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "PTipsViewController") as! PTipsViewController
            vc.isEdutain = false
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let stbd = UIStoryboard(name: "Main", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "EdutainmentController") as! EdutainmentController
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let stbd = UIStoryboard(name: "Feels", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "FeelsViewController") as! FeelsViewController
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            let stbd = UIStoryboard(name: "VocabBees", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "VocabBeesViewController") as! VocabBeesViewController
            navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = storyboard?.instantiateViewController(identifier: "CoursesVC") as! CoursesVC
            navigationController?.pushViewController(vc, animated: true)
        case 7:
            let stbd = UIStoryboard(name: "EdStore", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "EdStoreViewController") as! EdStoreViewController
            navigationController?.pushViewController(vc, animated: true)
        case 8:
            let vc = storyboard?.instantiateViewController(identifier: "ComingSoonVC") as! ComingSoonVC
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func onSelectItems(index: Int, selectedIndex: Int) {
        if segmentControl.isHidden {
            self.FamilyZoneItemSelection(index: index)
        } else {
            if selectedIndex == 0 {
                self.FamilyZoneItemSelection(index: index)
            } else {
                switch index {
                case 0:
                    let vc = self.storyboard?.instantiateViewController(identifier: "MySchoolViewController") as! MySchoolViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1:
                    let vc = storyboard?.instantiateViewController(identifier: "BulletinController") as! BulletinController
                    navigationController?.pushViewController(vc, animated: true)
                case 2:
                    let vc = storyboard?.instantiateViewController(identifier: "EventsViewController") as! EventsViewController
                    navigationController?.pushViewController(vc, animated: true)
                case 3:
                    let stbd = UIStoryboard(name: "Attendance", bundle: nil)
                    let vc = stbd.instantiateViewController(identifier: "AttendanceViewController") as! AttendanceViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                case 4:
                    let vc = storyboard?.instantiateViewController(identifier: "HomeworkViewController") as! HomeworkViewController
                    navigationController?.pushViewController(vc, animated: true)
                case 5:
                    let stbd = UIStoryboard(name: "TimeTable", bundle: nil)
                    let vc = stbd.instantiateViewController(identifier: "TimeTableViewController") as! TimeTableViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                case 6:
                    let vc = storyboard?.instantiateViewController(identifier: "FeeViewController") as! FeeViewController
                    navigationController?.pushViewController(vc, animated: true)
                case 7:
                    let vc = storyboard?.instantiateViewController(identifier: "ComingSoonVC") as! ComingSoonVC
                    navigationController?.pushViewController(vc, animated: true)
                case 8:
                    let stbd = UIStoryboard(name: "Gallery", bundle: nil)
                    let vc = stbd.instantiateViewController(identifier: "GalleryViewController") as! GalleryViewController
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
        }
    }
}

// MARK: - SwiftUI View for Family Zone (Matching Figma)
struct FamilyZoneSwiftUIView: View {
    @ObservedObject var state: HomeState
    
    var onModuleTapped: (Int) -> Void
    var onSchoolZoneTapped: () -> Void
    var onCalendarTapped: () -> Void
    var onProfilePicTapped: () -> Void
    
    let figmaBlueHeader = Color(red: 0/255, green: 85/255, blue: 215/255)
    let figmaBgGray = Color(red: 245/255, green: 247/255, blue: 250/255)
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            figmaBgGray.ignoresSafeArea()
            
            // Header Blue Background
            ZStack(alignment: .topTrailing) {
                figmaBlueHeader
                    .frame(height: 250)
                    .ignoresSafeArea(edges: .top)
                
                // **** UPDATED: Yellow circle moved behind the top-right corner of the white board (only its top curve shows, like Figma) ****
                Circle()
                    .fill(Color(red: 255/255, green: 204/255, blue: 51/255))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: 87)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - HEADER
                    HStack(spacing: 14) {
                        // Profile Image
                        Button(action: onProfilePicTapped) {
                            if let profileImg = state.profileImage {
                                Image(uiImage: profileImg)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 52, height: 52)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                AsyncImage(url: URL(string: state.userProfileUrl)) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Connect, explore, and\nstay updated.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        Spacer()
                        
                        // Bell Icon
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                    
                    // MARK: - MAIN WHITE BOARD
                    VStack(spacing: 14) { // **** UPDATED: Tighter spacing between sections like Figma (was 24) ****
                        
                        // 1. Active Child
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active child")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                            
                            // **** UPDATED: Card is now a dropdown – tap to show/hide the students list ****
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation {
                                        state.isDropdownOpen.toggle()
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        if let profileImg = state.profileImage {
                                            Image(uiImage: profileImg).resizable().scaledToFill()
                                                .frame(width: 42, height: 42).clipShape(Circle())
                                        } else {
                                            AsyncImage(url: URL(string: state.userProfileUrl)) { phase in
                                                if let image = phase.image {
                                                    image.resizable().scaledToFill()
                                                } else {
                                                    Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray)
                                                }
                                            }.frame(width: 42, height: 42).clipShape(Circle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(state.studentName)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.black)
                                            Text(state.gradeSection)
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: state.isDropdownOpen ? "chevron.up" : "chevron.down") // **** UPDATED: Arrow flips when open ****
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .padding(14)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // **** ADDED: Students list shown when the dropdown is open ****
                                if state.isDropdownOpen {
                                    kidsDropdownList
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        }
                        
                        // 2. Tabs (Family Zone Active)
                        HStack(spacing: 0) {
                            HStack {
                                Image(systemName: "heart")
                                Text("Family Zone")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0/255, green: 71/255, blue: 212/255))
                            .cornerRadius(20)
                            // **** ADDED: Yellow line at the bottom of the selected segment ****
                            .overlay(alignment: .bottom) {
                                Capsule()
                                    .fill(Color(red: 255/255, green: 204/255, blue: 51/255))
                                    .frame(width: 36, height: 3)
                                    .padding(.bottom, 5)
                            }
                            
                            Button(action: onSchoolZoneTapped) {
                                HStack {
                                    Image(systemName: "building.columns")
                                    Text("School Zone")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(5)
                        .background(Color(red: 238/255, green: 240/255, blue: 244/255))
                        .cornerRadius(24)
                        
                        // 3. DAILY LIFESKILLS Banner
                        Button(action: onCalendarTapped) {
                            ZStack(alignment: .trailing) {
                                Color(red: 255/255, green: 248/255, blue: 220/255) // Pale Yellow
                                    .cornerRadius(20)
                                
                                // **** UPDATED: Banner illustration – add an image named "lifeskills_illustration" in Assets ****
                                Image("Cooking illustration")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 130)
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DAILY LIFESKILLS")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(red: 255/255, green: 193/255, blue: 7/255)) // Gold
                                        .cornerRadius(8)
                                    
                                    Text(state.promptTitle)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(red: 0, green: 30/255, blue: 80/255))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true) // **** ADDED: Lets the title wrap onto 2 lines like Figma ****
                                    
                                    Text(state.promptSubtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    
                                    Text("Try it now")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(red: 0/255, green: 110/255, blue: 255/255))
                                }
                                .padding(20)
                                .padding(.trailing, 140) // **** ADDED: Keeps text clear of the banner image ****
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 165) // **** UPDATED: Taller banner so the 2-line title fits (was 140) ****
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 4. Modules Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Grow together")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Explore \(state.studentName.split(separator: " ").first ?? "your")'s learning world")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Text("View progress")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0/255, green: 71/255, blue: 212/255))
                            }
                        }
                        .padding(.top, 2) // **** UPDATED: Less space above "Grow together" like Figma (was 10) ****
                        
                        // 5. Modules Grid
                        // **** UPDATED: Title now sits INSIDE the white card, below the icon (as per Figma) ****
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(state.modules) { module in
                                Button(action: {
                                    if let index = state.modules.firstIndex(where: { $0.id == module.id }) {
                                        onModuleTapped(index)
                                    }
                                }) {
                                    // ===== WHITE CARD (Icon + Title inside) =====
                                    VStack(spacing: 8) {
                                        // Icon
                                        Image(module.image as String)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 46, height: 46)
                                        
                                        // Title below the icon, inside the card
                                        Text(module.title)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(red: 45/255, green: 45/255, blue: 55/255))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 6)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(red: 225/255, green: 230/255, blue: 240/255), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                                    )
                                    .contentShape(RoundedRectangle(cornerRadius: 16)) // Whole card is tappable
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .background(figmaBgGray)
                    .clipShape(HomeRoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                    .offset(y: -30)
                    .padding(.bottom, -30)
                }
            }
        }
    }
    
    // MARK: - Active Child Dropdown (same design as School Zone)
    
    // **** ADDED: List of students shown under the Active child card ****
    private var kidsDropdownList: some View {
        VStack(spacing: 0) {
            ForEach(Array(state.kids.enumerated()), id: \.offset) { index, kid in
                kidRow(index: index, kid: kid)
                
                if index < state.kids.count - 1 {
                    Divider().padding(.leading, 70)
                }
            }
        }
        .transition(.opacity)
    }
    
    // **** ADDED: Single student row inside the dropdown ****
    @ViewBuilder
    private func kidRow(index: Int, kid: Student) -> some View {
        Button(action: {
            withAnimation {
                state.switchKid(to: index)
            }
        }) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: DBManager.extractPhotoURL(from: kid) ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(kid.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Format as "Grade 5 - Section B" if section exists, or just "Grade 5"
                    Text(kid.section?.isEmpty == false ? "Grade \(kid.grade) - Section \(kid.section!)" : "Grade \(kid.grade)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // Blue Dot for active selection
                if state.selectedIndex == index {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(14)
            .background(state.selectedIndex == index ? Color.blue.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SwiftUI Shape Helper
struct HomeRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
