//
//  SaveAddressVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 29/12/25.
//

import UIKit

class SaveAddressVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var saveAddressBtn: UIButton!
    
    // Property to receive existing address
    var existingAddress: AddressModel?
    
    // Reference to cell for getting values
    private var addressCell: SaveAddressCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(
            UINib(nibName: "SaveAddressCell", bundle: nil),
            forCellReuseIdentifier: "SaveAddressCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        setupUI()
        setupKeyboardDismiss()
    }
    
    private func setupUI() {
        saveAddressBtn.layer.cornerRadius = 8
        saveAddressBtn.clipsToBounds = true
        topVw.addBottomShadow()
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAddressBtnTapped(_ sender: UIButton) {
        guard let cell = addressCell else { return }
        
        // Validate fields
        guard validateFields(cell: cell) else { return }
        
        // Call API based on mode (Edit or Create)
        if existingAddress != nil {
            editAddressAPI(cell: cell)
        } else {
            createAddressAPI(cell: cell)
        }
    }
    
    private func validateFields(cell: SaveAddressCell) -> Bool {
        
        guard let name = cell.nameTf.text, !name.isEmpty else {
            showAlert(message: "Please enter full name")
            return false
        }
        
        guard let phone = cell.phoneTf.text, !phone.isEmpty else {
            showAlert(message: "Please enter phone number")
            return false
        }
        
        guard phone.count == 10, Int(phone) != nil else {
            showAlert(message: "Please enter valid 10-digit phone number")
            return false
        }
        
        guard let address = cell.businessTv.text, !address.isEmpty else {
            showAlert(message: "Please enter address")
            return false
        }
        
        guard let city = cell.cityTf.text, !city.isEmpty else {
            showAlert(message: "Please enter city")
            return false
        }
        
        guard let state = cell.stateTf.text, !state.isEmpty else {
            showAlert(message: "Please select state")
            return false
        }
        
        guard let pincode = cell.pincodeTf.text, !pincode.isEmpty else {
            showAlert(message: "Please enter pincode")
            return false
        }
        
        guard pincode.count == 6, Int(pincode) != nil else {
            showAlert(message: "Please enter valid 6-digit pincode")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func editAddressAPI(cell: SaveAddressCell) {
        
        guard let addressId = existingAddress?.id else {
            showAlert(message: "Address ID not found")
            return
        }
        
        let mobile = Int(cell.phoneTf.text ?? "0") ?? 0
        
        let fullAddressDict: [String: Any] = [
            "street": "",
            "country": "India",
            "village": "",
            "district": cell.cityTf.text ?? "",
            "house_no": cell.businessTv.text ?? "",
            "landmark": ""
        ]
        
        let parameters: [String: Any] = [
            "contact_number": mobile,
            "full_name": cell.nameTf.text ?? "",
            "full_address": fullAddressDict,
            "mobile": mobile,
            "place_name": cell.cityTf.text ?? "",
            "state_name": cell.stateTf.text ?? "",
            "pin_code": cell.pincodeTf.text ?? ""
        ]
        
        let editURL = API.ONLINE_STORE_ADDRESS + "/\(addressId)"
        
        print("Edit URL: \(editURL)")
        
        NetworkManager.shared.request(
            urlString: editURL,
            method: .PUT,
            parameters: parameters
        ) { [weak self] (result: Result<APIResponse<AddressModel>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAndGoBack(message: "Address updated successfully!")
                    } else {
                        self.showAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    print("Edit Address Error:", error)
                    self.showAlert(message: "Failed to update address. Please try again.")
                }
            }
        }
    }
    
    private func createAddressAPI(cell: SaveAddressCell) {
        
        let mobile = Int(cell.phoneTf.text ?? "0") ?? 0
        
        let fullAddressDict: [String: Any] = [
            "street": "",
            "country": "India",
            "village": "",
            "district": cell.cityTf.text ?? "",
            "house_no": cell.businessTv.text ?? "",
            "landmark": ""
        ]
        
        let parameters: [String: Any] = [
            "contact_number": mobile,
            "full_name": cell.nameTf.text ?? "",
            "full_address": fullAddressDict,
            "mobile": mobile,
            "place_name": cell.cityTf.text ?? "",
            "state_name": cell.stateTf.text ?? "",
            "pin_code": cell.pincodeTf.text ?? ""
        ]
        
        NetworkManager.shared.request(
            urlString: API.ONLINE_STORE_ADDRESS,
            method: .POST,
            parameters: parameters
        ) { [weak self] (result: Result<APIResponse<CreateAddressResponseModel>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAndGoBack(message: "Address saved successfully!")
                    } else {
                        self.showAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    print("Create Address Error:", error)
                    self.showAlert(message: "Failed to save address. Please try again.")
                }
            }
        }
    }
    
    private func showSuccessAndGoBack(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension SaveAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SaveAddressCell",
            for: indexPath
        ) as! SaveAddressCell
        
        // Store reference to cell
        addressCell = cell
        
        // Populate existing address if available
        if let address = existingAddress {
            cell.populateAddress(address)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 750
    }
}
