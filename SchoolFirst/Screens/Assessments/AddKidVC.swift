//
//  AddKidVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/11/25.
//

import UIKit

class AddKidVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var addkidButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    private var addKidCell: AddKidOneCell?
    private var gradeList: [Grade] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "AddKidOneCell", bundle: nil), forCellReuseIdentifier: "AddKidOneCell")
        tblVw.rowHeight = 740
        
        fetchGrades()
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickAddKid(_ sender: UIButton) {
        addStudent()
    }
    
    private func fetchGrades() {
        NetworkManager.shared.request(
            urlString: API.GRADES_LIST,
            method: .GET
        ) { (result: Result<APIResponse<[Grade]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let grades = response.data {
                        print("✅ Grades fetched: \(grades.count)")
                        self.gradeList = grades
                        self.addKidCell?.gradeList = grades
                    } else {
                        self.showAlert(msg: response.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(msg: "Failed to fetch grades: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addStudent() {
        
        guard let cell = addKidCell else { return }
        
        // Validate
        guard let gradeId = cell.selectedGradeId, !gradeId.isEmpty else {
            showAlert(msg: "Please select a grade")
            return
        }
        
        guard let studentName = cell.nameTf.text?.trimmingCharacters(in: .whitespaces), !studentName.isEmpty else {
            showAlert(msg: "Please enter student name")
            return
        }
        
        guard let relationType = cell.selectedRelationType, !relationType.isEmpty else {
            showAlert(msg: "Please select Son or Daughter")
            return
        }
        
        guard let dob = cell.selectedDob, !dob.isEmpty else {
            showAlert(msg: "Please select date of birth")
            return
        }
        
        // Get notes
        let notesText = cell.notesTv.text ?? ""
        var notesArray: [String] = []
        if !notesText.trimmingCharacters(in: .whitespaces).isEmpty {
            notesArray = notesText.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        
        // Payload
        var payload: [String: Any] = [
            "grade_id": gradeId,
            "student_name": studentName,
            "relation_type": relationType,
            "dob": dob,
            "notes": notesArray,
            "status": "Active"
        ]
        
         
        NetworkManager.shared.request(
            urlString: API.ADD_STUDENT,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<StudentUpdateResponse>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        print("✅ Student added: \(data.studentName)")
                        self.showSuccessAndGoBack()
                    } else {
                        self.showAlert(msg: response.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(msg: "Failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessAndGoBack() {
        let alert = UIAlertController(title: "Success", message: "Kid added successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(msg: "This feature is not available on your device")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

extension AddKidVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddKidOneCell", for: indexPath) as! AddKidOneCell
        cell.gradeList = gradeList
        self.addKidCell = cell
        return cell
    }
}

extension AddKidVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        // Get edited or original image
        if let editedImage = info[.editedImage] as? UIImage {
            addKidCell?.setProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            addKidCell?.setProfileImage(originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
