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
    var allGrades: [Grade] = []
    var isGradesLoading = false
    
    private let kidSectionInset: CGFloat = 16
    private let kidInterItemSpacing: CGFloat = 12
    private let kidCellHeight: CGFloat = 72
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.addBottomShadow()
        
        colVw.register(UINib(nibName: "KidSelectionCell", bundle: nil), forCellWithReuseIdentifier: "KidSelectionCell")
        tblVw.register(UINib(nibName: "CurriculumTypeCell", bundle: nil), forCellReuseIdentifier: "CurriculumTypeCell")
        
        configureKidsCollectionView()
        
        getCurriculumType()
        getGradesList()
        
        colVw.delegate = self
        colVw.dataSource = self
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.reloadData()
    }
    
    private func configureKidsCollectionView() {
        // Force fixed-size cells (disable self-sizing from storyboard)
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = kidInterItemSpacing
            layout.minimumInteritemSpacing = kidInterItemSpacing
            layout.sectionInset = UIEdgeInsets(
                top: 8,
                left: kidSectionInset,
                bottom: 8,
                right: kidSectionInset
            )
            // Turn off self-sizing so sizeForItemAt is respected
            layout.estimatedItemSize = .zero
        }
        
        colVw.showsHorizontalScrollIndicator = false
        colVw.alwaysBounceHorizontal = true
        colVw.contentInsetAdjustmentBehavior = .never
        colVw.contentInset = .zero
        colVw.clipsToBounds = true
        colVw.backgroundColor = .clear
        colVw.decelerationRate = .fast
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colVw.collectionViewLayout.invalidateLayout()
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
                present(addKidVC, animated: true, completion: nil)
            }
            return
        }

        if !kids.isEmpty {
            colVw.isHidden = false
            tblVw.isHidden = false
            lblNoKids?.isHidden = true

            if let selected = UserManager.shared.curriculamSelectedStudent,
               let idx = kids.firstIndex(where: { $0.id == selected.id }) {
                selected_student = idx
            } else {
                selected_student = 0
                UserManager.shared.curriculamSelectedStudent = kids[0]
            }

            colVw.reloadData()
            tblVw.reloadData()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let count = UserManager.shared.kids.count
                if count > 0, self.selected_student < count {
                    self.colVw.scrollToItem(
                        at: IndexPath(item: self.selected_student, section: 0),
                        at: .centeredHorizontally,
                        animated: false
                    )
                }
            }
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
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.kids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidSelectionCell", for: indexPath) as! KidSelectionCell
        let kids = UserManager.shared.kids
        cell.setup(student: kids[indexPath.item], isSelected: selected_student == indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousIndex = selected_student
        selected_student = indexPath.item
        UserManager.shared.curriculamSelectedStudent = UserManager.shared.kids[indexPath.item]
        
        var indexPathsToReload = [indexPath]
        if previousIndex != indexPath.item {
            indexPathsToReload.append(IndexPath(item: previousIndex, section: 0))
        }
        colVw.reloadItems(at: indexPathsToReload)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalKids = UserManager.shared.kids.count
        let boundsWidth = collectionView.bounds.width
        
        guard boundsWidth > 0 else {
            return CGSize(width: 160, height: kidCellHeight)
        }
        
        if totalKids <= 1 {
            let width = boundsWidth - (kidSectionInset * 2)
            return CGSize(width: max(width, 120), height: kidCellHeight)
        }
        
        if totalKids == 2 {
            let totalHorizontalPadding = (kidSectionInset * 2) + kidInterItemSpacing
            let width = floor((boundsWidth - totalHorizontalPadding) / 2.0)
            return CGSize(width: max(width, 120), height: kidCellHeight)
        }
        
        let width = floor((boundsWidth - (kidSectionInset * 2) - kidInterItemSpacing) / 2.0)
        return CGSize(width: max(width, 140), height: kidCellHeight)
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
