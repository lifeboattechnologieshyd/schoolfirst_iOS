//
//  HomeController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/07/25.
//

import UIKit
import QPassLib

enum RowType {
    case modules
    case header
    case calendar
    case homework
    case news(Bulletin)
}

class HomeController: UIViewController {
    
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
    
    
    var schoolImages = [
        [
            "curriculum",
            "assessments",
            "Ptips",
            "Edutainmentt",
            "Feels",
            "Vocabbees",
            "online-course",
            "EdStore",
            "ask_us",
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
            "Edutainment",
            "Feels",
            "Vocabbees",
            "Courses",
            "Ed Store",
            "Ask Us"
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
    @IBOutlet weak var userImage: UIImageView!
//    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    
    var dashboard_url = ""
    var banners = [Banner]()
    var homework = [Homework]()
    var calender = [LifeSkillPrompt]()
    var profile_url = ""
    var rows: [RowType] = []
    var hasHomework: Bool = false
    var schooluser: Bool = false
    var newsList: [Bulletin] = []
    
    @IBOutlet weak var heightOfSegment: NSLayoutConstraint!
    override func viewDidLoad(){
        super.viewDidLoad()
        logoImg.addFourSideShadow(
            color: .black,
            opacity: 0.3,
            radius: 8
        )
        bannerVw.addFourSideShadow(color: .black,opacity: 0.3,radius: 8)
        calenderimg.addFourSideShadow(color: .black,opacity: 0.3,radius: 8)
        calenderimg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(navigateToCalendar))
        calenderimg.addGestureRecognizer(tap)
//        userImage.loadImage(url: UserManager.shared.user?.profileImage ?? "", placeHolderImage: "dummy_kid_profile_pic")

        titleLbl.applyOutlineWithBottomShadow(
                textColor: UIColor(hex: "#23B915"),   // Green fill
                outlineColor: .white,                 // White outline
                outlineWidth: 1,                      // Adjust if needed
                shadowOpacity: 0.1,
                shadowOffset: CGSize(width: 1, height: 1)
            )

        // Always hide segment control and move collection view up
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
        
        // Disable manual scrolling as requested
        self.colVw.isScrollEnabled = false
        
        // Add swipe gesture to trigger School Zone SDK
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.colVw.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            self.launchQPass()
        }
    }
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        let index: Int = sender.selectedSegmentIndex
        
        if index == 1 {
            // Immediately launch SDK and reset segment
            self.launchQPass()
            sender.selectedSegmentIndex = 0
            return
        }
        
