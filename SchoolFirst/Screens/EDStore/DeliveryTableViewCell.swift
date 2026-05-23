//
//  DeliveryTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class DeliveryTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var mainVw: UIView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var businessLbl: UILabel!
    @IBOutlet weak var businessTv: UITextView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cityTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var saveAddressLbl: UILabel!
    @IBOutlet weak var greencheckbox: UIButton!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var pincodeTf: UITextField!
    @IBOutlet weak var pincodeLbl: UILabel!
    @IBOutlet weak var stateTf: UITextField!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var saveAddressBtn: UIButton!


    // 🔹 Closure callback
    var onSaveAddress: (() -> Void)?

    private var isChecked = false

    let indianStates = [
        "Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh",
        "Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand",
        "Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur",
        "Meghalaya","Mizoram","Nagaland","Odisha","Punjab",
        "Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura",
        "Uttar Pradesh","Uttarakhand","West Bengal","Andaman and Nicobar Islands",
        "Chandigarh","Dadra and Nagar Haveli and Daman and Diu","Delhi","Jammu and Kashmir",
        "Ladakh","Lakshadweep","Puducherry"
    ]

    override func awakeFromNib() {
        super.awakeFromNib()

        businessTv.addCardShadow()
        cityTf.addCardShadow()
        phoneTf.addCardShadow()
        pincodeTf.addCardShadow()
        nameTf.addCardShadow()
        stateTf.addCardShadow()


        isChecked = false
        greencheckbox.setImage(UIImage(named: "green square"), for: .normal)
        greencheckbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        let statePicker = UIPickerView()
        statePicker.delegate = self
        statePicker.dataSource = self
        stateTf.inputView = statePicker

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: true)
        stateTf.inputAccessoryView = toolBar
    }

    @objc private func donePressed() {
        self.endEditing(true)
    }

    @objc private func toggleCheckbox() {
        isChecked.toggle()
        let imageName = isChecked ? "green square" : "Square_Checkbox"
        greencheckbox.setImage(UIImage(named: imageName), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isChecked = false
        greencheckbox.setImage(UIImage(named: "Square_Checkbox"), for: .normal)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indianStates.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return indianStates[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateTf.text = indianStates[row]
    }

    @IBAction func saveAddressTapped(_ sender: UIButton) {
        // Call the closure if set
        onSaveAddress?()
    }

    // Helper to access all form values
    func getAddressFormData() -> (contact: String, fullName: String, houseNo: String,
                                   street: String, landmark: String,
                                   village: String, district: String,
                                   country: String, placeName: String,
                                   stateName: String, pinCode: String) {
        return (
            contact: phoneTf.text ?? "",
            fullName: nameTf.text ?? "",
            houseNo: businessTv.text ?? "",
            street: cityTf.text ?? "",
            landmark: "",
            village: "",
            district: cityTf.text ?? "",
            country: "India",
            placeName: businessTv.text ?? "",
            stateName: stateTf.text ?? "",
            pinCode: pincodeTf.text ?? ""
        )
    }
}
