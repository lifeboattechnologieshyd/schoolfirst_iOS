//
//  AddKidOneCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/11/25.
//


import UIKit

class AddKidOneCell: UITableViewCell {
    
    @IBOutlet weak var gradeTf: UITextField!
    @IBOutlet weak var relationTf: UITextField!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var femaleVw: UIView!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var dateTf: UITextField!
    @IBOutlet weak var addProfileImg: UIButton!
    @IBOutlet weak var notesTv: UITextView!
    @IBOutlet weak var addDate: UIButton!
    @IBOutlet weak var maleVw: UIView!
    @IBOutlet weak var maleButton: UIButton!
    
    private let gradePicker = UIPickerView()
    private let relationPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    // Grades from API
    var gradeList: [Grade] = [] {
        didSet {
            gradePicker.reloadAllComponents()
        }
    }
    
    private let relations = ["son", "daughter"]
    private let relationsDisplay = ["Son", "Daughter"]
    
    // Selected values
    var selectedGradeId: String?
    var selectedRelationType: String?
    var selectedDob: String?
    var selectedImage: UIImage?  // Store selected image
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPickers()
        setupDatePicker()
        setupGenderViews()
        addShadowsToTextFields()
        setupGenderButtons()
        setupProfileImage()
    }
    
    private func setupProfileImage() {
        // Make profile image circular
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.clipsToBounds = true
        profileImg.contentMode = .scaleAspectFill
        
        // Add tap action to button
        addProfileImg.addTarget(self, action: #selector(addProfileImgTapped), for: .touchUpInside)
    }
    
    @objc private func addProfileImgTapped() {
        showImagePickerOptions()
    }
    
    private func showImagePickerOptions() {
        guard let parentVC = self.parentViewController else { return }
        
        let alert = UIAlertController(title: "Select Photo", message: "Choose a photo for profile", preferredStyle: .actionSheet)
        
        // Gallery option
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = addProfileImg
            popover.sourceRect = addProfileImg.bounds
        }
        
        parentVC.present(alert, animated: true)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard let parentVC = self.parentViewController else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = parentVC as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        
        parentVC.present(imagePicker, animated: true)
    }
    
    // Call this from VC when image is selected
    func setProfileImage(_ image: UIImage) {
        selectedImage = image
        profileImg.image = image
    }
    
    // Helper to get parent VC
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let vc = nextResponder as? UIViewController {
                return vc
            }
            responder = nextResponder
        }
        return nil
    }
}

extension AddKidOneCell {
    private func addShadowsToTextFields() {
        [gradeTf, relationTf, nameTf, dateTf, notesTv].forEach {
            $0?.layer.shadowColor = UIColor.black.cgColor
            $0?.layer.shadowOpacity = 0.15
            $0?.layer.shadowRadius = 4
            $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0?.layer.masksToBounds = false
            $0?.backgroundColor = .white
        }
    }
}

extension AddKidOneCell {
    private func setupGenderViews() {
        maleVw.layer.borderWidth = 1.5
        maleVw.layer.cornerRadius = 8
        femaleVw.layer.borderWidth = 1.5
        femaleVw.layer.cornerRadius = 8
        updateGenderSelection(isMale: nil)
    }
    
    private func setupGenderButtons() {
        maleButton.addTarget(self, action: #selector(maleSelected), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleSelected), for: .touchUpInside)
    }
    
    @objc private func maleSelected() {
        updateGenderSelection(isMale: true)
        selectedRelationType = "son"
        relationTf.text = "Son"
    }
    
    @objc private func femaleSelected() {
        updateGenderSelection(isMale: false)
        selectedRelationType = "daughter"
        relationTf.text = "Daughter"
    }
    
    private func updateGenderSelection(isMale: Bool?) {
        let selectedColor = UIColor(red: 0.04, green: 0.34, blue: 0.60, alpha: 1)
        let unselectedColor = UIColor(red: 0.80, green: 0.90, blue: 0.99, alpha: 1)
        
        if let isMale = isMale {
            maleVw.layer.borderColor = isMale ? selectedColor.cgColor : unselectedColor.cgColor
            femaleVw.layer.borderColor = isMale ? unselectedColor.cgColor : selectedColor.cgColor
        } else {
            maleVw.layer.borderColor = unselectedColor.cgColor
            femaleVw.layer.borderColor = unselectedColor.cgColor
        }
    }
}

extension AddKidOneCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    private func setupPickers() {
        gradePicker.delegate = self
        gradePicker.dataSource = self
        relationPicker.delegate = self
        relationPicker.dataSource = self
        
        gradeTf.inputView = gradePicker
        relationTf.inputView = relationPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        gradeTf.inputAccessoryView = toolbar
        relationTf.inputAccessoryView = toolbar
    }
    
    @objc private func doneTapped() {
        gradeTf.resignFirstResponder()
        relationTf.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == gradePicker ? gradeList.count : relationsDisplay.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView == gradePicker ? gradeList[row].name : relationsDisplay[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == gradePicker {
            if row < gradeList.count {
                gradeTf.text = gradeList[row].name
                selectedGradeId = gradeList[row].id
            }
        } else {
            relationTf.text = relationsDisplay[row]
            selectedRelationType = relations[row]
            updateGenderSelection(isMale: row == 0)
        }
    }
}

extension AddKidOneCell {
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        dateTf.isHidden = false
        
        addDate.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dateButtonTapped() {
        showDatePickerAlert()
    }
    
    private func showDatePickerAlert() {
        guard let parentVC = self.parentViewController else { return }
        
        let alert = UIAlertController(title: "Select Date of Birth", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.frame = CGRect(x: 0, y: 50, width: alert.view.bounds.width - 20, height: 200)
        
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            self.dateTf.text = displayFormatter.string(from: datePicker.date)
            self.addDate.setTitle(displayFormatter.string(from: datePicker.date), for: .normal)
            
            let apiFormatter = DateFormatter()
            apiFormatter.dateFormat = "yyyy-MM-dd"
            self.selectedDob = apiFormatter.string(from: datePicker.date)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = addDate
            popover.sourceRect = addDate.bounds
        }
        
        parentVC.present(alert, animated: true)
    }
}