        // Standard scrolling only for other indices (if any)
        let pageWidth: CGFloat = colVw.bounds.width
        let targetOffsetX: CGFloat = CGFloat(index) * pageWidth
        let maxOffset = colVw.contentSize.width - pageWidth
        let finalOffset = max(0, min(targetOffsetX, maxOffset))
        colVw.setContentOffset(CGPoint(x: finalOffset, y: 0), animated: true)
    }
    
    @IBAction func onClickImage(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Update Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openGallery()
        }))
        
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
        } else {
            print("Camera not available")
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
        NetworkManager.shared.request(urlString: API.BANNER,method: .GET) { (result: Result<APIResponse<[Banner]>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.banners = data
                    }
                    DispatchQueue.main.async {
                        self.imgVw.loadImage(url: self.banners.first?.image ?? "")
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    
    func getCalender() {
        showLoader()
        self.calender = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayString = dateFormatter.string(from: Date())
        
        // Try the specific date endpoint first as suggested (broadcast/calendar/dd-MM-yyyy)
        let specificDateUrl = API.BROADCAST_CALENDER + "/" + todayString
        
        NetworkManager.shared.request(urlString: specificDateUrl, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>) in
            switch result {
            case .success(let info):
                if info.success, let content = info.data?.first {
                    self.hideLoader()
                    DBManager.shared.calender = content
                    DispatchQueue.main.async {
                        self.setupCalendar(content: content)
                    }
                    return // Success with specific date, exit early
                }
                // If specific date fails or returns no data, fall back to bulk fetch
                self.fetchBulkCalendar(todayString: todayString)
                
            case .failure:
                // Fallback to bulk fetch if the specific endpoint fails
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
                    // Find today's entry
                    if let todaysEntry = data.first(where: { $0.date == todayString }) {
                        DBManager.shared.calender = todaysEntry
                        DispatchQueue.main.async {
                            self.setupCalendar(content: todaysEntry)
                        }
                    } else {
                        // Today's entry not found, show the "Stay Tuned" fallback message
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
        DispatchQueue.main.async {
            self.setupCalendar(content: fallbackPrompt)
        }
    }
    func setupCalendar(content: LifeSkillPrompt){
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        if let date = inputFormatter.date(from: content.date) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            let day = dayFormatter.string(from: date)
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            let month = monthFormatter.string(from: date)
            lblDate.text = "\(day)"
            lblMonth.text = "\(month)"
        }
        lblCalenderTitle.text = content.prompt
        if content.id == "fallback" {
            lblCalenderPrompt.text = content.prompt
        } else {
            lblCalenderPrompt.text = "Today's Prompt: " + content.prompt
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
                            print("courses fetched")
                            if let data = info.data?.first {
                                self.profile_url = data.fileURL
                            }
                        }else{
                            print(info.description)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
        }
    }
    
    
    func getRawData(){
        showLoader()
        NetworkManager.shared.request(urlString: API.DASHBOARD,method: .GET) { (result: Result<APIResponse<DashboardResponse>, NetworkError>)  in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        
                    }
                    
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }

    func launchQPass() {
        let domain = "ppsfqpassdev"
        
        if let student = UserManager.shared.selectedKid,
           let qpassId = student.qpass_id,
           let sessionToken = student.student_access_token {
            
            print("🚀 Launching SDK for \(student.name)")
            QPassManager.shared.launchMFE(
                domain: domain,
                authToken: qpassId,
                sessionToken: sessionToken
            )
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
            userImage.image = image
            self.upload_user_name(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK:  Helper Function to Check Kids
    func checkKidsAndNavigate(completion: @escaping () -> Void) {
        let kids = UserManager.shared.kids
        
        if kids.isEmpty {
            // No kids - Show AddKidVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                
                // When kid is added successfully, execute the completion
                addKidVC.onKidAdded = { [weak self] in
                    completion()
                }
                
                self.present(addKidVC, animated: true, completion: nil)
            }
        } else {
            // Has kids - Continue with navigation
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
            }else{
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
            // vc.isEdutain = true
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let stbd = UIStoryboard(name: "Feels", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "FeelsViewController") as! FeelsViewController
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            print("Vocabbees")
            let stbd = UIStoryboard(name: "VocabBees", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "VocabBeesViewController") as! VocabBeesViewController
            navigationController?.pushViewController(vc, animated: true)
        case 6:
            print("Courses")
            let vc = storyboard?.instantiateViewController(identifier: "CoursesVC") as! CoursesVC
            navigationController?.pushViewController(vc, animated: true)
        case 7:
            print("EdStore")
            let stbd = UIStoryboard(name: "EdStore", bundle: nil)
            let vc = stbd.instantiateViewController(identifier: "EdStoreViewController") as! EdStoreViewController
            navigationController?.pushViewController(vc, animated: true)
        case 8:
            print("Ask Us")
            let vc = storyboard?.instantiateViewController(identifier: "ComingSoonVC") as! ComingSoonVC
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("Courses")
        }
    }
    
    func onSelectItems(index: Int, selectedIndex: Int) {
        if segmentControl.isHidden {
            self.FamilyZoneItemSelection(index: index)
        } else {
            if selectedIndex == 0 {
                // Now ItemSelection is for Family Zone on Index 0
                self.FamilyZoneItemSelection(index: index)
            } else {
                // School logic moved to Index 1
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
                    print("School Bus")
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
