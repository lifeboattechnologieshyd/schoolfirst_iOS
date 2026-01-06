//
//  ReSubmitViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 01/11/25.
//

import UIKit

class ReSubmitViewController: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var leaveVw: UIView!
    @IBOutlet weak var leavedateLBl: UILabel!
    @IBOutlet weak var leavedaysLbl: UILabel!
    @IBOutlet weak var remarksLbl: UILabel!
    @IBOutlet weak var studentImg: UIImageView!
    @IBOutlet weak var reasonsButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var rejectedVw: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var totalDaysLbl: UILabel!
    @IBOutlet weak var submitVw: UIView!
    @IBOutlet weak var abhiVw: UIView!
    @IBOutlet weak var detailTv: UITextView!
    @IBOutlet weak var reasonsTf: UITextField!
    
    var leaveData: LeaveHistoryData!
    
    let issueReasons = [
        "Fever / Health Issue",
        "Family Function",
        "Emergency Situation",
        "Travel",
        "Other"
    ]
    
    var reasonPickerView = UIPickerView()
    var selectedReason: String = ""
    var selectedImage: UIImage?
    var selectedImageName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaveVw.addCardShadow()
        reasonsTf.addCardShadow()
        detailTv.addCardShadow()
        topVw.addBottomShadow()
        bottomVw.addTopShadow()
        
        setupUI()
        setupReasonPicker()
        setupTextView()
        populateLeaveData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        submitVw.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
        addDashedBorder(to: submitVw, color: UIColor(red: 157/255, green: 168/255, blue: 181/255, alpha: 1), lineWidth: 1, dashPattern: [5, 5])
    }
    
    private func setupUI() {
        addDashedBorder(to: submitVw, color: UIColor(red: 157/255, green: 168/255, blue: 181/255, alpha: 1), lineWidth: 1, dashPattern: [5, 5])
        submitVw.layer.cornerRadius = 8
        submitVw.layer.masksToBounds = true
        
        reasonsTf.tintColor = .clear
    }
    
    private func setupTextView() {
        detailTv.delegate = self
        detailTv.text = "Enter additional details..."
        detailTv.textColor = .lightGray
    }
    
    private func populateLeaveData() {
        guard let leave = leaveData else {
            print("❌ Leave data is nil")
            return
        }
        
        // ✅ Get student info from UserManager using studentId
        if let student = UserManager.shared.kids.first(where: { $0.studentID == leave.studentId }) {
            
            // ✅ Using correct property names from Student model
            studentNameLbl.text = student.name
            gradeLbl.text = student.grade
            
            // Load student image
            if let imageUrlString = student.image,
               !imageUrlString.isEmpty,
               let imageUrl = URL(string: imageUrlString) {
                loadImage(from: imageUrl, into: studentImg)
            } else {
                studentImg.image = UIImage(named: "placeholder_student")
            }
            
        } else {
            // Fallback if student not found
            studentNameLbl.text = "Student"
            gradeLbl.text = ""
            studentImg.image = UIImage(named: "placeholder_student")
        }
        
        leavedateLBl?.text = leave.formattedDateRange
        dateLbl?.text = leave.formattedDateRange
        
        // Leave Days (e.g., "1 Day", "2 Days")
        leavedaysLbl?.text = leave.formattedTotalDays
        totalDaysLbl?.text = leave.formattedTotalDays
        
        // Teacher Remarks
        if let remarks = leave.teacherRemarks, !remarks.isEmpty {
            remarksLbl?.text = remarks
            remarksLbl?.isHidden = false
        } else {
            remarksLbl?.isHidden = true
        }
        
        // Previous Reason - Pre-fill in text field
        if !leave.reason.isEmpty {
            reasonsTf.text = leave.reason
            selectedReason = leave.reason
        } else if !leave.reasonType.isEmpty {
            reasonsTf.text = leave.reasonType
            selectedReason = leave.reasonType
        }
        
        print("✅ Leave data populated - ID: \(leave.id)")
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
    
    private func setupReasonPicker() {
        reasonPickerView.delegate = self
        reasonPickerView.dataSource = self
        
        reasonsTf.inputView = reasonPickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = .white
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(reasonPickerDoneTapped))
        doneButton.tintColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(reasonPickerCancelTapped))
        cancelButton.tintColor = .gray
        
        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
        reasonsTf.inputAccessoryView = toolbar
    }
    
    @objc private func reasonPickerDoneTapped() {
        let selectedRow = reasonPickerView.selectedRow(inComponent: 0)
        selectedReason = issueReasons[selectedRow]
        reasonsTf.text = selectedReason
        reasonsTf.resignFirstResponder()
    }
    
    @objc private func reasonPickerCancelTapped() {
        reasonsTf.resignFirstResponder()
    }
    
    private func addDashedBorder(to view: UIView, color: UIColor, lineWidth: CGFloat, dashPattern: [NSNumber]) {
        let dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = color.cgColor
        dashedBorder.lineDashPattern = dashPattern
        dashedBorder.lineWidth = lineWidth
        dashedBorder.fillColor = nil
        dashedBorder.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        dashedBorder.frame = view.bounds
        view.layer.addSublayer(dashedBorder)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reasonsButtonTapped(_ sender: UIButton) {
        reasonsTf.becomeFirstResponder()
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        showImagePickerOptions()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        updateLeaveRequest()
    }
    
    private func showImagePickerOptions() {
        let alertController = UIAlertController(title: "Select Document", message: "Choose an option to upload document", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        alertController.addAction(galleryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = uploadButton
            popover.sourceRect = uploadButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateLeaveRequest() {
        
        guard let leave = leaveData else {
            showAlert(msg: "Leave data not found")
            return
        }
        
        guard !selectedReason.isEmpty else {
            showAlert(msg: "Please select a reason")
            return
        }
        
        
        // ✅ Using leaveData.id for API URL
        let url = API.BASE_URL + "attendance/leave/\(leave.id)"
        
        // Build final reason with additional details
        var finalReason = selectedReason
        if let detailText = detailTv.text,
           !detailText.isEmpty,
           detailText != "Enter additional details..." {
            finalReason = selectedReason + " - " + detailText
        }
        
        var parameters: [String: Any] = [
            "reason": finalReason
        ]
        
        if !selectedImageName.isEmpty {
            parameters["document"] = selectedImageName
        }
        
        print("📤 API URL: \(url)")
        print("📤 Parameters: \(parameters)")
        
        NetworkManager.shared.request(urlString: url, method: .PUT, parameters: parameters) { (result: Result<APIResponse<LeaveUpdateResponse>, NetworkError>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAlert(message: response.description)
                    } else {
                        self.showAlert(msg: response.description)
                    }
                    
                case .failure(let error):
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
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "✅ Success", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
  
    }


extension ReSubmitViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issueReasons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issueReasons[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedReason = issueReasons[row]
        reasonsTf.text = selectedReason
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = issueReasons[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        return label
    }
}

extension ReSubmitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let imageURL = info[.imageURL] as? URL {
            selectedImageName = imageURL.lastPathComponent
        } else {
            let timestamp = Int(Date().timeIntervalSince1970)
            selectedImageName = "document_\(timestamp).jpg"
        }
        
        updateUploadUI()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func updateUploadUI() {
        if selectedImage != nil {
            uploadButton.setTitle("📎 \(selectedImageName)", for: .normal)
            submitVw.backgroundColor = UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1)
        }
    }
}

extension ReSubmitViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter additional details..."
            textView.textColor = .lightGray
        }
    }
}
