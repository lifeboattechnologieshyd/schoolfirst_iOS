//
//  CurriculumController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblNoKids: UILabel!
    
    var selected_student = 0
    var types = [Curriculum]()
    var allGrades: [Grade] = []          // ✅ All grades from GRADES_LIST API
    var isGradesLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        self.colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        self.tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        
        self.getCurriculumType()
        self.getGradesList()   // ✅ Load grades for matching
        
        colVw.delegate = self
        colVw.dataSource = self
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        colVw.reloadData()
    }
    
    var hasShownAddKid = false

    func setupUI() {
        let kids = UserManager.shared.kids

        if kids.isEmpty && !hasShownAddKid {
            hasShownAddKid = true
            
            colVw.isHidden = true
            tblVw.isHidden = true
            lblNoKids?.isHidden = true
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addKidVC = storyboard.instantiateViewController(identifier: "AddKidVC") as? AddKidVC {
                addKidVC.modalPresentationStyle = .fullScreen
                addKidVC.onDismissWithoutAdding = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                self.present(addKidVC, animated: true, completion: nil)
            }
            return
        }

        if !kids.isEmpty {
            colVw.isHidden = false
            tblVw.isHidden = false
            lblNoKids?.isHidden = true

            selected_student = 0
            UserManager.shared.curriculamSelectedStudent = kids[0]

            colVw.reloadData()
            tblVw.reloadData()
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Get Selected Student (safe unwrap)
    func currentSelectedStudent() -> Student? {
        if let selected = UserManager.shared.curriculamSelectedStudent {
            return selected
        } else if selected_student < UserManager.shared.kids.count {
            return UserManager.shared.kids[selected_student]
        }
        return nil
    }
    
    // MARK: - Resolve Grade ID
    /// Resolves the grade ID for the given student using multiple strategies.
    func resolveGradeID(for student: Student) -> String {
        
        // 1) Direct gradeID (if available)
        let directID = student.gradeID.trimmingCharacters(in: .whitespacesAndNewlines)
        if !directID.isEmpty {
            print("✅ Using direct gradeID: \(directID)")
            return directID
        }
        
        // Normalize student's grade display string
        let studentGradeRaw = student.grade.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        print("🔎 Resolving grade for '\(student.name)' | grade='\(studentGradeRaw)' | numeric_grade=\(student.numeric_grade)")
        
        // 2) Exact name match (e.g. student "VI" == grade name "VI")
        if !studentGradeRaw.isEmpty {
            if let match = allGrades.first(where: {
                $0.name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == studentGradeRaw
            }) {
                print("✅ Matched by exact name '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        // 3) Convert student grade to a class number and match by numeric_grade
        let studentClassNumber = classNumber(from: studentGradeRaw, fallbackNumeric: student.numeric_grade)
        print("   student class number = \(studentClassNumber)")
        
        if studentClassNumber != Int.min {
            // Try matching grade whose class number equals studentClassNumber
            if let match = allGrades.first(where: {
                classNumber(from: $0.name.uppercased(), fallbackNumeric: $0.numericGrade ?? 0) == studentClassNumber
            }) {
                print("✅ Matched by class number \(studentClassNumber): '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        // 4) Match by numeric_grade directly (if both have it)
        if student.numeric_grade > 0 {
            if let match = allGrades.first(where: { $0.numericGrade == student.numeric_grade }) {
                print("✅ Matched by numeric_grade \(student.numeric_grade): '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        // 5) Partial/contains name match
        if !studentGradeRaw.isEmpty {
            if let match = allGrades.first(where: {
                let gName = $0.name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                return gName.contains(studentGradeRaw) || studentGradeRaw.contains(gName)
            }) {
                print("✅ Matched by partial name '\(match.name)' → \(match.id)")
                return match.id
            }
        }
        
        // Debug dump
        print("⚠️ Could NOT resolve grade for '\(student.name)'")
        print("   Available grades:")
        for g in allGrades {
            print("   • name='\(g.name)' id=\(g.id) numeric=\(String(describing: g.numericGrade)) classNo=\(classNumber(from: g.name.uppercased(), fallbackNumeric: g.numericGrade ?? 0))")
        }
        
        return ""
    }
    
    /// Converts a grade display string to a universal "class number".
    /// Pre-primary: Nursery=-2, LKG/PP1=-1, UKG/PP2=0
    /// Grades: Grade1/I=1 ... Grade12/XII=12
    /// Returns Int.min if unresolvable.
    func classNumber(from raw: String, fallbackNumeric: Int) -> Int {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Pre-primary keywords
        if s.contains("NURSERY") || s.contains("PRE-KG") || s.contains("PREKG") || s.contains("PRE KG") {
            return -2
        }
        if s == "LKG" || s.contains("LOWER KG") || s == "PP1" || s.contains("PP 1") {
            return -1
        }
        if s == "UKG" || s.contains("UPPER KG") || s == "PP2" || s.contains("PP 2") || s == "HKG" {
            return 0
        }
        
        // Try Roman numeral (VI, VIII, XII, etc.)
        let roman = romanToInt(s)
        if roman > 0 {
            return roman
        }
        
        // Try to extract plain digits (e.g. "Grade 8", "8")
        let digits = s.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let n = Int(digits), n > 0 {
            return n
        }
        
        // Fallback to numeric_grade if positive
        if fallbackNumeric > 0 {
            return fallbackNumeric
        }
        
        return Int.min
    }
    
    /// Convert Roman numeral to Int. Returns 0 if invalid.
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
            self.showAlert(msg: "Please select a student first.")
            return
        }
        
        let gradeID = resolveGradeID(for: student)
        
        if gradeID.isEmpty {
            // If grades still loading, retry after fetching
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
                self.showAlert(msg: "Grade information not available for the selected student.")
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
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        let kids = UserManager.shared.kids
        cell.setup(student: kids[indexPath.row], isSelected: selected_student == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selected_student
        selected_student = indexPath.row
        UserManager.shared.curriculamSelectedStudent = UserManager.shared.kids[indexPath.row]
        
        var indexPathsToReload = [indexPath]
        if previousIndex != indexPath.row {
            indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
        }
        colVw.reloadItems(at: indexPathsToReload)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 20) / 2
        return CGSize(width: width, height: 80)
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTypeCell") as? CurriculumTypeCell
        cell?.lblDesc.text = types[indexPath.row].description
        cell?.lblName.text = types[indexPath.row].curriculumName
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
