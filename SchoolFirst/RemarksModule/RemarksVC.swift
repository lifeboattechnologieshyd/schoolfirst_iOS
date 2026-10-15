//
//  RemarksVC.swift
//  SchoolFirst
//

import UIKit

class RemarksVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    // MARK: - Categories Data
    private var remarkCategories: [FeedbackCategoryOption] = []

    // MARK: - Remarks Data
    private var allRemarks: [RemarkItem] = []
    private var filteredRemarks: [RemarkItem] = []
    private var selectedCategoryId: String = "all"
    private var filterStartDate: Date?
    private var filterEndDate: Date?
    private var isSortNewestFirst: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        Tableview.register(
            UINib(nibName: "RemarksTBLVCll1", bundle: nil),
            forCellReuseIdentifier: "RemarksTBLVCll1"
        )
        Tableview.register(
            UINib(nibName: "RemarksTBLVCll2", bundle: nil),
            forCellReuseIdentifier: "RemarksTBLVCll2"
        )
        Tableview.register(
            UINib(nibName: "EmtyremarksTBLVCll", bundle: nil),
            forCellReuseIdentifier: "EmtyremarksTBLVCll"
        )

        Backbutton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)

        fetchRemarkCategories()
        fetchRemarksList()
    }

    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - API: Categories
    private func fetchRemarkCategories() {
        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ Remarks Categories API — missing IDs")
            return
        }

        print("📡 Remarks Categories API — schoolId: \(schoolId), studentId: \(studentId)")

        NetworkManager.shared.request(
            urlString: API.REMARKS_CATEGORIES,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<[RemarkCategory]>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Remarks Categories API Success: \(response.success)")
                    if let categories = response.data {
                        var options: [FeedbackCategoryOption] = [
                            FeedbackCategoryOption(id: "all", name: "All")
                        ]
                        options.append(contentsOf: categories.map {
                            FeedbackCategoryOption(id: $0.id, name: $0.name)
                        })
                        self.remarkCategories = options
                        self.Tableview.reloadData()
                    }
                case .failure(let error):
                    print("❌ Failed to fetch remark categories: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - API: Remarks List
    private func fetchRemarksList() {
        let schoolId = UserManager.shared.resolvedSchoolID
        let studentId = UserManager.shared.resolvedStudentID

        guard !schoolId.isEmpty, !studentId.isEmpty else {
            print("❌ Remarks List API — missing IDs")
            return
        }

        print("📡 Remarks List API — schoolId: \(schoolId), studentId: \(studentId)")

        NetworkManager.shared.request(
            urlString: API.REMARKS_LIST,
            method: .GET,
            requiresAuth: true,
            parameters: ["student_id": studentId],
            headers: ["X-School-Id": schoolId]
        ) { [weak self] (result: Result<APIResponse<[RemarkItem]>, NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Remarks List API Success — total: \(response.total ?? 0), data count: \(response.data?.count ?? 0)")
                    self.allRemarks = response.data ?? []
                    self.applyFilter()

                case .failure(let error):
                    print("❌ Failed to fetch remarks: \(error.localizedDescription)")
                    self.allRemarks = []
                    self.filteredRemarks = []
                    self.Tableview.reloadData()
                }
            }
        }
    }

    // MARK: - Filter Logic
    private func applyFilter() {
        var result = allRemarks

        // 1. Category filter
        if selectedCategoryId != "all" && !selectedCategoryId.isEmpty {
            result = result.filter { $0.category.id == selectedCategoryId }
        }

        // 2. Date range filter
        let calendar = Calendar.current
        if let start = filterStartDate {
            let startDay = calendar.startOfDay(for: start)
            result = result.filter { item in
                guard let itemDate = item.parsedDate else { return true }
                return itemDate >= startDay
            }
        }
        if let end = filterEndDate {
            let endDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
            result = result.filter { item in
                guard let itemDate = item.parsedDate else { return true }
                return itemDate <= endDay
            }
        }

        // 3. Sort order
        result.sort { item1, item2 in
            let date1 = item1.parsedDate ?? Date.distantPast
            let date2 = item2.parsedDate ?? Date.distantPast
            return isSortNewestFirst ? (date1 > date2) : (date1 < date2)
        }

        filteredRemarks = result
        print("🔍 Filter — id: \(selectedCategoryId), start: \(String(describing: filterStartDate)), end: \(String(describing: filterEndDate)), sortNewest: \(isSortNewestFirst), showing: \(filteredRemarks.count) of \(allRemarks.count)")
        Tableview.reloadData()
    }

    // MARK: - Count helpers for cards
    private func countForCategory(name: String) -> Int {
        allRemarks.filter {
            $0.category.name.lowercased().contains(name.lowercased())
        }.count
    }

    private func presentRemarksFilterBottomSheet() {
        let vc = RemarksFilterBottomSheetVC()
        vc.categories = remarkCategories
        vc.selectedCategoryId = selectedCategoryId
        vc.selectedStartDate = filterStartDate
        vc.selectedEndDate = filterEndDate
        vc.isSortNewestFirst = isSortNewestFirst

        vc.onApplyFilter = { [weak self] (catId, startDate, endDate, newestFirst) in
            guard let self = self else { return }
            self.selectedCategoryId = catId
            self.filterStartDate = startDate
            self.filterEndDate = endDate
            self.isSortNewestFirst = newestFirst
            self.applyFilter()
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: false)
    }
}

