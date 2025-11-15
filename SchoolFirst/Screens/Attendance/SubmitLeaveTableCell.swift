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

    let issueReasons = ["Fever / Health Issue","Family Function","Emergency Situation","Travel","Personal Reason"]

    override func awakeFromNib() {
        super.awakeFromNib()

        colVw.register(
            UINib(nibName: "GradeCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "GradeCollectionCell"
        )

        colVw.delegate = self
        colVw.dataSource = self

        hideAllViews()
        clearHighlights()

        // ⭐ APPLY DROPSHADOWS HERE
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
    }

    func hideAllViews() {
        dateVw.isHidden = true
        sessionVw.isHidden = true
        todateVw.isHidden = true
        reasonVw.isHidden = true

        dateHeight.constant = 0
        sessionHeight.constant = 0
        todateHeight.constant = 0
        reasonHeight.constant = 0
    }

    func refreshLayout() {
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    @IBAction func onClickSingleDay(_ sender: UIButton) {
        hideAllViews()
        dateVw.isHidden = false
        reasonVw.isHidden = false

        dateHeight.constant = 132
        reasonHeight.constant = 268

        highlightSelected(view: singleVw)
        refreshLayout()
    }

    @IBAction func onClickHalfDay(_ sender: UIButton) {
        hideAllViews()
        clearHighlights()

        dateVw.isHidden = false
        sessionVw.isHidden = false
        reasonVw.isHidden = false

        dateHeight.constant = 132
        sessionHeight.constant = 76
        reasonHeight.constant = 268

        highlightSelected(view: singleVw)
        refreshLayout()
    }

    @IBAction func onClickMultipleDays(_ sender: UIButton) {
        hideAllViews()

        dateVw.isHidden = false
        sessionVw.isHidden = false
        todateVw.isHidden = false
        reasonVw.isHidden = false

        dateHeight.constant = 132
        sessionHeight.constant = 76
        todateHeight.constant = 48
        reasonHeight.constant = 268

        highlightSelected(view: multipleVw)
        refreshLayout()
    }

    @IBAction func onClickChangeDate(_ sender: UIButton) { openDatePicker() }
    @IBAction func onClickAddDate(_ sender: UIButton) { openDatePicker() }

    func openDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date

        let alert = UIAlertController(title: "Select Date",
                                      message: "\n\n\n\n\n\n",
                                      preferredStyle: .alert)

        alert.view.addSubview(datePicker)
        datePicker.frame = CGRect(x: 10, y: 40, width: 250, height: 150)

        alert.addAction(UIAlertAction(title: "Done", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        parentViewController()?.present(alert, animated: true)
    }

    @IBAction func onClickIssue(_ sender: UIButton) {

        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self

        let alert = UIAlertController(title: "Select Issue",
                                      message: "\n\n\n\n\n\n",
                                      preferredStyle: .alert)

        alert.view.addSubview(picker)
        picker.frame = CGRect(x: 10, y: 40, width: 250, height: 150)

        alert.addAction(UIAlertAction(title: "Done", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        parentViewController()?.present(alert, animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { issueReasons.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { issueReasons[row] }
}

extension SubmitLeaveTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 10 }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCell(
            withReuseIdentifier: "GradeCollectionCell",
            for: indexPath
        ) as! GradeCollectionCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 160, height: 54)
    }
}


extension UIView {
    func applyDropShadow() {
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false
    }
}
