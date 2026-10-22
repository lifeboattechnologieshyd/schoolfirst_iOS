//
//  LeaveapplyVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 19/10/26.
//

import UIKit

class LeaveapplyVC: UIViewController {

    @IBOutlet weak var Backbutton: UIButton!
    @IBOutlet weak var Tableview: UITableView!

    private let leaveCellID = "leaveapplyTableViewCell"

    // MARK: - Form State

    private var fromDate: Date?
    private var toDate: Date?
    private var selectedLeaveType: LeaveApplyTypeOption?
    private var leaveTypeOptions: [LeaveApplyTypeOption] = []
    private var isSubmitting = false

    private enum DateField {
        case from
        case to
    }

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    /// API expects "yyyy-MM-dd"
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        Backbutton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        fetchLeaveTypes()
    }

    // MARK: - Back Button Action

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup TableView

    private func setupTableView() {
        Tableview.delegate = self
        Tableview.dataSource = self
        Tableview.separatorStyle = .none
        Tableview.showsVerticalScrollIndicator = false

        let nib = UINib(nibName: "leaveapplyTableViewCell", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: leaveCellID)

        Tableview.tableFooterView = UIView()
    }

    // MARK: - Fetch Leave Types (from API)

    private func fetchLeaveTypes() {
        let studentID = UserManager.shared.resolvedStudentID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let schoolID = UserManager.shared.resolvedSchoolID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !studentID.isEmpty else {
            print("❌ Leave types: studentID is empty")
            return
        }

        guard !schoolID.isEmpty else {
            print("❌ Leave types: schoolID is empty")
            return
        }

        NetworkManager.shared.request<LeaveListDataWrapper>(
            urlString: API.STUDENT_LEAVE_REQUESTS,
            method: .GET,
            requiresAuth: true,
            parameters: [
                "student_id": studentID
            ],
            headers: [
                "x-school-id": schoolID
            ],
            completion: { [weak self] (result: Result<APIResponse<LeaveListDataWrapper>, NetworkError>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    switch result {
                    case .success(let response):
                        guard response.success else {
                            self.leaveTypeOptions = []
                            return
                        }

                        let items = response.data?.data ?? []
                        self.leaveTypeOptions = self.makeLeaveTypeOptions(from: items)

                    case .failure(let error):
                        print("❌ Leave types error: \(error.localizedDescription)")
                        self.leaveTypeOptions = []
                    }
                }
            }
        )
    }

    /// Builds unique leave types from the API, keeping the API order.
    private func makeLeaveTypeOptions(from items: [LeaveListItem]) -> [LeaveApplyTypeOption] {
        var seen = Set<String>()
        var options: [LeaveApplyTypeOption] = []

        for item in items {
            let raw = item.leaveType
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased()

            guard !raw.isEmpty, !seen.contains(raw) else { continue }

            seen.insert(raw)
            options.append(
                LeaveApplyTypeOption(
                    rawValue: raw,
                    title: LeaveapplyVC.leaveTypeTitle(for: raw)
                )
            )
        }

        return options
    }

    private static func leaveTypeTitle(for raw: String) -> String {
        switch raw {
        case "SICK":
            return "Sick Leave"
        case "CASUAL":
            return "Casual Leave"
        case "EMERGENCY":
            return "Emergency Leave"
        case "OTHER":
            return "Other Leave"
        default:
            let readable = raw.replacingOccurrences(of: "_", with: " ").capitalized
            return "\(readable) Leave"
        }
    }

    // MARK: - Cell Helpers

    private func leaveCell() -> leaveapplyTableViewCell? {
        return Tableview.cellForRow(at: IndexPath(row: 0, section: 0)) as? leaveapplyTableViewCell
    }

    private func refreshLeaveCell() {
        guard let cell = leaveCell() else { return }
        applyState(to: cell)
    }

    private func applyState(to cell: leaveapplyTableViewCell) {
        cell.setFromDateText(fromDate.map { displayString(for: $0) })
        cell.setToDateText(toDate.map { displayString(for: $0) })
        cell.setLeaveTypeText(selectedLeaveType?.title)
        cell.setDurationText(durationDisplayText())
    }

    private func displayString(for date: Date) -> String {
        return LeaveapplyVC.displayFormatter.string(from: date)
    }

    /// "1 day" / "2 days" shown in Durationtextfield (display only)
    private func durationDisplayText() -> String? {
        guard let fromDate = fromDate, let toDate = toDate else { return nil }

        let calendar = Calendar.current
        let from = calendar.startOfDay(for: fromDate)
        let to = calendar.startOfDay(for: toDate)

        guard to >= from else { return nil }

        let dayCount = (calendar.dateComponents([.day], from: from, to: to).day ?? 0) + 1
        return dayCount == 1 ? "1 day" : "\(dayCount) days"
    }

    // MARK: - Date Picker Card

    private func presentDatePicker(for field: DateField) {
        let today = Calendar.current.startOfDay(for: Date())

        let title: String
        let initialDate: Date
        let minimumDate: Date?

        switch field {
        case .from:
            title = "Select From Date"
            initialDate = fromDate ?? today
            minimumDate = nil

        case .to:
            title = "Select To Date"
            initialDate = toDate ?? fromDate ?? today
            minimumDate = fromDate
        }

        let card = LeaveApplyDatePickerCard(
            title: title,
            initialDate: initialDate,
            minimumDate: minimumDate
        ) { [weak self] date in
            self?.applyDate(date, to: field)
        }

        present(card, animated: true)
    }

    private func applyDate(_ date: Date, to field: DateField) {
        let day = Calendar.current.startOfDay(for: date)

        switch field {
        case .from:
            fromDate = day

            // Keep the To date valid when From moves past it.
            if let currentTo = toDate, currentTo < day {
                toDate = day
            }

        case .to:
            toDate = day
        }

        refreshLeaveCell()
    }

    // MARK: - Leave Type Card

    private func presentLeaveTypePicker() {
        let card = LeaveApplyTypeCard(
            options: leaveTypeOptions,
            selectedRawValue: selectedLeaveType?.rawValue
        ) { [weak self] option in
            guard let self = self else { return }
            self.selectedLeaveType = option
            self.refreshLeaveCell()
        }

        present(card, animated: true)
    }

    // MARK: - Submit Leave Request

    private func handleSubmitTapped() {
        guard !isSubmitting else { return }
        guard let cell = leaveCell() else { return }

        // --- 1. Collect inputs ---
        let reason = (cell.Reasontextfield.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Note is OPTIONAL
        let note = (cell.Notetextfield.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // --- 2. Validation ---
        guard let leaveType = selectedLeaveType else {
            showAlert(title: "Missing Field", message: "Please select a leave type.")
            return
        }

        guard let fromDate = fromDate else {
            showAlert(title: "Missing Field", message: "Please select from date.")
            return
        }

        guard let toDate = toDate else {
            showAlert(title: "Missing Field", message: "Please select to date.")
            return
        }

        guard toDate >= fromDate else {
            showAlert(title: "Invalid Dates", message: "To date must be the same or after from date.")
            return
        }

        guard !reason.isEmpty else {
            showAlert(title: "Missing Field", message: "Please enter a reason.")
            return
        }

        // --- 3. Session IDs ---
        let studentID = UserManager.shared.resolvedStudentID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let schoolID = UserManager.shared.resolvedSchoolID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !studentID.isEmpty else {
            showAlert(title: "Error", message: "Student ID not found. Please login again.")
            return
        }

        guard !schoolID.isEmpty else {
            showAlert(title: "Error", message: "School ID not found. Please login again.")
            return
        }

        // --- 4. Build leave_days (each day = FULL_DAY) ---
        let leaveDays = buildLeaveDays(from: fromDate, to: toDate, duration: "FULL_DAY")

        guard !leaveDays.isEmpty else {
            showAlert(title: "Invalid Dates", message: "Please select a valid date range.")
            return
        }

        // --- 5. Compose final reason (append optional note) ---
        var finalReason = reason
        if !note.isEmpty {
            finalReason += "\nNote: \(note)"
        }

        // --- 6. Parameters for NetworkManager ---
        let leaveDaysPayload: [[String: Any]] = leaveDays.map {
            [
                "date": $0.date,
                "duration": $0.duration
            ]
        }

        let parameters: [String: Any] = [
            "student_id": studentID,
            "leave_type": leaveType.rawValue,
            "leave_days": leaveDaysPayload,
            "reason": finalReason,
            "pdf": NSNull()
        ]

        // --- 7. Submit ---
        submitLeave(parameters: parameters, schoolID: schoolID)
    }

    /// Builds leave_days between from and to (inclusive). Each day uses given duration.
    private func buildLeaveDays(
        from: Date,
        to: Date,
        duration: String
    ) -> [LeaveDayRequest] {
        var days: [LeaveDayRequest] = []
        let calendar = Calendar.current
        var current = calendar.startOfDay(for: from)
        let last = calendar.startOfDay(for: to)

        while current <= last {
            let dateString = LeaveapplyVC.apiDateFormatter.string(from: current)
            days.append(LeaveDayRequest(date: dateString, duration: duration))

            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        return days
    }

    private func submitLeave(parameters: [String: Any], schoolID: String) {
        isSubmitting = true
        leaveCell()?.Submitrequestbutton.isEnabled = false

        NetworkManager.shared.request<LeaveApplyData>(
            urlString: API.APPLY_STUDENT_LEAVE,
            method: .POST,
            requiresAuth: true,
            parameters: parameters,
            headers: [
                "x-school-id": schoolID,
                "Content-Type": "application/json"
            ],
            completion: { [weak self] (result: Result<APIResponse<LeaveApplyData>, NetworkError>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    self.isSubmitting = false
                    self.leaveCell()?.Submitrequestbutton.isEnabled = true

                    switch result {
                    case .success(let response):
                        // HTTP 2xx — check business success flag
                        if response.success {
                            self.resetForm()
                            // Navigate to the Success Screen passing the response data
                            self.openSuccessScreen(with: response.data)
                        } else {
                            // e.g. "Leave already exists for the following dates: ..."
                            let msg = response.description.isEmpty
                                ? "Could not submit leave request."
                                : response.description
                            self.showAlert(title: "Error", message: msg)
                        }

                    case .failure(let error):
                        // NetworkManager already shows AlertManager for HTTP errors.
                        print("❌ Submit leave error: \(error.localizedDescription)")
                    }
                }
            }
        )
    }

    // MARK: - Navigation to Success Screen
    
    private func openSuccessScreen(with data: LeaveApplyData?) {
        let vc = LeaverequestsuccessVC()

        let start: String
        let end: String
        let leaveID: String
        let status: String
        let hasPDF: Bool

        if let data = data {
            leaveID = data.leaveID
            start = data.startDate
            end = data.endDate
            status = data.status
            hasPDF = (data.pdf != nil && !(data.pdf?.isEmpty ?? true))
        } else {
            leaveID = UUID().uuidString
            start = fromDate.map { LeaveapplyVC.apiDateFormatter.string(from: $0) } ?? ""
            end = toDate.map { LeaveapplyVC.apiDateFormatter.string(from: $0) } ?? start
            status = "PENDING"
            hasPDF = false
        }

        let sentTo = "Class teacher"

        vc.displayData = LeaveSuccessDisplayData(
            leaveID: leaveID,
            startDate: start,
            endDate: end,
            status: status.isEmpty ? "PENDING" : status,
            documentAttached: hasPDF,
            sentToText: sentTo
        )

        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func resetForm() {
        fromDate = nil
        toDate = nil
        selectedLeaveType = nil

        if let cell = leaveCell() {
            cell.Reasontextfield.text = ""
            cell.Notetextfield.text = ""
            applyState(to: cell)
        }
    }

    // MARK: - Alert Helper

    private func showAlert(
        title: String,
        message: String,
        onOK: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension LeaveapplyVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: leaveCellID,
            for: indexPath
        ) as? leaveapplyTableViewCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none

        cell.onFromDateTap = { [weak self] in
            self?.presentDatePicker(for: .from)
        }

        cell.onToDateTap = { [weak self] in
            self?.presentDatePicker(for: .to)
        }

        cell.onLeaveTypeTap = { [weak self] in
            self?.presentLeaveTypePicker()
        }

        cell.onSubmitTap = { [weak self] in
            self?.handleSubmitTapped()
        }

        applyState(to: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}

// MARK: - Leave Type Option

fileprivate struct LeaveApplyTypeOption {
    let rawValue: String   // e.g. "SICK" (from API)
    let title: String      // e.g. "Sick Leave" (shown in UI)
}

// MARK: - Date Picker Card

fileprivate final class LeaveApplyDatePickerCard: UIViewController {

    private let cardTitle: String
    private let initialDate: Date
    private let minimumDate: Date?
    private let onConfirm: (Date) -> Void

    private let dimView = UIView()
    private let cardView = UIView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let buttonStack = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)

    init(
        title: String,
        initialDate: Date,
        minimumDate: Date?,
        onConfirm: @escaping (Date) -> Void
    ) {
        self.cardTitle = title
        self.initialDate = initialDate
        self.minimumDate = minimumDate
        self.onConfirm = onConfirm

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        )

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        titleLabel.text = cardTitle
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)
        titleLabel.textAlignment = .center

        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.date = initialDate
        datePicker.minimumDate = minimumDate

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        cancelButton.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        doneButton.backgroundColor = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)
        doneButton.layer.cornerRadius = 10
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(doneButton)

        cancelButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 46).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(datePicker)
        contentStack.addArrangedSubview(buttonStack)
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let selected = datePicker.date
        let confirm = onConfirm
        dismiss(animated: true) {
            confirm(selected)
        }
    }
}