// MARK: - UITableView
extension RemarksVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there are no remarks, return 2 (Row 0 for cards/header, Row 1 for Empty Cell)
        if filteredRemarks.isEmpty {
            return 2
        }
        return 1 + filteredRemarks.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RemarksTBLVCll1",
                for: indexPath
            ) as! RemarksTBLVCll1

            cell.selectionStyle = .none

            let academicCount = countForCategory(name: "academic")
            let behaviourCount = countForCategory(name: "behaviour")
            let newCount = allRemarks.count

            cell.updateCounts(
                academic: academicCount,
                behaviour: behaviourCount,
                newCount: newCount
            )

            cell.configureCategories(
                remarkCategories,
                totalCount: allRemarks.count,
                selectedCategoryId: selectedCategoryId
            )

            cell.onCategorySelected = { [weak self] categoryId in
                guard let self = self else { return }
                if self.selectedCategoryId != categoryId {
                    self.selectedCategoryId = categoryId
                    self.applyFilter()
                }
            }

            cell.onFilterButtonTapped = { [weak self] in
                self?.presentRemarksFilterBottomSheet()
            }

            return cell

        } else if filteredRemarks.isEmpty {
            // MARK: Show empty cell when there are no remarks
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "EmtyremarksTBLVCll",
                for: indexPath
            ) as? EmtyremarksTBLVCll ?? EmtyremarksTBLVCll()
            cell.selectionStyle = .none
            cell.configure()
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RemarksTBLVCll2",
                for: indexPath
            ) as! RemarksTBLVCll2

            cell.selectionStyle = .none
            let remark = filteredRemarks[indexPath.row - 1]
            cell.configure(with: remark)
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 334
        } else if filteredRemarks.isEmpty {
            return 280
        } else {
            return 160
        }
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.row == 0 {
            return 334
        } else if filteredRemarks.isEmpty {
            return 280
        } else {
            return 160
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Only navigate if remarks exist and row is a valid remark item
        if !filteredRemarks.isEmpty && indexPath.row > 0 {
            let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "RemarksdetailsVC") as? RemarksdetailsVC {
                vc.remark = filteredRemarks[indexPath.row - 1]
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Calendar Picker View Controller
final class CalendarPickerVC: UIViewController {

    var titleText: String = "Select Date"
    var initialDate: Date = Date()
    var minimumDate: Date?
    var maximumDate: Date?
    var onDateSelected: ((Date) -> Void)?

    private let dimView = UIControl()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private let selectButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(dimView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        view.addSubview(cardView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
        cardView.addSubview(titleLabel)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor(red: 0.48, green: 0.54, blue: 0.64, alpha: 1.0), for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        closeButton.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
        closeButton.layer.cornerRadius = 15
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = initialDate
        if let min = minimumDate { datePicker.minimumDate = min }
        if let max = maximumDate { datePicker.maximumDate = max }
        cardView.addSubview(datePicker)

        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.setTitle("Done", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        selectButton.backgroundColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0)
        selectButton.layer.cornerRadius = 12
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
        cardView.addSubview(selectButton)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            datePicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            datePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            selectButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 12),
            selectButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            selectButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 44),
            selectButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func selectTapped() {
        onDateSelected?(datePicker.date)
        dismiss(animated: true)
    }
}

// MARK: - Bottom Filter Sheet
final class RemarksFilterBottomSheetVC: UIViewController {

    var categories: [FeedbackCategoryOption] = []
    var selectedCategoryId: String = "all"
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var isSortNewestFirst: Bool = true
    var onApplyFilter: ((_ categoryId: String, _ startDate: Date?, _ endDate: Date?, _ isNewestFirst: Bool) -> Void)?

    private var categoriesToShow: [FeedbackCategoryOption] = []

    private let dimView = UIControl()
    private let sheetView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let categoryTitleLabel = UILabel()
    private var categoryButtons: [UIButton] = []
    private let categoryContainerView = UIView()
    private var categoryContainerHeightConstraint: NSLayoutConstraint?

    private let dateRangeTitleLabel = UILabel()
    private let startDateButton = UIButton(type: .system)
    private let endDateButton = UIButton(type: .system)
    private let toLabel = UILabel()

    private let last7DaysButton = UIButton(type: .system)
    private let last30DaysButton = UIButton(type: .system)
    private let thisTermButton = UIButton(type: .system)

    private let sortTitleLabel = UILabel()
    private let sortContainerView = UIView()
    private let newestFirstButton = UIButton(type: .system)
    private let oldestFirstButton = UIButton(type: .system)

    private let resetButton = UIButton(type: .system)
    private let showRemarksButton = UIButton(type: .system)

    private var didAnimateIn = false
    private var selectedCategoryButton: UIButton?
    private var selectedQuickDateButton: UIButton?

    private let displayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyDefaultSelections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAnimateIn else { return }
        didAnimateIn = true
        dimView.alpha = 0
        sheetView.transform = CGAffineTransform(translationX: 0, y: 440)
        UIView.animate(withDuration: 0.28) {
            self.dimView.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    private func setupUI() {
        view.backgroundColor = .clear
        setupDimView()
        setupSheetView()
        setupHeader()
        setupCategorySection()
        setupDateRangeSection()
        setupSortSection()
        setupBottomButtons()
    }

    private func setupDimView() {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSheetView() {
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 28
        sheetView.clipsToBounds = true
        view.addSubview(sheetView)
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sheetView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            sheetView.heightAnchor.constraint(equalToConstant: 480)
        ])
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = UIColor(red: 0.85, green: 0.88, blue: 0.93, alpha: 1.0)
        handleView.layer.cornerRadius = 2
        sheetView.addSubview(handleView)
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 36),
            handleView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func setupHeader() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Filter & sort"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor(red: 0.48, green: 0.54, blue: 0.64, alpha: 1.0), for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        closeButton.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
        closeButton.layer.cornerRadius = 16
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -18),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupCategorySection() {
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.text = "CATEGORY"
        categoryTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        categoryTitleLabel.textColor = UIColor(red: 0.43, green: 0.49, blue: 0.59, alpha: 1.0)
        sheetView.addSubview(categoryTitleLabel)
        categoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(categoryContainerView)

        let heightConstraint = categoryContainerView.heightAnchor.constraint(equalToConstant: 76)
        categoryContainerHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            categoryTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            categoryContainerView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 10),
            categoryContainerView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            categoryContainerView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -18),
            heightConstraint
        ])
        buildCategoryChips()
    }

    private func buildCategoryChips() {
        categoryButtons.forEach { $0.removeFromSuperview() }
        categoryButtons.removeAll()

        let categoriesToShow: [FeedbackCategoryOption]
        if categories.isEmpty {
            categoriesToShow = [
                FeedbackCategoryOption(id: "all", name: "All"),
                FeedbackCategoryOption(id: "appreciation", name: "Appreciation"),
                FeedbackCategoryOption(id: "academic", name: "Academic"),
                FeedbackCategoryOption(id: "behaviour", name: "Behaviour"),
                FeedbackCategoryOption(id: "attendance", name: "Attendance")
            ]
        } else {
            categoriesToShow = categories
        }
        self.categoriesToShow = categoriesToShow

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacing: CGFloat = 8
        let rowHeight: CGFloat = 32
        let maxWidth = UIScreen.main.bounds.width - 68

        for (index, cat) in categoriesToShow.enumerated() {
            let button = UIButton(type: .system)
            configureChipButton(button, title: cat.name)
            button.tag = index
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false

            let textWidth = (cat.name as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .semibold)]
            ).width
            let chipWidth = max(ceil(textWidth) + 32, 48)

            if currentX + chipWidth > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + 8
            }

            categoryContainerView.addSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: currentX),
                button.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: currentY),
                button.heightAnchor.constraint(equalToConstant: rowHeight),
                button.widthAnchor.constraint(equalToConstant: chipWidth)
            ])
            categoryButtons.append(button)
            currentX += chipWidth + spacing
        }

        categoryContainerHeightConstraint?.constant = max(currentY + rowHeight, 72)
    }

    private func setupDateRangeSection() {
        dateRangeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateRangeTitleLabel.text = "DATE RANGE"
        dateRangeTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        dateRangeTitleLabel.textColor = UIColor(red: 0.43, green: 0.49, blue: 0.59, alpha: 1.0)
        sheetView.addSubview(dateRangeTitleLabel)
        NSLayoutConstraint.activate([
            dateRangeTitleLabel.topAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: 14),
            dateRangeTitleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18)
        ])

        configureDateButton(startDateButton, title: "Start Date")
        configureDateButton(endDateButton, title: "End Date")

        startDateButton.addTarget(self, action: #selector(startDateTapped), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(endDateTapped), for: .touchUpInside)

        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.text = "to"
        toLabel.font = .systemFont(ofSize: 13, weight: .medium)
        toLabel.textColor = UIColor(red: 0.48, green: 0.54, blue: 0.64, alpha: 1.0)
        toLabel.textAlignment = .center
        toLabel.setContentHuggingPriority(.required, for: .horizontal)
        toLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        sheetView.addSubview(startDateButton)
        sheetView.addSubview(toLabel)
        sheetView.addSubview(endDateButton)

        NSLayoutConstraint.activate([
            startDateButton.topAnchor.constraint(equalTo: dateRangeTitleLabel.bottomAnchor, constant: 10),
            startDateButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            startDateButton.heightAnchor.constraint(equalToConstant: 38),

            toLabel.centerYAnchor.constraint(equalTo: startDateButton.centerYAnchor),
            toLabel.leadingAnchor.constraint(equalTo: startDateButton.trailingAnchor, constant: 8),
            toLabel.trailingAnchor.constraint(equalTo: endDateButton.leadingAnchor, constant: -8),

            endDateButton.centerYAnchor.constraint(equalTo: startDateButton.centerYAnchor),
            endDateButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -18),
            endDateButton.heightAnchor.constraint(equalToConstant: 38),
            endDateButton.widthAnchor.constraint(equalTo: startDateButton.widthAnchor)
        ])

        configureChipButton(last7DaysButton, title: "Last 7 days")
        configureChipButton(last30DaysButton, title: "Last 30 days")
        configureChipButton(thisTermButton, title: "This term")

        last7DaysButton.addTarget(self, action: #selector(quickDateTapped(_:)), for: .touchUpInside)
        last30DaysButton.addTarget(self, action: #selector(quickDateTapped(_:)), for: .touchUpInside)
        thisTermButton.addTarget(self, action: #selector(quickDateTapped(_:)), for: .touchUpInside)

        let quickRow = UIStackView(arrangedSubviews: [last7DaysButton, last30DaysButton, thisTermButton])
        quickRow.axis = .horizontal
        quickRow.spacing = 8
        quickRow.alignment = .center
        quickRow.distribution = .fill
        quickRow.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(quickRow)

        NSLayoutConstraint.activate([
            quickRow.topAnchor.constraint(equalTo: startDateButton.bottomAnchor, constant: 10),
            quickRow.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            quickRow.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupSortSection() {
        sortTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sortTitleLabel.text = "SORT BY"
        sortTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        sortTitleLabel.textColor = UIColor(red: 0.43, green: 0.49, blue: 0.59, alpha: 1.0)
        sheetView.addSubview(sortTitleLabel)
        NSLayoutConstraint.activate([
            sortTitleLabel.topAnchor.constraint(equalTo: last7DaysButton.bottomAnchor, constant: 14),
            sortTitleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18)
        ])

        sortContainerView.translatesAutoresizingMaskIntoConstraints = false
        sortContainerView.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        sortContainerView.layer.cornerRadius = 12
        sheetView.addSubview(sortContainerView)
        NSLayoutConstraint.activate([
            sortContainerView.topAnchor.constraint(equalTo: sortTitleLabel.bottomAnchor, constant: 10),
            sortContainerView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            sortContainerView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -18),
            sortContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])

        configureSortButton(newestFirstButton, title: "Newest first")
        configureSortButton(oldestFirstButton, title: "Oldest first")
        newestFirstButton.addTarget(self, action: #selector(sortTapped(_:)), for: .touchUpInside)
        oldestFirstButton.addTarget(self, action: #selector(sortTapped(_:)), for: .touchUpInside)
        sortContainerView.addSubview(newestFirstButton)
        sortContainerView.addSubview(oldestFirstButton)

        NSLayoutConstraint.activate([
            newestFirstButton.topAnchor.constraint(equalTo: sortContainerView.topAnchor, constant: 2),
            newestFirstButton.leadingAnchor.constraint(equalTo: sortContainerView.leadingAnchor, constant: 2),
            newestFirstButton.bottomAnchor.constraint(equalTo: sortContainerView.bottomAnchor, constant: -2),
            newestFirstButton.widthAnchor.constraint(equalTo: sortContainerView.widthAnchor, multiplier: 0.5, constant: -3),
            oldestFirstButton.topAnchor.constraint(equalTo: sortContainerView.topAnchor, constant: 2),
            oldestFirstButton.trailingAnchor.constraint(equalTo: sortContainerView.trailingAnchor, constant: -2),
            oldestFirstButton.bottomAnchor.constraint(equalTo: sortContainerView.bottomAnchor, constant: -2),
            oldestFirstButton.leadingAnchor.constraint(equalTo: newestFirstButton.trailingAnchor, constant: 2)
        ])
    }

    private func setupBottomButtons() {
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 1.0), for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        resetButton.backgroundColor = .white
        resetButton.layer.cornerRadius = 12
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor(red: 0.86, green: 0.89, blue: 0.94, alpha: 1.0).cgColor
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        showRemarksButton.translatesAutoresizingMaskIntoConstraints = false
        showRemarksButton.setTitle("Show remarks", for: .normal)
        showRemarksButton.setTitleColor(.white, for: .normal)
        showRemarksButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        showRemarksButton.backgroundColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0)
        showRemarksButton.layer.cornerRadius = 12
        showRemarksButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        sheetView.addSubview(resetButton)
        sheetView.addSubview(showRemarksButton)
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 18),
            resetButton.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -20),
            resetButton.widthAnchor.constraint(equalToConstant: 80),
            resetButton.heightAnchor.constraint(equalToConstant: 42),
            showRemarksButton.leadingAnchor.constraint(equalTo: resetButton.trailingAnchor, constant: 10),
            showRemarksButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -18),
            showRemarksButton.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor),
            showRemarksButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func configureChipButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 0.33, green: 0.39, blue: 0.49, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.87, green: 0.90, blue: 0.95, alpha: 1.0).cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
    }

    private func configureDateButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  \(title)", for: .normal)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = UIColor(red: 0.44, green: 0.50, blue: 0.60, alpha: 1.0)
        button.setTitleColor(UIColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.87, green: 0.90, blue: 0.95, alpha: 1.0).cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    private func configureSortButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 0.45, green: 0.50, blue: 0.60, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        button.backgroundColor = .clear
    }

    private func applyDefaultSelections() {
        if let index = categoriesToShow.firstIndex(where: { $0.id == selectedCategoryId }),
           index < categoryButtons.count {
            setSelectedCategoryButton(categoryButtons[index])
        } else if let firstButton = categoryButtons.first {
            setSelectedCategoryButton(firstButton)
            selectedCategoryId = categoriesToShow.first?.id ?? "all"
        }

        updateDateButtonsUI()

        if isSortNewestFirst {
            setSelectedSortButton(newestFirstButton)
        } else {
            setSelectedSortButton(oldestFirstButton)
        }
    }

    private func setSelectedCategoryButton(_ selectedButton: UIButton) {
        for button in categoryButtons {
            button.backgroundColor = .white
            button.setTitleColor(UIColor(red: 0.33, green: 0.39, blue: 0.49, alpha: 1.0), for: .normal)
            button.layer.borderColor = UIColor(red: 0.87, green: 0.90, blue: 0.95, alpha: 1.0).cgColor
        }
        selectedButton.backgroundColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0)
        selectedButton.setTitleColor(.white, for: .normal)
        selectedButton.layer.borderColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0).cgColor
        selectedCategoryButton = selectedButton
    }

    private func setSelectedQuickDateButton(_ selectedButton: UIButton) {
        clearQuickDateSelection()
        selectedButton.backgroundColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0)
        selectedButton.setTitleColor(.white, for: .normal)
        selectedButton.layer.borderColor = UIColor(red: 0.24, green: 0.47, blue: 0.92, alpha: 1.0).cgColor
        selectedQuickDateButton = selectedButton
    }

    private func clearQuickDateSelection() {
        let buttons = [last7DaysButton, last30DaysButton, thisTermButton]
        for button in buttons {
            button.backgroundColor = .white
            button.setTitleColor(UIColor(red: 0.33, green: 0.39, blue: 0.49, alpha: 1.0), for: .normal)
            button.layer.borderColor = UIColor(red: 0.87, green: 0.90, blue: 0.95, alpha: 1.0).cgColor
        }
        selectedQuickDateButton = nil
    }

    private func updateDateButtonsUI() {
        if let start = selectedStartDate {
            startDateButton.setTitle("  \(displayDateFormatter.string(from: start))", for: .normal)
        } else {
            startDateButton.setTitle("  Start Date", for: .normal)
        }
        if let end = selectedEndDate {
            endDateButton.setTitle("  \(displayDateFormatter.string(from: end))", for: .normal)
        } else {
            endDateButton.setTitle("  End Date", for: .normal)
        }
        startDateButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        endDateButton.setImage(UIImage(systemName: "calendar"), for: .normal)
    }

    @objc private func startDateTapped() {
        presentCalendar(isStartDate: true)
    }

    @objc private func endDateTapped() {
        presentCalendar(isStartDate: false)
    }

    private func presentCalendar(isStartDate: Bool) {
        let pickerVC = CalendarPickerVC()
        pickerVC.titleText = isStartDate ? "Select Start Date" : "Select End Date"
        pickerVC.initialDate = (isStartDate ? selectedStartDate : selectedEndDate) ?? Date()

        if !isStartDate, let start = selectedStartDate {
            pickerVC.minimumDate = start
        }

        pickerVC.onDateSelected = { [weak self] pickedDate in
            guard let self = self else { return }
            if isStartDate {
                self.selectedStartDate = pickedDate
                if let end = self.selectedEndDate, end < pickedDate {
                    self.selectedEndDate = pickedDate
                }
            } else {
                self.selectedEndDate = pickedDate
                if let start = self.selectedStartDate, start > pickedDate {
                    self.selectedStartDate = pickedDate
                }
            }
            self.clearQuickDateSelection()
            self.updateDateButtonsUI()
        }

        pickerVC.modalPresentationStyle = .overFullScreen
        pickerVC.modalTransitionStyle = .crossDissolve
        present(pickerVC, animated: true)
    }

    @objc private func quickDateTapped(_ sender: UIButton) {
        setSelectedQuickDateButton(sender)
        let calendar = Calendar.current
        let today = Date()
        selectedEndDate = today

        if sender == last7DaysButton {
            selectedStartDate = calendar.date(byAdding: .day, value: -7, to: today)
        } else if sender == last30DaysButton {
            selectedStartDate = calendar.date(byAdding: .day, value: -30, to: today)
        } else if sender == thisTermButton {
            selectedStartDate = calendar.date(byAdding: .month, value: -3, to: today)
        }
        updateDateButtonsUI()
    }

    private func setSelectedSortButton(_ selectedButton: UIButton) {
        let buttons = [newestFirstButton, oldestFirstButton]
        for button in buttons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(red: 0.45, green: 0.50, blue: 0.60, alpha: 1.0), for: .normal)
        }
        selectedButton.backgroundColor = .white
        selectedButton.setTitleColor(UIColor(red: 0.20, green: 0.24, blue: 0.32, alpha: 1.0), for: .normal)
        isSortNewestFirst = (selectedButton == newestFirstButton)
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        setSelectedCategoryButton(sender)
        if sender.tag >= 0 && sender.tag < categoriesToShow.count {
            selectedCategoryId = categoriesToShow[sender.tag].id
        }
    }

    @objc private func sortTapped(_ sender: UIButton) {
        setSelectedSortButton(sender)
    }

    @objc private func resetTapped() {
        selectedCategoryId = "all"
        selectedStartDate = nil
        selectedEndDate = nil
        isSortNewestFirst = true

        if let firstButton = categoryButtons.first {
            setSelectedCategoryButton(firstButton)
        }
        clearQuickDateSelection()
        updateDateButtonsUI()
        setSelectedSortButton(newestFirstButton)
    }

    @objc private func applyTapped() {
        onApplyFilter?(selectedCategoryId, selectedStartDate, selectedEndDate, isSortNewestFirst)
        dismissSheet()
    }

    @objc private func dismissSheet() {
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 440)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - RemarkItem Date Parsing Extension
extension RemarkItem {
    var parsedDate: Date? {
        let ymdFormatter = DateFormatter()
        ymdFormatter.dateFormat = "yyyy-MM-dd"
        ymdFormatter.locale = Locale(identifier: "en_US_POSIX")
        ymdFormatter.timeZone = TimeZone.current
        if let d = ymdFormatter.date(from: date) {
            return d
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: created_at) {
            return d
        }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: created_at) {
            return d
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        fallbackFormatter.timeZone = TimeZone.current
        for format in ["yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss", "dd-MM-yyyy", "dd/MM/yyyy"] {
            fallbackFormatter.dateFormat = format
            if let d = fallbackFormatter.date(from: date) ?? fallbackFormatter.date(from: created_at) {
                return d
            }
        }
        return nil
    }
}
