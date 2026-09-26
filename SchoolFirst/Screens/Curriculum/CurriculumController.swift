//
//  CurriculumController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblNoKids: UILabel!
    
    var selected_student = 0
    var types = [Curriculum]()
    var allGrades: [Grade] = []
    var isGradesLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        
        removeKidSelection()
        
        getCurriculumType()
        getGradesList()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = .white
        tblVw.separatorStyle = .none
        
        tblVw.reloadData()
    }
    
    // MARK: - Remove Kid Selection UI (collapse storyboard collection view)
    private func removeKidSelection() {
        guard let colVw = colVw else { return }
        
        colVw.isHidden = true
        colVw.dataSource = nil
        colVw.delegate = nil
        
        // Collapse any existing height constraint on the collection view
        var foundHeight = false
        for c in colVw.constraints where c.firstAttribute == .height && c.firstItem === colVw {
            c.constant = 0
            foundHeight = true
        }
        if !foundHeight {
            let h = colVw.heightAnchor.constraint(equalToConstant: 0)
            h.priority = .required
            h.isActive = true
        }
        
        // Remove any vertical spacing between collection view and table
        for c in view.constraints {
            let involvesCol = (c.firstItem === colVw || c.secondItem === colVw)
            let involvesTbl = (c.firstItem === tblVw || c.secondItem === tblVw)
            if involvesCol && involvesTbl,
               c.firstAttribute == .top || c.firstAttribute == .bottom {
                c.constant = 0
            }
        }
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    var hasShownAddKid = false

    func setupUI() {
        let kids = UserManager.shared.kids

        if kids.isEmpty && !hasShownAddKid {
            hasShownAddKid = true
            
            tblVw.isHidden = true
            lblNoKids?.isHidden = true
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                addKidVC.onDismissWithoutAdding = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                present(addKidVC, animated: true, completion: nil)
            }
            return
        }

        if !kids.isEmpty {
            tblVw.isHidden = false
            lblNoKids?.isHidden = true

            if let selected = UserManager.shared.curriculamSelectedStudent,
               let idx = kids.firstIndex(where: { $0.id == selected.id }) {
                selected_student = idx
            } else {
                selected_student = 0
                UserManager.shared.curriculamSelectedStudent = kids[0]
            }

            tblVw.reloadData()
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Get Selected Student
    func currentSelectedStudent() -> Student? {
        if let selected = UserManager.shared.curriculamSelectedStudent {
            return selected
        } else if selected_student < UserManager.shared.kids.count {
            return UserManager.shared.kids[selected_student]
        }
        return nil
    }
    
    // MARK: - Resolve Grade ID
    func resolveGradeID(for student: Student) -> String {
        
        let directID = student.gradeID.trimmingCharacters(in: .whitespacesAndNewlines)
        if !directID.isEmpty {
            print("✅ Using direct gradeID: \(directID)")
            return directID
        }
        
        let studentGradeRaw = student.grade.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        print("🔎 Resolving grade for '\(student.name)' | grade='\(studentGradeRaw)' | numeric_grade=\(student.numeric_grade)")
        
        if !studentGradeRaw.isEmpty {
            if let match = allGrades.first(where: {
                $0.name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == studentGradeRaw
            }) {
                print("✅ Matched by exact name '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        let studentClassNumber = classNumber(from: studentGradeRaw, fallbackNumeric: student.numeric_grade)
        print("   student class number = \(studentClassNumber)")
        
        if studentClassNumber != Int.min {
            if let match = allGrades.first(where: {
                classNumber(from: $0.name.uppercased(), fallbackNumeric: $0.numericGrade ?? 0) == studentClassNumber
            }) {
                print("✅ Matched by class number \(studentClassNumber): '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        if student.numeric_grade > 0 {
            if let match = allGrades.first(where: { $0.numericGrade == student.numeric_grade }) {
                print("✅ Matched by numeric_grade \(student.numeric_grade): '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        if !studentGradeRaw.isEmpty {
            if let match = allGrades.first(where: {
                let gName = $0.name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                return gName.contains(studentGradeRaw) || studentGradeRaw.contains(gName)
            }) {
                print("✅ Matched by partial name '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        print("⚠️ Could NOT resolve grade for '\(student.name)'")
        print("   Available grades:")
        for g in allGrades {
            print("   • name='\(g.name)' id=\(g.id) numeric=\(String(describing: g.numericGrade)) classNo=\(classNumber(from: g.name.uppercased(), fallbackNumeric: g.numericGrade ?? 0))")
        }
        
        return ""
    }
    
    func classNumber(from raw: String, fallbackNumeric: Int) -> Int {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if s.contains("NURSERY") || s.contains("PRE-KG") || s.contains("PREKG") || s.contains("PRE KG") {
            return -2
        }
        if s == "LKG" || s.contains("LOWER KG") || s == "PP1" || s.contains("PP 1") {
            return -1
        }
        if s == "UKG" || s.contains("UPPER KG") || s == "PP2" || s.contains("PP 2") || s == "HKG" {
            return 0
        }
        
        let tokens = s.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        
        for token in tokens {
            if let n = Int(token), n > 0 {
                return n
            }
            let roman = romanToInt(token)
            if roman > 0 {
                return roman
            }
        }
        
        let digits = s.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let n = Int(digits), n > 0 {
            return n
        }
        
        if fallbackNumeric > 0 {
            return fallbackNumeric
        }
        
        return Int.min
    }
    
    func romanToInt(_ input: String) -> Int {
        let values: [Character: Int] = ["I":1, "V":5, "X":10, "L":50, "C":100, "D":500, "M":1000]
        let cleaned = input.replacingOccurrences(of: " ", with: "").uppercased()
        if cleaned.isEmpty { return 0 }
        
        for ch in cleaned where values[ch] == nil { return 0 }
        
        var total = 0
        var prev = 0
        for ch in cleaned.reversed() {
            guard let val = values[ch] else { return 0 }
            if val < prev { total -= val } else { total += val; prev = val }
        }
        return total
    }
    
    // MARK: - Navigation
    func handleNavigate() {
        guard let student = currentSelectedStudent() else {
            showAlert(msg: "Please select a student first.")
            return
        }
        
        let gradeID = resolveGradeID(for: student)
        
        if gradeID.isEmpty {
            if isGradesLoading || allGrades.isEmpty {
                showLoader()
                getGradesList { [weak self] in
                    self?.hideLoader()
                    guard let self = self else { return }
                    let retryID = self.resolveGradeID(for: student)
                    if retryID.isEmpty {
                        self.showAlert(msg: "Grade information not available for the selected student.")
                    } else {
                        self.pushCategory(gradeID: retryID)
                    }
                }
            } else {
                showAlert(msg: "Grade information not available for the selected student.")
            }
            return
        }
        
        pushCategory(gradeID: gradeID)
    }
    
    func pushCategory(gradeID: String) {
        print("🚀 Navigating with gradeID: \(gradeID)")
        let stbd = UIStoryboard(name: "curriculum", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "CurriculumCategoryController") as! CurriculumCategoryController
        vc.selectedGradeID = gradeID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell
        cell?.lblDesc.text = types[indexPath.row].description
        cell?.lblName.text = types[indexPath.row].curriculumName
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleNavigate()
    }
    
    // MARK: - APIs
    
    func getCurriculumType() {
        showLoader()
        NetworkManager.shared.request(urlString: API.CURRICULUM_TYPES, method: .GET) { (result: Result<APIResponse<[Curriculum]>, NetworkError>) in
            self.hideLoader()
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.types = data
                    }
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description ?? "Failed to load curriculum")
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
    func getGradesList(completion: (() -> Void)? = nil) {
        isGradesLoading = true
        NetworkManager.shared.request(urlString: API.GRADES_LIST, method: .GET) { (result: Result<APIResponse<[Grade]>, NetworkError>) in
            self.isGradesLoading = false
            switch result {
            case .success(let info):
                if info.success, let data = info.data {
                    self.allGrades = data
                    print("✅ Grades loaded: \(data.count)")
                    for g in data {
                        print("   • name='\(g.name)' id=\(g.id) numeric=\(String(describing: g.numericGrade))")
                    }
                } else {
                    print("❌ Failed to load grades: \(info.description)")
                }
            case .failure(let error):
                print("❌ Grades API Error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}
