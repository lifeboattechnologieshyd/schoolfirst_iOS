//  CurriculumCategoryController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 20/10/25.
//

import UIKit

class CurriculumCategoryController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var gradesCollectionView: UICollectionView?
    
    // Passed from CurriculumController
    var selectedCurriculum: Curriculum?
    
    // Selected grade ID
    var selectedGradeID: String = ""
    
    // Categories loaded for the selected grade
    var cats = [CurriculumCategory]()
    
    // Grade chips built from selectedCurriculum
    private var grades = [GradeChip]()
    
    private struct GradeChip {
        let id: String
        let name: String
    }
    
    private let gradeHeaderHeight: CGFloat = 64
    private var activeGradesCollectionView: UICollectionView?
    private var gradeCollectionHeader: UIView?
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(
            UINib(nibName: "CurriculamCategoryCell", bundle: nil),
            forCellReuseIdentifier: "CurriculamCategoryCell"
        )
        
        topView.addBottomShadow()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = .white
        tblVw.separatorStyle = .none
        
        configureEmptyStateLabel()
        installGradesCollectionView()
        
        setupGradesFromCurriculum()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradesHeaderSize()
    }
    
    private func configureEmptyStateLabel() {
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.numberOfLines = 0
    }
    
    private func showCategoryMessage(_ message: String) {
        emptyStateLabel.text = message
        emptyStateLabel.frame = tblVw.bounds
        tblVw.backgroundView = emptyStateLabel
    }
    
    // MARK: - Programmatic Grades Collection View Header
    
    private func installGradesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(
            top: 12,
            left: 16,
            bottom: 8,
            right: 16
        )
        
        let collectionView: UICollectionView
        if let storyboardCollectionView = gradesCollectionView {
            collectionView = storyboardCollectionView
        } else {
            collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: layout
            )
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        
        collectionView.register(
            CurriculumGradeChipCell.self,
            forCellWithReuseIdentifier: CurriculumGradeChipCell.reuseIdentifier
        )
        
        collectionView.removeFromSuperview()
        
        let header = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tblVw.bounds.width,
                height: gradeHeaderHeight
            )
        )
        header.backgroundColor = .clear
        
        collectionView.frame = header.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        header.addSubview(collectionView)
        
        activeGradesCollectionView = collectionView
        gradeCollectionHeader = header
        tblVw.tableHeaderView = header
    }
    
    private func updateGradesHeaderSize() {
        guard let header = gradeCollectionHeader,
              let collectionView = activeGradesCollectionView else {
            return
        }
        
        let width = tblVw.bounds.width
        guard width > 0 else { return }
        
        let needsUpdate = abs(header.frame.width - width) > 0.5 ||
                          abs(header.frame.height - gradeHeaderHeight) > 0.5
        guard needsUpdate else { return }
        
        header.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: gradeHeaderHeight
        )
        collectionView.frame = header.bounds
        tblVw.tableHeaderView = header
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Build Grades from Curriculum & Fetch Categories
    
    private func setupGradesFromCurriculum() {
        guard let curriculum = selectedCurriculum else {
            showCategoryMessage("No curriculum selected.")
            return
        }
        
        let ids = curriculum.gradeIDs ?? []
        let names = curriculum.gradeNames ?? []
        
        grades = ids.enumerated().map { (index, id) in
            let name = names.indices.contains(index) ? names[index] : "Grade \(index + 1)"
            return GradeChip(id: id, name: name)
        }
        
        print("🎓 Built \(grades.count) grades for curriculum: \(curriculum.curriculumName ?? "")")
        
        if grades.isEmpty {
            activeGradesCollectionView?.reloadData()
            tblVw.reloadData()
            showCategoryMessage("No grades available for this curriculum.")
            return
        }
        
        if selectedGradeID.isEmpty || !grades.contains(where: { $0.id == selectedGradeID }) {
            selectedGradeID = grades[0].id
        }
        
        activeGradesCollectionView?.reloadData()
        scrollToSelectedGrade()
        fetchCategoriesForSelectedGrade()
    }
    
    private func fetchCategoriesForSelectedGrade() {
        guard !selectedGradeID.isEmpty else {
            cats = []
            tblVw.reloadData()
            showCategoryMessage("Select a grade to view categories.")
            return
        }
        
        showLoader()
        
        var urlString = "\(API.BASE_URL)curriculum/categori?grade=\(selectedGradeID)"
        if let curriculumID = selectedCurriculum?.id, !curriculumID.isEmpty {
            urlString += "&curriculum=\(curriculumID)"
        }
        
        print("🔗 Fetching Categories URL: \(urlString)")
        
        NetworkManager.shared.request(urlString: urlString, method: .GET) { [weak self] (result: Result<APIResponse<[CurriculumCategory]>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                
                switch result {
                case .success(let info):
                    if info.success {
                        self.cats = info.data ?? []
                        self.tblVw.reloadData()
                        if self.cats.isEmpty {
                            self.showCategoryMessage("No categories available for this grade.")
                        } else {
                            self.tblVw.backgroundView = nil
                        }
                    } else {
                        self.cats = []
                        self.tblVw.reloadData()
                        self.showCategoryMessage(info.description ?? "No categories available.")
                    }
                case .failure(let error):
                    self.cats = []
                    self.tblVw.reloadData()
                    self.showCategoryMessage("Could not load categories.")
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    private func scrollToSelectedGrade() {
        guard activeGradesCollectionView != nil,
              let index = grades.firstIndex(where: { $0.id == selectedGradeID }) else {
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let collectionView = self.activeGradesCollectionView,
                  indexPath.item < collectionView.numberOfItems(inSection: 0) else {
                return
            }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    // MARK: - UICollectionView (Grades Chips)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return grades.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurriculumGradeChipCell.reuseIdentifier,
            for: indexPath
        ) as! CurriculumGradeChipCell
        
        let grade = grades[indexPath.item]
        cell.configure(gradeName: grade.name, isSelected: grade.id == selectedGradeID)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard grades.indices.contains(indexPath.item) else { return }
        let selectedGrade = grades[indexPath.item]
        guard selectedGrade.id != selectedGradeID else { return }
        
        selectedGradeID = selectedGrade.id
        collectionView.reloadData()
        scrollToSelectedGrade()
        fetchCategoriesForSelectedGrade()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard grades.indices.contains(indexPath.item) else {
            return CGSize(width: 100, height: 36)
        }
        
        let grade = grades[indexPath.item]
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let titleWidth = (grade.name as NSString).size(withAttributes: [.font: titleFont]).width
        return CGSize(width: max(ceil(titleWidth) + 28, 90), height: 36)
    }
    
    // MARK: - UITableView (Categories)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard cats.indices.contains(indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculamCategoryCell") as? CurriculamCategoryCell else {
            return UITableViewCell()
        }
        
        let category = cats[indexPath.row]
        cell.lblTitle.text = category.name
        
        if let imgUrl = category.categoryImage, !imgUrl.isEmpty {
            cell.imgVw.isHidden = false
            cell.imgVw.loadImage(url: imgUrl)
        } else {
            cell.imgVw.isHidden = false
            cell.imgVw.backgroundColor = UIColor(red: 0.15, green: 0.25, blue: 0.45, alpha: 1.0)
            cell.imgVw.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard cats.indices.contains(indexPath.row), !selectedGradeID.isEmpty else { return }
        
        let storyboard = UIStoryboard(name: "curriculum", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "CurriculumSubjectController") as? CurriculumSubjectController else {
            return
        }
        
        vc.selected_category = cats[indexPath.row]
        vc.selectedGradeID = selectedGradeID
        
        print("➡️ Navigating to CurriculumSubjectController with Grade ID: \(selectedGradeID), Category ID: \(cats[indexPath.row].id)")
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Grade Chip Cell

private final class CurriculumGradeChipCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CurriculumGradeChipCell"
    private let gradeNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        gradeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        gradeNameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        gradeNameLabel.textAlignment = .center
        gradeNameLabel.numberOfLines = 1
        gradeNameLabel.lineBreakMode = .byTruncatingTail
        
        contentView.addSubview(gradeNameLabel)
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            gradeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            gradeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            gradeNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
    
    func configure(gradeName: String, isSelected: Bool) {
        gradeNameLabel.text = gradeName
        if isSelected {
            contentView.backgroundColor = UIColor.primary
            contentView.layer.borderWidth = 0
            gradeNameLabel.textColor = .white
        } else {
            contentView.backgroundColor = .systemGray5
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            gradeNameLabel.textColor = .label
        }
    }
}
