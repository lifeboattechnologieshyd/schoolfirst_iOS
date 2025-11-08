//
//  AddKidOneCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/11/25.
//
import UIKit

class AddKidOneCell: UITableViewCell {
    
    @IBOutlet weak var gradeTf: UITextField!
    @IBOutlet weak var relationTf: UITextField!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var femaleVw: UIView!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var dateTf: UITextField!
    @IBOutlet weak var notesTv: UITextView!
    @IBOutlet weak var addDate: UIButton!
    @IBOutlet weak var maleVw: UIView!
    @IBOutlet weak var maleButton: UIButton!
    
    private let gradePicker = UIPickerView()
    private let relationPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    private let grades = ["Nursery", "PP1", "PP2", "Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10"]
    private let relations = ["Son","Daughter"]
    
    private var isDatePickerVisible = false
    
     
        override func awakeFromNib() {
            super.awakeFromNib()
            setupPickers()
            setupDatePicker()
            setupGenderViews()
            addShadowsToTextFields()
        }
    }

     extension AddKidOneCell {
        private func addShadowsToTextFields() {
            [gradeTf, relationTf,nameTf,dateTf,notesTv].forEach {
                 $0?.layer.shadowColor = UIColor.black.cgColor
                $0?.layer.shadowOpacity = 0.15
                $0?.layer.shadowRadius = 4
                $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0?.layer.masksToBounds = false
                $0?.backgroundColor = .white
            }
        }
    }

     extension AddKidOneCell {
        private func setupGenderViews() {
            maleVw.layer.borderWidth = 1.5
            maleVw.layer.borderColor = UIColor(red: 0.04, green: 0.34, blue: 0.60, alpha: 1).cgColor // #0B569A

            femaleVw.layer.borderWidth = 1.5
            femaleVw.layer.borderColor = UIColor(red: 0.80, green: 0.90, blue: 0.99, alpha: 1).cgColor // #CBE5FD
        }
    }

     extension AddKidOneCell: UIPickerViewDelegate, UIPickerViewDataSource {
        
        private func setupPickers() {
            [gradePicker, relationPicker].forEach {
                $0.delegate = self
                $0.dataSource = self
            }
            
            gradeTf.inputView = gradePicker
            relationTf.inputView = relationPicker
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
            toolbar.setItems([doneButton], animated: true)
            gradeTf.inputAccessoryView = toolbar
            relationTf.inputAccessoryView = toolbar
        }
        
        @objc private func doneTapped() {
            gradeTf.resignFirstResponder()
            relationTf.resignFirstResponder()
            hideDatePicker()
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            pickerView == gradePicker ? grades.count : relations.count
        }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            pickerView == gradePicker ? grades[row] : relations[row]
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            pickerView == gradePicker ? (gradeTf.text = grades[row]) : (relationTf.text = relations[row])
        }
    }

     extension AddKidOneCell {
        
        private func setupDatePicker() {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.maximumDate = Date()
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            addDate.addTarget(self, action: #selector(showInlineDatePicker), for: .touchUpInside)
        }
        
        @objc private func showInlineDatePicker() {
            guard let parentView = addDate.superview else { return }
            if isDatePickerVisible { hideDatePicker(); return }
            
            parentView.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: addDate.bottomAnchor, constant: 8),
                datePicker.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
                datePicker.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16)
            ])
            isDatePickerVisible = true
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.setItems([UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideDatePicker))], animated: true)
            parentView.addSubview(toolbar)
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                toolbar.bottomAnchor.constraint(equalTo: datePicker.topAnchor),
                toolbar.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
                toolbar.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16)
            ])
            toolbar.tag = 999
        }
        
        @objc private func hideDatePicker() {
            datePicker.removeFromSuperview()
            addDate.superview?.viewWithTag(999)?.removeFromSuperview()
            isDatePickerVisible = false
        }
        
        @objc private func dateChanged() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            addDate.setTitle(formatter.string(from: datePicker.date), for: .normal)
        }
    }

