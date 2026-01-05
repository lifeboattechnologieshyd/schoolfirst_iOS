//
//  SubmitLeaveTableCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 03/11/25.
//

import UIKit

class SubmitLeaveTableCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dateVw: UIView!
    @IBOutlet weak var sessionVw: UIView!
    @IBOutlet weak var todateVw: UIView!
    @IBOutlet weak var tosessionVw: UIView!
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var multipleVw: UIView!
    @IBOutlet weak var singleVw: UIView!
    
    @IBOutlet weak var issueTf: UITextField!
    @IBOutlet weak var tellusTv: UITextView!
    @IBOutlet weak var todateTf: UITextField!
    @IBOutlet weak var dateTf: UITextField!
    
    @IBOutlet weak var singledayButton: UIButton!
    @IBOutlet weak var multipledaysButton: UIButton!
    
    @IBOutlet weak var changedate: UIButton!
    @IBOutlet weak var adddateButton: UIButton!
    @IBOutlet weak var issuesbutton: UIButton!
    
    @IBOutlet weak var fulldayButton: UIButton!
    @IBOutlet weak var halfdayButton: UIButton!
    
    @IBOutlet weak var firstHalfButton: UIButton!
    @IBOutlet weak var secondHalfButton: UIButton!
    
    @IBOutlet weak var tofullday: UIButton!
    @IBOutlet weak var tohalfDay: UIButton!
    
    @IBOutlet weak var tofirstHalf: UIButton!
    @IBOutlet weak var toSecondHalf: UIButton!
    
    @IBOutlet weak var colVw: UICollectionView!
    
    @IBOutlet weak var todateTfHeight: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var sessionHeight: NSLayoutConstraint!
    @IBOutlet weak var todateHeight: NSLayoutConstraint!
    @IBOutlet weak var tosessionHeight: NSLayoutConstraint!
    @IBOutlet weak var reasonHeight: NSLayoutConstraint!
    
    let selectedBgColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
    let selectedTextColor = UIColor(red: 254/255, green: 242/255, blue: 0/255, alpha: 1)
    let unselectedBgColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1)
    let unselectedTextColor = UIColor.black
    
    let issueReasons = [
        "Fever / Health Issue",
        "Family Function",
        "Emergency Situation",
        "Travel",
        "Other"
    ]
    
    var selectedIssue: String = ""
    var selectedDate: Date?
    var selectedToDate: Date?
    
    enum LeaveType {
        case singleDay
        case halfDay
        case multipleDays
    }
    
    var currentLeaveType: LeaveType = .singleDay
    var selectedFromDayType: String = "Fullday"
    var selectedFromSession: String = "Firsthalf"
    var selectedToDayType: String = "Fullday"
    var selectedToSession: String = "Firsthalf"
    
    var kids: [Student] = []
    var selected_student: Int = 0
    
    var onKidSelected: ((Int) -> Void)?
    var onLayoutUpdate: ((CGFloat) -> Void)?
    
    private let kidsCollectionHeight: CGFloat = 90
    private let selectionButtonsHeight: CGFloat = 80
    private let topPadding: CGFloat = 16
    private let bottomPadding: CGFloat = 30
    
    private let dateViewHeight: CGFloat = 140
    private let sessionViewHeight: CGFloat = 80
    private let toDateViewHeight: CGFloat = 140
    private let tosessionViewHeight: CGFloat = 80
    private let reasonViewHeight: CGFloat = 280
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
        setupInitialState()
        setupTextView()
        setupToDateTextField()
        setupButtonStyles()
        applyStyles()
    }
    
    func setupCollectionView() {
        colVw.register(
            UINib(nibName: "KidSelectionCell", bundle: nil),
            forCellWithReuseIdentifier: "KidSelectionCell"
        )
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    func setupToDateTextField() {
        todateTfHeight.constant = 48
    }
    
    func setupInitialState() {
        hideView(dateVw, heightConstraint: dateHeight)
        hideView(sessionVw, heightConstraint: sessionHeight)
        hideView(todateVw, heightConstraint: todateHeight)
        hideView(tosessionVw, heightConstraint: tosessionHeight)
        hideView(reasonVw, heightConstraint: reasonHeight)
        
        singleVw.layer.borderWidth = 0
        multipleVw.layer.borderWidth = 0
        
        tellusTv.text = "Enter your reason here..."
        tellusTv.textColor = .lightGray
        
        self.contentView.layoutIfNeeded()
    }
    
    func setupTextView() {
        tellusTv.delegate = self
        tellusTv.layer.cornerRadius = 8
        tellusTv.layer.borderWidth = 1
        tellusTv.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }
    
    func setupButtonStyles() {
        let allButtons: [UIButton?] = [
            fulldayButton, halfdayButton,
            firstHalfButton, secondHalfButton,
            tofullday, tohalfDay,
            tofirstHalf, toSecondHalf
        ]
        
        for button in allButtons {
            button?.layer.cornerRadius = 8
            button?.clipsToBounds = true
        }
        
        setAllButtonsUnselected()
    }
    
    func setAllButtonsUnselected() {
        deselectButton(fulldayButton)
        deselectButton(halfdayButton)
        deselectButton(firstHalfButton)
        deselectButton(secondHalfButton)
        deselectButton(tofullday)
        deselectButton(tohalfDay)
        deselectButton(tofirstHalf)
        deselectButton(toSecondHalf)
    }
    
    func applyStyles() {
        issueTf.applyDropShadow()
        todateTf.applyDropShadow()
        dateTf.applyDropShadow()
        tellusTv.applyDropShadow()
        
        singleVw.layer.cornerRadius = 8
        multipleVw.layer.cornerRadius = 8
    }
    
    func selectButton(_ button: UIButton?) {
        guard let button = button else { return }
        button.backgroundColor = selectedBgColor
        button.setTitleColor(selectedTextColor, for: .normal)
        button.tintColor = selectedTextColor
    }
    
    func deselectButton(_ button: UIButton?) {
        guard let button = button else { return }
        button.backgroundColor = unselectedBgColor
        button.setTitleColor(unselectedTextColor, for: .normal)
        button.tintColor = unselectedTextColor
    }
    
    func updateFromDayTypeButtons(isFullday: Bool) {
        if isFullday {
            selectButton(fulldayButton)
            deselectButton(halfdayButton)
        } else {
            deselectButton(fulldayButton)
            selectButton(halfdayButton)
        }
    }
    
    func updateFromSessionButtons(isFirstHalf: Bool) {
        if isFirstHalf {
            selectButton(firstHalfButton)
            deselectButton(secondHalfButton)
        } else {
            deselectButton(firstHalfButton)
            selectButton(secondHalfButton)
        }
    }
    
    func updateToDayTypeButtons(isFullday: Bool) {
        if isFullday {
            selectButton(tofullday)
            deselectButton(tohalfDay)
        } else {
            deselectButton(tofullday)
            selectButton(tohalfDay)
        }
    }
    
    func updateToSessionButtons(isFirstHalf: Bool) {
        if isFirstHalf {
            selectButton(tofirstHalf)
            deselectButton(toSecondHalf)
        } else {
            deselectButton(tofirstHalf)
            selectButton(toSecondHalf)
        }
    }
    
    func showView(_ view: UIView, heightConstraint: NSLayoutConstraint, height: CGFloat) {
        view.isHidden = false
        view.alpha = 1
        heightConstraint.constant = height
    }
    
    func hideView(_ view: UIView, heightConstraint: NSLayoutConstraint) {
        view.isHidden = true
        view.alpha = 0
        heightConstraint.constant = 0
    }
    
    func configureWithKids(kids: [Student], selectedIndex: Int = 0) {
        self.kids = kids
        self.selected_student = selectedIndex
        self.colVw.reloadData()
        
        if !kids.isEmpty && selectedIndex < kids.count {
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            DispatchQueue.main.async {
                self.colVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func getSelectedStudentId() -> String {
        guard !kids.isEmpty, selected_student < kids.count else {
            return ""
        }
        return kids[selected_student].studentID
    }
    
    func clearHighlights() {
        singleVw.layer.borderWidth = 0
        multipleVw.layer.borderWidth = 0
    }

    func highlightSelected(view: UIView) {
        clearHighlights()
        view.layer.borderWidth = 1.5
        view.layer.borderColor = selectedBgColor.cgColor
        view.layer.cornerRadius = 8
    }
    
    func calculateTotalHeight() -> CGFloat {
        var totalHeight: CGFloat = kidsCollectionHeight + selectionButtonsHeight + topPadding
        
        if !dateVw.isHidden && dateHeight.constant > 0 {
            totalHeight += dateHeight.constant
        }
        
        if !sessionVw.isHidden && sessionHeight.constant > 0 {
            totalHeight += sessionHeight.constant
        }
        
        if !todateVw.isHidden && todateHeight.constant > 0 {
            totalHeight += todateHeight.constant
        }
        
        if !tosessionVw.isHidden && tosessionHeight.constant > 0 {
            totalHeight += tosessionHeight.constant
        }
        
        if !reasonVw.isHidden && reasonHeight.constant > 0 {
            totalHeight += reasonHeight.constant
        }
        
        totalHeight += bottomPadding
         
        return totalHeight
    }

    func refreshLayout() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        let newHeight = calculateTotalHeight()
        
        DispatchQueue.main.async {
            self.onLayoutUpdate?(newHeight)
        }
    }
    
    func findParentTableView() -> UITableView? {
        var view: UIView? = self.superview
        while view != nil {
            if let tableView = view as? UITableView {
                return tableView
            }
            view = view?.superview
        }
        return nil
    }
    
    @IBAction func onClickSingleDay(_ sender: UIButton) {
        currentLeaveType = .singleDay
        selectedFromDayType = "Fullday"
        selectedToDayType = "Fullday"
        
        showView(dateVw, heightConstraint: dateHeight, height: dateViewHeight)
        showView(reasonVw, heightConstraint: reasonHeight, height: reasonViewHeight)
        
        hideView(sessionVw, heightConstraint: sessionHeight)
        hideView(todateVw, heightConstraint: todateHeight)
        hideView(tosessionVw, heightConstraint: tosessionHeight)
        
        setAllButtonsUnselected()
        
        highlightSelected(view: singleVw)
        refreshLayout()
    }

    

    @IBAction func onClickMultipleDays(_ sender: UIButton) {
        currentLeaveType = .multipleDays
        selectedFromDayType = "Fullday"
        selectedToDayType = "Fullday"
        
        showView(dateVw, heightConstraint: dateHeight, height: dateViewHeight)
        showView(todateVw, heightConstraint: todateHeight, height: toDateViewHeight)
        showView(reasonVw, heightConstraint: reasonHeight, height: reasonViewHeight)
        
        hideView(sessionVw, heightConstraint: sessionHeight)
        hideView(tosessionVw, heightConstraint: tosessionHeight)
        
        highlightSelected(view: multipleVw)
        refreshLayout()
        
        DispatchQueue.main.async {
            self.updateFromDayTypeButtons(isFullday: true)
            self.updateToDayTypeButtons(isFullday: true)
        }
    }
    
    @IBAction func onClickFullday(_ sender: UIButton) {
        selectedFromDayType = "Fullday"
        hideView(sessionVw, heightConstraint: sessionHeight)
        updateFromDayTypeButtons(isFullday: true)
        refreshLayout()
    }
    
    @IBAction func onClickFromHalfday(_ sender: UIButton) {
        selectedFromDayType = "Halfday"
        selectedFromSession = "Firsthalf"
        showView(sessionVw, heightConstraint: sessionHeight, height: sessionViewHeight)
        updateFromDayTypeButtons(isFullday: false)
        refreshLayout()
        
        DispatchQueue.main.async {
            self.updateFromSessionButtons(isFirstHalf: true)
        }
    }
    
    @IBAction func onClickFirstHalf(_ sender: UIButton) {
        selectedFromSession = "Firsthalf"
        updateFromSessionButtons(isFirstHalf: true)
    }
    
    @IBAction func onClickSecondHalf(_ sender: UIButton) {
        selectedFromSession = "Secondhalf"
        updateFromSessionButtons(isFirstHalf: false)
    }
    
    @IBAction func onClickToFullDay(_ sender: UIButton) {
        selectedToDayType = "Fullday"
        hideView(tosessionVw, heightConstraint: tosessionHeight)
        updateToDayTypeButtons(isFullday: true)
        refreshLayout()
    }

    @IBAction func onClickToHalfDay(_ sender: UIButton) {
        selectedToDayType = "Halfday"
        selectedToSession = "Firsthalf"
        showView(tosessionVw, heightConstraint: tosessionHeight, height: tosessionViewHeight)
        updateToDayTypeButtons(isFullday: false)
        refreshLayout()
        
        DispatchQueue.main.async {
            self.updateToSessionButtons(isFirstHalf: true)
        }
    }
    
    @IBAction func onClickToFirstHalf(_ sender: UIButton) {
        selectedToSession = "Firsthalf"
        updateToSessionButtons(isFirstHalf: true)
    }
    
    @IBAction func onClickToSecondHalf(_ sender: UIButton) {
        selectedToSession = "Secondhalf"
        updateToSessionButtons(isFirstHalf: false)
    }

    @IBAction func onClickChangeDate(_ sender: UIButton) {
        openDatePicker(isToDate: false)
    }
    
    @IBAction func onClickAddDate(_ sender: UIButton) {
        openDatePicker(isToDate: true)
    }

    func openDatePicker(isToDate: Bool = false) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        let alert = UIAlertController(
            title: isToDate ? "Select To Date" : "Select Date",
            message: "\n\n\n\n\n\n\n\n",
            preferredStyle: .alert
        )

        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.widthAnchor.constraint(equalToConstant: 270),
            datePicker.heightAnchor.constraint(equalToConstant: 150)
        ])

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let dateString = formatter.string(from: datePicker.date)
            
            if isToDate {
                self.selectedToDate = datePicker.date
                self.todateTf.text = dateString
            } else {
                self.selectedDate = datePicker.date
                self.dateTf.text = dateString
                
                if self.currentLeaveType == .singleDay || self.currentLeaveType == .halfDay {
                    self.selectedToDate = datePicker.date
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        parentViewController()?.present(alert, animated: true)
    }

    @IBAction func onClickIssue(_ sender: UIButton) {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self

        let alert = UIAlertController(
            title: "Select Issue",
            message: "\n\n\n\n\n\n\n",
            preferredStyle: .alert
        )

        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            picker.widthAnchor.constraint(equalToConstant: 270),
            picker.heightAnchor.constraint(equalToConstant: 150)
        ])

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let selectedRow = picker.selectedRow(inComponent: 0)
            self.selectedIssue = self.issueReasons[selectedRow]
            self.issueTf.text = self.selectedIssue
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        parentViewController()?.present(alert, animated: true)
    }
    
    func getLeaveParameters() -> [String: Any]? {
        
        let studentId = getSelectedStudentId()
        guard !studentId.isEmpty else {
            showAlert(title: "Error", message: "Please select a student")
            return nil
        }
        
        guard let fromDate = selectedDate else {
            showAlert(title: "Error", message: "Please select a date")
            return nil
        }
        
        var toDate = fromDate
        if currentLeaveType == .multipleDays {
            guard let selectedTo = selectedToDate else {
                showAlert(title: "Error", message: "Please select end date")
                return nil
            }
            toDate = selectedTo
            
            if toDate < fromDate {
                showAlert(title: "Error", message: "End date must be after start date")
                return nil
            }
        }
        
        guard !selectedIssue.isEmpty else {
            showAlert(title: "Error", message: "Please select issue type")
            return nil
        }
        
        let reason = tellusTv.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty, reason != "Enter your reason here..." else {
            showAlert(title: "Error", message: "Please enter reason for leave")
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let fromDateString = dateFormatter.string(from: fromDate)
        let toDateString = dateFormatter.string(from: toDate)
        
        var fromDayType = "Fullday"
        var toDayType = "Fullday"
        var fromSession = "Fullday"
        var toSession = "Fullday"
        
        switch currentLeaveType {
        case .singleDay:
            fromDayType = "Fullday"
            toDayType = "Fullday"
            fromSession = "Fullday"
            toSession = "Fullday"
            
        case .halfDay:
            fromDayType = "Halfday"
            toDayType = "Halfday"
            fromSession = selectedFromSession
            toSession = selectedFromSession
            
        case .multipleDays:
            fromDayType = selectedFromDayType
            toDayType = selectedToDayType
            fromSession = (selectedFromDayType == "Fullday") ? "Fullday" : selectedFromSession
            toSession = (selectedToDayType == "Fullday") ? "Fullday" : selectedToSession
        }
        
        let reasonType = mapIssueToReasonType(selectedIssue)
        
        var params: [String: Any] = [
            "student_id": studentId,
            "from_date": fromDateString,
            "to_date": toDateString,
            "from_day_type": fromDayType,
            "to_day_type": toDayType,
            "from_session": fromSession,
            "to_session": toSession,
            "reason_type": reasonType,
            "reason": reason
        ]
        
        params["document"] = NSNull()
        
        return params
    }
    
    func mapIssueToReasonType(_ issue: String) -> String {
        switch issue {
        case "Fever / Health Issue":
            return "Health"
        case "Family Function":
            return "Family"
        case "Emergency Situation":
            return "Emergency"
        case "Travel":
            return "Travel"
        default:
            return "Other"
        }
    }
    
    func showAlert(title: String, message: String) {
        if let vc = parentViewController() {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issueReasons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issueReasons[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIssue = issueReasons[row]
    }
}

extension SubmitLeaveTableCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your reason here..."
            textView.textColor = .lightGray
        }
    }
}

extension SubmitLeaveTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kids.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "KidSelectionCell",
            for: indexPath
        ) as! KidSelectionCell
        
        cell.setup(
            student: kids[indexPath.row],
            isSelected: selected_student == indexPath.row
        )
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 10) / 2
        return CGSize(width: width, height: 74)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected_student = indexPath.row
        colVw.reloadData()
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
        
        onKidSelected?(indexPath.row)
    }
}
