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
    @IBOutlet weak var reasonVw: UIView!
    @IBOutlet weak var multipleVw: UIView!
    @IBOutlet weak var singleVw: UIView!
    @IBOutlet weak var issueTf: UITextField!
    
    @IBOutlet weak var tellusTv: UITextView!
    @IBOutlet weak var todateTf: UITextField!
    @IBOutlet weak var dateTf: UITextField!
    @IBOutlet weak var singledayButton: UIButton!
    @IBOutlet weak var singlehalfday: UIButton!
    @IBOutlet weak var multipledaysButton: UIButton!
    @IBOutlet weak var changedate: UIButton!
    @IBOutlet weak var adddateButton: UIButton!
    @IBOutlet weak var issuesbutton: UIButton!

    @IBOutlet weak var colVw: UICollectionView!

    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var sessionHeight: NSLayoutConstraint!
    @IBOutlet weak var todateHeight: NSLayoutConstraint!
    @IBOutlet weak var reasonHeight: NSLayoutConstraint!

    let issueReasons = ["Fever / Health Issue", "Family Function", "Emergency Situation", "Travel", "Personal Reason"]
    
    var selectedIssue: String = ""
    var selectedDate: Date?
    var selectedToDate: Date?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
        setupInitialState()
        applyShadows()
    }
    
    func setupCollectionView() {
        colVw.register(
            UINib(nibName: "KidSelectionCell", bundle: nil),
            forCellWithReuseIdentifier: "KidSelectionCell"
        )
        colVw.delegate = self
        colVw.dataSource = self
    }
    
    func setupInitialState() {
        hideAllViews()
        clearHighlights()
        
        // Ensure clipsToBounds for proper hiding
        dateVw.clipsToBounds = true
        sessionVw.clipsToBounds = true
        todateVw.clipsToBounds = true
        reasonVw.clipsToBounds = true
    }
    
    func applyShadows() {
        issueTf.applyDropShadow()
        todateTf.applyDropShadow()
        dateTf.applyDropShadow()
        tellusTv.applyDropShadow()
    }

    func clearHighlights() {
        singleVw.layer.borderWidth = 0
        multipleVw.layer.borderWidth = 0
    }

    func highlightSelected(view: UIView) {
        clearHighlights()
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        view.layer.cornerRadius = 8
    }

    func hideAllViews() {
        // Hide all views
        dateVw.isHidden = true
        sessionVw.isHidden = true
        todateVw.isHidden = true
        reasonVw.isHidden = true

        // Set all heights to 0
        dateHeight.constant = 0
        sessionHeight.constant = 0
        todateHeight.constant = 0
        reasonHeight.constant = 0
        
        // Force immediate layout
        self.layoutIfNeeded()
    }

    func refreshLayout() {
        // Animate the layout changes
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
        
        // Notify tableView to recalculate cell height
        if let tableView = findParentTableView() {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    // Helper to find parent tableView
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
        // First hide everything and reset
        hideAllViews()
        
        // Show only required views
        dateVw.isHidden = false
        reasonVw.isHidden = false
        
        // Set heights for visible views only
        dateHeight.constant = 132
        reasonHeight.constant = 268
        
        // Explicitly ensure these are hidden with 0 height
        sessionVw.isHidden = true
        sessionHeight.constant = 0
        todateVw.isHidden = true
        todateHeight.constant = 0
        
        // Highlight selection
        highlightSelected(view: singleVw)
        
        // Debug print
        print("Single Day - todateHeight: \(todateHeight.constant), isHidden: \(todateVw.isHidden)")
        
        // Refresh layout
        refreshLayout()
    }

    @IBAction func onClickHalfDay(_ sender: UIButton) {
        // First hide everything and reset
        hideAllViews()
        
        // Show required views
        dateVw.isHidden = false
        sessionVw.isHidden = false
        reasonVw.isHidden = false
        
        // Set heights for visible views only
        dateHeight.constant = 132
        sessionHeight.constant = 76
        reasonHeight.constant = 268
        
        // Explicitly ensure todate is hidden with 0 height
        todateVw.isHidden = true
        todateHeight.constant = 0

        // Highlight selection
        highlightSelected(view: singleVw)
        
        // Debug print
        print("Half Day - todateHeight: \(todateHeight.constant), isHidden: \(todateVw.isHidden)")
        
        // Refresh layout
        refreshLayout()
    }

    @IBAction func onClickMultipleDays(_ sender: UIButton) {
        // First hide everything and reset
        hideAllViews()

        // Show all required views
        dateVw.isHidden = false
        sessionVw.isHidden = false
        todateVw.isHidden = false
        reasonVw.isHidden = false

        // Set heights for visible views
        dateHeight.constant = 132
        sessionHeight.constant = 76
        todateHeight.constant = 48
        reasonHeight.constant = 268

        // Highlight selection
        highlightSelected(view: multipleVw)
        
        // Debug print
        print("Multiple Days - todateHeight: \(todateHeight.constant), isHidden: \(todateVw.isHidden)")
        
        // Refresh layout
        refreshLayout()
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
        datePicker.minimumDate = Date() // Can't select past dates
        
        // Set preferred style for iOS 13.4+
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

extension SubmitLeaveTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "KidSelectionCell",
            for: indexPath
        ) as! KidSelectionCell
        
        // Configure cell here if needed
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 210, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle kid selection here
        print("Selected kid at index: \(indexPath.item)")
    }
}

extension UIView {
    func applyDropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false
    }
    
   
    }