// MARK: - Leave Type Card

fileprivate final class LeaveApplyTypeCard: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let options: [LeaveApplyTypeOption]
    private let selectedRawValue: String?
    private let onSelect: (LeaveApplyTypeOption) -> Void

    private let dimView = UIView()
    private let cardView = UIView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let cancelButton = UIButton(type: .system)

    private let cellID = "LeaveApplyTypeCell"
    private let rowHeight: CGFloat = 52
    private let maxTableHeight: CGFloat = 260

    init(
        options: [LeaveApplyTypeOption],
        selectedRawValue: String?,
        onSelect: @escaping (LeaveApplyTypeOption) -> Void
    ) {
        self.options = options
        self.selectedRawValue = selectedRawValue
        self.onSelect = onSelect

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
    }

    private func setupLayout() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        )

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        titleLabel.text = "Leave Type"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)
        titleLabel.textAlignment = .center

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let tableHeight = min(CGFloat(options.count) * rowHeight, maxTableHeight)
        tableView.heightAnchor.constraint(equalToConstant: max(tableHeight, rowHeight)).isActive = true
        tableView.isHidden = options.isEmpty

        emptyLabel.text = "No leave types found.\nLeave types appear after leave requests are loaded."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.isHidden = !options.isEmpty

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        cancelButton.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.heightAnchor.constraint(equalToConstant: 46).isActive = true

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(tableView)
        contentStack.addArrangedSubview(emptyLabel)
        contentStack.addArrangedSubview(cancelButton)
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: 360),

            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let option = options[indexPath.row]

        cell.textLabel?.text = option.title
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.textLabel?.textColor = UIColor(red: 0.02, green: 0.19, blue: 0.38, alpha: 1)
        cell.accessoryType = option.rawValue == selectedRawValue ? .checkmark : .none
        cell.tintColor = UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1)

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let option = options[indexPath.row]
        let select = onSelect

        dismiss(animated: true) {
            select(option)
        }
    }
}
