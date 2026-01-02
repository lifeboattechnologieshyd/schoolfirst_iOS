//
//  CheckOutViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class CheckOutViewController: UIViewController {
    
    var selectedProduct: Product?
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var buynowButton: UIButton!
    @IBOutlet weak var gstLbl: UILabel!
    @IBOutlet weak var bottomVw: UIView!
    
    var savedAddresses: [AddressModel] = []
    var selectedAddress: AddressModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "CheckOutImageTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckOutImageTableViewCell")
        tblVw.register(UINib(nibName: "DescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "DescriptionTableViewCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
        
        topbarVw.addBottomShadow()
        bottomVw.addTopShadow()
        
        
        if let product = selectedProduct {
            amountLbl.text = "₹\(product.mrp)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch address every time view appears
        getAddressAPI()
    }
    
    func getAddressAPI() {
        NetworkManager.shared.request(
            urlString: API.ONLINE_STORE_ADDRESS,
            method: .GET,
            parameters: nil,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<[AddressModel]>, NetworkError>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let addresses = response.data, !addresses.isEmpty {
                        self.savedAddresses = addresses
                        self.selectedAddress = addresses.first
                        self.updateDeliveryLabel()
                    } else {
                        self.savedAddresses = []
                        self.selectedAddress = nil
                        self.deliveryLbl.text = "Add your Delivery Address"
                    }
                    
                case .failure(let error):
                    print("Address Fetch Error:", error)
                    self.savedAddresses = []
                    self.selectedAddress = nil
                    self.deliveryLbl.text = "Add your Delivery Address"
                }
            }
        }
    }
    
    func updateDeliveryLabel() {
        guard let address = selectedAddress else {
            deliveryLbl.text = "Add your Delivery Address"
            return
        }
        
        let displayAddress = getDisplayAddress(from: address)
        
        if displayAddress.isEmpty {
            deliveryLbl.text = "Add your Delivery Address"
        } else {
            deliveryLbl.text = displayAddress
            deliveryLbl.textColor = .black

        }
    }
    
    func getDisplayAddress(from address: AddressModel) -> String {
        var addressComponents: [String] = []
        
        if let houseNo = address.fullAddress?.houseNo, !houseNo.isEmpty {
            addressComponents.append(houseNo)
        }
        if let street = address.fullAddress?.street, !street.isEmpty {
            addressComponents.append(street)
        }
        if let landmark = address.fullAddress?.landmark, !landmark.isEmpty {
            addressComponents.append(landmark)
        }
        if let village = address.fullAddress?.village, !village.isEmpty {
            addressComponents.append(village)
        }
        if let district = address.fullAddress?.district, !district.isEmpty {
            addressComponents.append(district)
        }
        if let place = address.placeName, !place.isEmpty {
            addressComponents.append(place)
        }
        if let state = address.stateName, !state.isEmpty {
            addressComponents.append(state)
        }
        if let pin = address.pinCode, !pin.isEmpty {
            addressComponents.append(pin)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    private func setupTopbarShadow() {
        topbarVw.layer.shadowColor = UIColor.black.cgColor
        topbarVw.layer.shadowOpacity = 0.15
        topbarVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        topbarVw.layer.shadowRadius = 5
        topbarVw.layer.masksToBounds = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func changeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let saveAddressVC = storyboard.instantiateViewController(withIdentifier: "SaveAddressVC") as? SaveAddressVC {
            saveAddressVC.existingAddress = selectedAddress
            self.navigationController?.pushViewController(saveAddressVC, animated: true)
        }
    }
    
    @IBAction func buyNowButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "MakePaymentViewController") as? MakePaymentViewController {
            nextVC.selectedProduct = selectedProduct
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

extension CheckOutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = selectedProduct else { return UITableViewCell() }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOutImageTableViewCell", for: indexPath) as! CheckOutImageTableViewCell
            cell.selectionStyle = .none
            if let url = URL(string: product.thumbnailImage) {
                cell.imgVw.loadImage(from: url)
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell", for: indexPath) as! DescriptionTableViewCell
            cell.selectionStyle = .none
            
            cell.descriptionTv.text = product.itemDescription
            self.amountLbl.text = "₹\(Int(Double(product.finalPrice) ?? 0))"
            cell.strikeOutPrice.text = "₹\(Int(Double(product.finalPrice) ?? 0))"

            
            // STRIKEOUT PRICE VISIBILITY
            let mrp = product.mrp.trimmingCharacters(in: .whitespaces)
            
            if !mrp.isEmpty && mrp != "0" {

                let mrpValue = Int(Double(mrp) ?? 0)
                cell.strikeOutPrice.text = "₹\(mrpValue)"
                cell.strikeOutPrice.isHidden = false
                cell.strikeLineImg.isHidden = false
            } else {
                cell.strikeOutPrice.isHidden = true
                cell.strikeLineImg.isHidden = true
            }
            
            if let discountTag = product.discountTag {
                cell.offLbl?.text = discountTag.components(separatedBy: "-").first
            } else {
                cell.offLbl?.text = "0% off"
            }
            
            cell.interestingLbl.text = product.highlights?.joined(separator: ", ") ?? ""
            
            let highlights = product.highlights ?? []
            if highlights.count >= 2 {
                cell.variant1.text = highlights[0]
                cell.variant2.text = highlights[1]
            } else if highlights.count == 1 {
                cell.variant1.text = highlights[0]
                cell.variant2.text = "--"
            } else {
                cell.variant1.text = "--"
                cell.variant2.text = "--"
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 212
        case 1: return 528
        default: return UITableView.automaticDimension
        }
    }
}
