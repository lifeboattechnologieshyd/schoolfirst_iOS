//
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
    
    // Reused if connected in Storyboard. Otherwise, the collection view is created here.
    @IBOutlet weak var gradesCollectionView: UICollectionView?
    
    // Full response from curriculum/categori API
    var allCategories = [CurriculumCategory]()
    
    // Categories filtered for selected grade (table view data)
    var cats = [CurriculumCategory]()
    
    // Grade chips built from the category response
    private var grades = [GradeChip]()
    
    // Set by the previous screen and updated when a grade chip is tapped.
    var selectedGradeID: String = ""
    
    private struct GradeChip {
        let id: String
        let name: String
    }
    
    private let gradeHeaderHeight: CGFloat = 64
    private var activeGradesCollectionView: UICollectionView?
    private var gradeCollectionHeader: UIView?
    private var categoryRequestGeneration = 0
    private var isCategoryRequestLoading = false
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
        
        configureEmptyStateLabel()
        installGradesCollectionView()
        
        selectedGradeID = selectedGradeID.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        print("📥 CurriculumCategoryController received Grade ID: \(selectedGradeID)")
        
        fetchCategoriesAndBuildGrades()
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
    
    // MARK: - Programmatic Grades Collection View
    
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
        
        // Move the collection into the table header so it appears above categories.
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
        
        guard width > 0 else {
            return
        }
        
        let needsUpdate =
            abs(header.frame.width - width) > 0.5 ||
            abs(header.frame.height - gradeHeaderHeight) > 0.5
        
        guard needsUpdate else {
            return
        }
        
        header.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: gradeHeaderHeight
        )
        
        collectionView.frame = header.bounds
        
        // UITableView requires its header frame to be reset after resizing.
        tblVw.tableHeaderView = header
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Fetch Categories & Build Grades
    
    private func fetchCategoriesAndBuildGrades() {
        
        categoryRequestGeneration += 1
        
        let requestGeneration = categoryRequestGeneration
        
        showLoader()
        isCategoryRequestLoading = true
        
        // Fetch all categories.
        let url = API.CURRICULUM_CATEGORIES
        
        print("🔗 Curriculum Categories URL: \(url)")
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (
            result: Result<APIResponse<[CurriculumCategory]>, NetworkError>
        ) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self,
                      self.categoryRequestGeneration == requestGeneration else {
                    return
                }
                
                self.hideLoader()
                self.isCategoryRequestLoading = false
                
                switch result {
                    
                case .success(let info):
                    
                    guard info.success else {
                        
                        self.allCategories = []
                        self.grades = []
                        self.cats = []
                        
                        self.activeGradesCollectionView?.reloadData()
                        self.tblVw.reloadData()
                        
                        self.showCategoryMessage("Could not load categories.")
                        
                        return
                    }
                    
                    self.allCategories = info.data ?? []
                    
                    // Build unique grade chips from grade_ids + grade_names.
                    var uniqueGrades = [GradeChip]()
                    var seenGradeIDs = Set<String>()
                    
                    for category in self.allCategories {
                        
                        for (index, gradeID) in category.gradeIDs.enumerated() {
                            
                            if !seenGradeIDs.contains(gradeID) {
                                
                                seenGradeIDs.insert(gradeID)
                                
                                let gradeName = category.gradeNames.indices.contains(index)
                                    ? category.gradeNames[index]
                                    : "Grade"
                                
                                uniqueGrades.append(
                                    GradeChip(
                                        id: gradeID,
                                        name: gradeName
                                    )
                                )
                            }
                        }
                    }
                    
                    self.grades = uniqueGrades
                    
                    if self.grades.isEmpty {
                        
                        self.cats = []
                        
                        self.activeGradesCollectionView?.reloadData()
                        self.tblVw.reloadData()
                        
                        self.showCategoryMessage("No grades available.")
                        
                        return
                    }
                    
                    // Keep passed grade if valid, otherwise select first.
                    if !self.grades.contains(where: {
                        $0.id == self.selectedGradeID
                    }) {
                        self.selectedGradeID = self.grades[0].id
                    }
                    
                    self.activeGradesCollectionView?.reloadData()
                    self.scrollToSelectedGrade()
                    self.filterCategoriesForSelectedGrade()
                    
                case .failure(let error):
                    
                    self.allCategories = []
                    self.grades = []
                    self.cats = []
                    
                    self.activeGradesCollectionView?.reloadData()
                    self.tblVw.reloadData()
                    
                    self.showCategoryMessage("Could not load categories.")
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    private func filterCategoriesForSelectedGrade() {
        
        guard !selectedGradeID.isEmpty else {
            
            cats = []
            tblVw.reloadData()
            
            showCategoryMessage("Select a grade to view categories.")
            
            return
        }
        
        cats = allCategories.filter {
            $0.gradeIDs.contains(selectedGradeID)
        }
        
        tblVw.reloadData()
        
        if cats.isEmpty {
            showCategoryMessage("No categories available for this grade.")
        } else {
            tblVw.backgroundView = nil
        }
    }
    
    // MARK: - Grade Collection View
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return grades.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurriculumGradeChipCell.reuseIdentifier,
            for: indexPath
        ) as! CurriculumGradeChipCell
        
        let grade = grades[indexPath.item]
        
        cell.configure(
            gradeName: grade.name,
            isSelected: grade.id == selectedGradeID
        )
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        guard grades.indices.contains(indexPath.item) else {
            return
        }
        
        let selectedGrade = grades[indexPath.item]
        
        guard selectedGrade.id != selectedGradeID else {
            return
        }
        
        let previousGradeID = selectedGradeID
        
        selectedGradeID = selectedGrade.id
        
        var indexPathsToReload = [indexPath]
        
        if let previousIndex = grades.firstIndex(where: {
            $0.id == previousGradeID
        }), previousIndex != indexPath.item {
            
            indexPathsToReload.append(
                IndexPath(
                    item: previousIndex,
                    section: 0
                )
            )
        }
        
        collectionView.reloadItems(at: indexPathsToReload)
        
        print("🎓 Selected grade: \(selectedGrade.name)")
        print("🎓 Selected grade ID: \(selectedGradeID)")
        
        filterCategoriesForSelectedGrade()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard grades.indices.contains(indexPath.item) else {
            return CGSize(
                width: 100,
                height: 36
            )
        }
        
        let grade = grades[indexPath.item]
        
        let titleFont = UIFont.systemFont(
            ofSize: 14,
            weight: .semibold
        )
        
        let titleWidth = (grade.name as NSString).size(
            withAttributes: [
                .font: titleFont
            ]
        ).width
        
        return CGSize(
            width: max(ceil(titleWidth) + 28, 90),
            height: 36
        )
    }
    
    private func scrollToSelectedGrade() {
        
        guard let collectionView = activeGradesCollectionView,
              let index = grades.firstIndex(where: {
                  $0.id == selectedGradeID
              }) else {
            return
        }
        
        let indexPath = IndexPath(
            item: index,
            section: 0
        )
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self,
                  let collectionView = self.activeGradesCollectionView,
                  indexPath.item < collectionView.numberOfItems(inSection: 0) else {
                return
            }
            
            collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
    
    // MARK: - Table View
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return cats.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard cats.indices.contains(indexPath.row),
              let cell = tableView.dequeueReusableCell(
                withIdentifier: "CurriculamCategoryCell"
              ) as? CurriculamCategoryCell else {
            return UITableViewCell()
        }
        
        let category = cats[indexPath.row]
        
        cell.lblTitle.text = category.curriculumName
        
        // New response has no image field.
        cell.imgVw.isHidden = true
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 185
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        guard cats.indices.contains(indexPath.row),
              !selectedGradeID.isEmpty else {
            return
        }
        
        let storyboard = UIStoryboard(
            name: "curriculum",
            bundle: nil
        )
        
        let vc = storyboard.instantiateViewController(
            identifier: "CurriculumSubjectController"
        ) as! CurriculumSubjectController
        
        vc.selected_category = cats[indexPath.row]
        
        // Pass the grade selected on this screen to the next screen.
        vc.selectedGradeID = selectedGradeID
        
        print(
            "➡️ Passing Grade ID to CurriculumSubjectController: \(selectedGradeID)"
        )
        
        navigationController?.pushViewController(
            vc,
            animated: true
        )
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
        
        gradeNameLabel.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )
        
        gradeNameLabel.textAlignment = .center
        gradeNameLabel.numberOfLines = 1
        gradeNameLabel.lineBreakMode = .byTruncatingTail
        
        contentView.addSubview(gradeNameLabel)
        
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            
            gradeNameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            
            gradeNameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            
            gradeNameLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius =
            contentView.bounds.height / 2
    }
    
    func configure(
        gradeName: String,
        isSelected: Bool
    ) {
        
        gradeNameLabel.text = gradeName
        
        if isSelected {
            
            contentView.backgroundColor = UIColor.primary
            contentView.layer.borderWidth = 0
            gradeNameLabel.textColor = .white
            
        } else {
            
            contentView.backgroundColor = .systemGray5
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor =
                UIColor.systemGray4.cgColor
            
            gradeNameLabel.textColor = .label
        }
    }
}
