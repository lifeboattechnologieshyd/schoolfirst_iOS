//
//  HomeController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/07/25.
//

import UIKit

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
    @IBOutlet weak var lblCalenderPrompt: UILabel!
    
    @IBOutlet weak var lblCalenderTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    
    
    var schoolImages = [
        [
            "curriculum",
            "news",
            "Ptips",
            "Edutainmentt",
            "Feels",
            "Vocabbees",
            "online-course",
            "EdStore",
            "student",
        ],
        [
            "curriculum",
            "assessments",
            "Ptips",
            "Edutainmentt",
            "Feels",
            "Vocabbees",
            "online-course",
            "EdStore",
            "student",
        ]
    ]
    
    var schoolNames = [
        [
            "My School",
            "Bulletin",
            "Events",
            "Homework",
            "Fee",
            "Gallery",
            "Attendance",
            "Time Table",
            "School Bus"
        ],
        [
            "Curriculum",
            "Assessments",
            "P-Tips",
            "Edutainment",
            "Feels",
            "Vocabbees",
            "Courses",
            "Ed Store",
            "Child Profile"
        ]
    ]
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserManager.shared.user?.schools.count == 0 {
            schooluser = false
        }else{
            schooluser = true
        }
        segmentControl.isHidden = !schooluser
        if !schooluser {
            schoolNames.removeFirst()
            schoolImages.removeFirst()
        }
        self.getCalender()
        self.getBanners()
        self.segmentControl.applyCustomStyle()
        self.logoImage.loadImage(url: UserManager.shared.user?.schools.first?.fullLogo ?? "", placeHolderImage: "")
        self.colVw.register(UINib(nibName: "HomeViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeViewCell")
        self.colVw.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        
        let index: Int = sender.selectedSegmentIndex
        let pageWidth: CGFloat = colVw.bounds.width
        let targetOffsetX: CGFloat = CGFloat(index) * pageWidth
        
        // clamp offset
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
        NetworkManager.shared.request(urlString: API.BANNER,method: .GET) { (result: Result<APIResponse<[Banner]>, NetworkError>)  in
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
        self.calender = []
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY"
        let start_date = dateFormatter.string(from: today)
        
        NetworkManager.shared.request(urlString: API.BROADCAST_CALENDER+start_date, method: .GET) { (result: Result<APIResponse<[LifeSkillPrompt]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.calender = data
                        if self.calender.count > 0 {
                            DBManager.shared.calender = self.calender[0]
                            DispatchQueue.main.async {
                                self.setupCalendar(content: self.calender[0])
                            }
                        }
                    }
                    
                }else{
                    print(info.description)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
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
        lblCalenderPrompt.text = "Today's Prompt :" + content.prompt
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
        NetworkManager.shared.request(urlString: API.DASHBOARD,method: .GET) { (result: Result<APIResponse<DashboardResponse>, NetworkError>)  in
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
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.schoolNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.config(name: self.schoolNames[indexPath.row], imageName: self.schoolImages[indexPath.row])
        cell.onSelectModule = { index in
            self.onSelectItems(index: index, selectedIndex: self.segmentControl.selectedSegmentIndex)
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
    
    func onSelectItems(index: Int, selectedIndex: Int){
        if selectedIndex == 0 {
            switch index {
            case 0:
                let vc = storyboard?.instantiateViewController(identifier: "MySchoolViewController") as? MySchoolViewController
                navigationController?.pushViewController(vc!, animated: true)
            case 1:
                let vc = storyboard?.instantiateViewController(identifier: "BulletinController") as? BulletinController
                navigationController?.pushViewController(vc!, animated: true)
            case 2:
                let vc = storyboard?.instantiateViewController(identifier: "EventsViewController") as? EventsViewController
                navigationController?.pushViewController(vc!, animated: true)
            case 3:
                print("homework")
                let vc = storyboard?.instantiateViewController(identifier: "HomeworkViewController") as? HomeworkViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            case 4:
                //            let vc = storyboard?.instantiateViewController(identifier: "HomeworkViewController") as? HomeworkViewController
                //            vc?.screen_title = "School Fee"
                let vc = storyboard?.instantiateViewController(identifier: "FeeViewController") as? FeeViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            case 5:
                let vc = storyboard?.instantiateViewController(identifier: "MySchoolViewController") as? MySchoolViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            default:
                let vc = storyboard?.instantiateViewController(identifier: "HomeworkViewController") as? HomeworkViewController
                vc?.screen_title = ""
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }else{
            switch index {
            case 0:
                print("Curicullum")
            case 1:
                let vc = storyboard?.instantiateViewController(identifier: "AssessmentsViewController") as? AssessmentsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            case 2:
                print("P-tips")
                var stbd = UIStoryboard(name: "PTips", bundle: nil)
                let vc = stbd.instantiateViewController(identifier: "PTipsViewController") as? PTipsViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            case 3:
                print("Edutainment")
            case 4:
                print("Feels")
            case 5:
                print("Vocabees")
            default:
                print("Courses")
            }
        }
        
    }
}
