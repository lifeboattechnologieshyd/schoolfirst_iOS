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
    
    var gradeList: [Grade] = [] {
        didSet {
            gradePicker.reloadAllComponents()
        }
    }
    
    private let relations = ["son", "daughter"]
    private let relationsDisplay = ["Son", "Daughter"]
    
    var selectedGradeId: String?
    var selectedRelationType: String?
    var selectedDob: String?
    var selectedImage: UIImage?
    
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
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.clipsToBounds = true
        profileImg.contentMode = .scaleAspectFill
        
        addProfileImg.addTarget(self, action: #selector(addProfileImgTapped), for: .touchUpInside)
    }
    
    @objc private func addProfileImgTapped() {
        showImagePickerOptions()
    }
    
    private func showImagePickerOptions() {
        guard let parentVC = self.parentViewController else { return }
        
        let alert = UIAlertController(title: "Select Photo", message: "Choose a photo for profile", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
    
    func setProfileImage(_ image: UIImage) {
        selectedImage = image
        profileImg.image = image
    }
    
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
        
        // Toolbar for Grade
        let gradeToolbar = UIToolbar()
        gradeToolbar.sizeToFit()
        let gradeDoneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(gradeDoneTapped))
        let gradeFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        gradeToolbar.setItems([gradeFlexSpace, gradeDoneBtn], animated: true)
        gradeTf.inputAccessoryView = gradeToolbar
        
        // Toolbar for Relation
        let relationToolbar = UIToolbar()
        relationToolbar.sizeToFit()
        let relationDoneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(relationDoneTapped))
        let relationFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        relationToolbar.setItems([relationFlexSpace, relationDoneBtn], animated: true)
        relationTf.inputAccessoryView = relationToolbar
    }
    
    @objc private func gradeDoneTapped() {
        // Auto-select first item if nothing selected
        if selectedGradeId == nil && !gradeList.isEmpty {
            let row = gradePicker.selectedRow(inComponent: 0)
            if row < gradeList.count {
                gradeTf.text = gradeList[row].name
                selectedGradeId = gradeList[row].id
            }
        }
        gradeTf.resignFirstResponder()
    }
    
    @objc private func relationDoneTapped() {
        // Auto-select first item if nothing selected
        if selectedRelationType == nil {
            let row = relationPicker.selectedRow(inComponent: 0)
            relationTf.text = relationsDisplay[row]
            selectedRelationType = relations[row]
            updateGenderSelection(isMale: row == 0)
        }
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
        // Configure date picker
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        // Set wheels style for consistency across iOS versions
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        // IMPORTANT: Enable user interaction and make it editable
        dateTf.isUserInteractionEnabled = true
        dateTf.isEnabled = true
        
        // Set date picker as input view for text field
        dateTf.inputView = datePicker
        
        // Create toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dateDoneTapped))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        dateTf.inputAccessoryView = toolbar
        
        // Handle button tap to show picker
        addDate.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func dateButtonTapped() {
            DispatchQueue.main.async {
            self.dateTf.becomeFirstResponder()
        }
    }
    
    @objc private func dateDoneTapped() {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        
        let dateString = displayFormatter.string(from: datePicker.date)
//        dateTf.text = dateString
        addDate.setTitle(dateString, for: .normal)
        
        let apiFormatter = DateFormatter()
        apiFormatter.dateFormat = "yyyy-MM-dd"
        selectedDob = apiFormatter.string(from: datePicker.date)
        
        dateTf.resignFirstResponder()
    }
}
