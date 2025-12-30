//
//  EdStoreViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class EdStoreViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var inspiroLbl: UILabel!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var products: [Product] = []
    var currentPage = 1
    var isLoading = false
    var totalProducts = 0
    let pageSize = 10
    
    // Address properties
    var savedAddresses: [AddressModel] = []
    var selectedAddress: AddressModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "EdStoreTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "EdStoreTableViewCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
        
        topbarVw.addBottomShadow()
        
        
        fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    print("Address Response: \(response)")
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 120 {
            if !isLoading && products.count < totalProducts {
                fetchProducts()
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let saveAddressVC = storyboard.instantiateViewController(withIdentifier: "SaveAddressVC") as? SaveAddressVC {
            saveAddressVC.existingAddress = selectedAddress
            self.navigationController?.pushViewController(saveAddressVC, animated: true)
        }
    }
    
    func fetchProducts() {
        guard !isLoading else { return }
        isLoading = true

        NetworkManager.shared.request(
            urlString: API.ONLINE_STORE_PRODUCTS,
            method: .GET,
            parameters: [
                "page": currentPage,
                "limit": pageSize
            ]
        ) { [weak self] (result: Result<APIResponse<[Product]>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.totalProducts = response.total ?? 0
                    
                    if let newProducts = response.data, !newProducts.isEmpty {
                        self.products.append(contentsOf: newProducts)
                        self.tblVw.reloadData()
                        self.currentPage += 1
                    }

                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
}

extension EdStoreViewController: UITableViewDataSource, UITableViewDelegate, EdStoreCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EdStoreTableViewCell",
            for: indexPath
        ) as! EdStoreTableViewCell
        
        let product = products[indexPath.row]
        cell.delegate = self
        
        cell.titleLbl.text = product.itemName
        cell.priceLbl.text = "₹\(Int(Double(product.finalPrice) ?? 0))"
        cell.discountLbl.text = product.discountTag
        
        if let discountTag = product.discountTag {
            let pattern = "\\d+%\\s*off"
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

            let range = NSRange(location: 0, length: discountTag.utf16.count)
            if let match = regex?.firstMatch(in: discountTag, options: [], range: range),
               let matchRange = Range(match.range, in: discountTag) {
                cell.discountLbl.text = String(discountTag[matchRange])
                cell.discountLbl.isHidden = false
            } else {
                cell.discountLbl.text = ""
                cell.discountLbl.isHidden = true
            }
        } else {
            cell.discountLbl.text = ""
            cell.discountLbl.isHidden = true
        }

        if let url = URL(string: product.thumbnailImage) {
            cell.imgVw.loadImage(from: url)
        } else {
            cell.imgVw.image = UIImage(named: "thumbnailImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 266
    }
    
    func didTapImage(in cell: EdStoreTableViewCell) {
        guard let indexPath = tblVw.indexPath(for: cell) else { return }
        let product = products[indexPath.row]
        
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckOutViewController") as? CheckOutViewController {
            checkoutVC.selectedProduct = product
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
}
