//
//  SaveAddressCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 29/12/25.
//

import UIKit

class SaveAddressCell: UITableViewCell {
    
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var businessLbl: UILabel!
    @IBOutlet weak var businessTv: UITextView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cityTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var pincodeTf: UITextField!
    @IBOutlet weak var pincodeLbl: UILabel!
    @IBOutlet weak var stateTf: UITextField!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    
    private let statePicker = UIPickerView()
    
    let indianStates: [String] = [
        "Andhra Pradesh",
        "Arunachal Pradesh",
        "Assam",
        "Bihar",
        "Chhattisgarh",
        "Goa",
        "Gujarat",
        "Haryana",
        "Himachal Pradesh",
        "Jharkhand",
        "Karnataka",
        "Kerala",
        "Madhya Pradesh",
        "Maharashtra",
        "Manipur",
        "Meghalaya",
        "Mizoram",
        "Nagaland",
        "Odisha",
        "Punjab",
        "Rajasthan",
        "Sikkim",
        "Tamil Nadu",
        "Telangana",
        "Tripura",
        "Uttar Pradesh",
        "Uttarakhand",
        "West Bengal",
        "Andaman and Nicobar Islands",
        "Chandigarh",
        "Dadra and Nagar Haveli and Daman and Diu",
        "Delhi",
        "Jammu and Kashmir",
        "Ladakh",
        "Lakshadweep",
        "Puducherry"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        setupTextFieldDelegates()
        setupStatePicker()
    }
    
    private func setupUI() {
        // Style text view
        businessTv.layer.borderWidth = 1
        businessTv.layer.borderColor = UIColor.lightGray.cgColor
        businessTv.layer.cornerRadius = 8
        
        // Style main view if needed
        if mainVw != nil {
            mainVw.layer.cornerRadius = 12
        }
    }
    
    private func setupTextFieldDelegates() {
        phoneTf.delegate = self
        pincodeTf.delegate = self
        phoneTf.keyboardType = .numberPad
        pincodeTf.keyboardType = .numberPad
    }
    
    private func setupStatePicker() {
        statePicker.delegate = self
        statePicker.dataSource = self
        
        // Set picker as input view for stateTf
        stateTf.inputView = statePicker
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.systemBlue
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePickerTapped))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPickerTapped))
        
        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
        
        stateTf.inputAccessoryView = toolbar
        
        // Add dropdown arrow indicator
        addDropdownArrow(to: stateTf)
    }
    
    private func addDropdownArrow(to textField: UITextField) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
         
        textField.rightView = containerView
        textField.rightViewMode = .always
    }
    
    @objc private func donePickerTapped() {
        let selectedRow = statePicker.selectedRow(inComponent: 0)
        stateTf.text = indianStates[selectedRow]
        stateTf.resignFirstResponder()
    }
    
    @objc private func cancelPickerTapped() {
        stateTf.resignFirstResponder()
    }
    
    func populateAddress(_ address: AddressModel) {
        nameTf.text = address.fullName
        
        if let mobile = address.mobile {
            phoneTf.text = "\(mobile)"
        } else if let contactNumber = address.contactNumber {
            phoneTf.text = "\(contactNumber)"
        }
        
        businessTv.text = address.fullAddress?.houseNo ?? ""
        
        // Set city from district or placeName
        cityTf.text = address.fullAddress?.district ?? address.placeName
        
        stateTf.text = address.stateName
        pincodeTf.text = address.pinCode
        
        // Set picker to correct state if exists
        if let stateName = address.stateName,
           let index = indianStates.firstIndex(of: stateName) {
            statePicker.selectRow(index, inComponent: 0, animated: false)
        }
    
    }
}

extension SaveAddressCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Prevent typing in state text field (only picker selection allowed)
        if textField == stateTf {
            return false
        }
        
        if textField == phoneTf || textField == pincodeTf {
            // Allow only digits
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            guard allowedCharacters.isSuperset(of: characterSet) else {
                return false
            }
            
            // Limit length
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            if textField == phoneTf {
                return newLength <= 10
            } else if textField == pincodeTf {
                return newLength <= 6
            }
        }
        
        return true
    }
}

extension SaveAddressCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indianStates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return indianStates[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateTf.text = indianStates[row]
    }
    
  
    
   
    }

