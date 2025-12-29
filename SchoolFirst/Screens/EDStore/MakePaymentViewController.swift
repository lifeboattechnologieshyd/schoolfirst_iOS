//
//  MakePaymentViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit
import CashfreePG
import CashfreePGCoreSDK
import CashfreePGUISDK

class MakePaymentViewController: UIViewController {

    var selectedProduct: Product?
    var savedAddresses: [AddressModel] = []
    var selectedAddress: AddressModel?
    var selectedQuantity: Int = 1


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var makepaymentBtn: UIButton!
    @IBOutlet weak var finalPriceLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topbarVw.addBottomShadow()
        setupTableView()
        getAddressAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateFinalPriceLabel()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PaymentTableViewCell")
        tableView.register(UINib(nibName: "DeliveryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "DeliveryTableViewCell")
        tableView.register(UINib(nibName: "InvoiceTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "InvoiceTableViewCell")
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func makepaymentBtnTapped(_ sender: UIButton) {
        guard selectedAddress != nil else {
            showAlert(title: "Address Required", message: "Please save or select an address before making payment.")
            return
        }
        callCreateOrderAPI()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateFinalPriceLabel() {
        guard let product = selectedProduct else {
            finalPriceLbl.text = "₹0.00"
            return
        }
        let unitFinalPrice = Double(product.finalPrice) ?? 0.0
        let finalPrice = unitFinalPrice * Double(selectedQuantity)

        let gst = finalPrice * 0.18
        let total = finalPrice + gst

        finalPriceLbl.text = "₹\(String(format: "%.2f", total))"
    }
}

extension MakePaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return configurePaymentCell(for: indexPath)
        case 1:
            return configureDeliveryCell(for: indexPath)
        case 2:
            return configureInvoiceCell(for: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 372
        case 1: return 720
        case 2: return 356
        default: return 0
        }
    }
    
    private func configurePaymentCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PaymentTableViewCell",
            for: indexPath
        ) as! PaymentTableViewCell
            
        if let product = selectedProduct,
           let url = URL(string: product.thumbnailImage) {
            cell.imgVw.loadImage(from: url)
        }

        // 🔥 THIS IS THE IMPORTANT PART
        cell.onQuantityChanged = { [weak self] quantity in
            guard let self = self else { return }
            self.selectedQuantity = quantity

            // Update invoice + final price
            let invoiceIndexPath = IndexPath(row: 2, section: 0)
            self.tableView.reloadRows(at: [invoiceIndexPath], with: .none)
            self.updateFinalPriceLabel()
        }
            
        return cell
    }

    
    private func configureDeliveryCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTableViewCell", for: indexPath) as! DeliveryTableViewCell
        
        if let address = selectedAddress {
            cell.nameTf.text = address.fullName
            cell.phoneTf.text = "\(address.contactNumber ?? 0)"
            cell.businessTf.text = address.fullAddress?.houseNo
            cell.cityTf.text = address.fullAddress?.district
            cell.stateTf.text = address.stateName
            cell.pincodeTf.text = address.pinCode
        }
        
        cell.saveAddressLbl.isUserInteractionEnabled = true
        cell.saveAddressLbl.gestureRecognizers?.removeAll()
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveAddressTapped(_:)))
        cell.saveAddressLbl.addGestureRecognizer(tap)
        
        return cell
    }
    
    private func configureInvoiceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceTableViewCell", for: indexPath) as! InvoiceTableViewCell
        updateInvoiceCell(cell: cell)
        return cell
    }
    
    func updateInvoiceCell(cell: InvoiceTableViewCell) {
        guard let product = selectedProduct else {
            setDefaultInvoiceValues(cell: cell)
            return
        }
        let unitMrp = Double(product.mrp) ?? 0.0
        let unitFinalPrice = Double(product.finalPrice) ?? 0.0

        let mrp = unitMrp * Double(selectedQuantity)
        let finalPrice = unitFinalPrice * Double(selectedQuantity)

        let gst = finalPrice * 0.18
        let total = finalPrice + gst
        let discountAmount = mrp - finalPrice

        cell.invoiceLbl?.text = product.itemName ?? "Product"
        cell.mrpamtLbl?.text = "₹\(String(format: "%.2f", mrp))"
        cell.finalamountLbl?.text = "₹\(String(format: "%.2f", finalPrice))"
        cell.discountamtLbl?.text = "-₹\(String(format: "%.2f", discountAmount))"
        if let discountTag = product.discountTag {
            cell.discountLbl?.text = discountTag.components(separatedBy: "-").first
        } else {
            cell.discountLbl?.text = "0% off"
        }
        cell.gstamtLbl?.text = "₹\(String(format: "%.2f", gst))"
        cell.totalPayableLbl?.text = "₹\(String(format: "%.2f", total))"
        cell.exclusiveGstamtLbl?.text = "₹\(String(format: "%.2f", total))"

        finalPriceLbl?.text = "₹\(String(format: "%.2f", total))"
    }
    
    private func setDefaultInvoiceValues(cell: InvoiceTableViewCell) {
        cell.invoiceLbl?.text = "No Product"
        cell.mrpamtLbl?.text = "₹0.00"
        cell.finalamountLbl?.text = "₹0.00"
        cell.discountamtLbl?.text = "₹0.00"
        cell.discountLbl?.text = "0% off"
        cell.gstamtLbl?.text = "₹0.00"
        cell.totalPayableLbl?.text = "₹0.00"
        cell.exclusiveGstamtLbl?.text = "₹0.00"
    }
}

extension MakePaymentViewController {
    
    func getAddressAPI() {
        NetworkManager.shared.request(
            urlString: API.GET_ADDRESS,
            method: .GET,
            parameters: nil,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<[AddressModel]>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let addresses = response.data, !addresses.isEmpty {
                        self?.savedAddresses = addresses
                        self?.selectedAddress = addresses.first
                        self?.tableView.reloadData()
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    @objc func saveAddressTapped(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view?.superview(of: DeliveryTableViewCell.self) else { return }

        let contact = cell.phoneTf.text ?? ""
        let fullName = cell.nameTf.text ?? ""
        let houseNo = cell.businessTf.text ?? ""
        let street = cell.cityTf.text ?? ""
        let district = cell.cityTf.text ?? ""
        let stateName = cell.stateTf.text ?? ""
        let pinCode = cell.pincodeTf.text ?? ""

        if contact.isEmpty || fullName.isEmpty || stateName.isEmpty || pinCode.isEmpty {
            showAlert(title: "Missing Fields", message: "Please fill all required fields")
            return
        }

        callCreateAddressAPI(
            contact: contact,
            fullName: fullName,
            houseNo: houseNo,
            street: street,
            landmark: "",
            village: "",
            district: district,
            country: "India",
            placeName: district,
            stateName: stateName,
            pinCode: pinCode
        )
    }

    func callCreateAddressAPI(
        contact: String,
        fullName: String,
        houseNo: String,
        street: String,
        landmark: String,
        village: String,
        district: String,
        country: String,
        placeName: String,
        stateName: String,
        pinCode: String
    ) {
        let body: [String: Any] = [
            "contact_number": Int(contact) ?? 0,
            "full_name": fullName,
            "full_address": [
                "house_no": houseNo,
                "street": street,
                "landmark": landmark,
                "village": village,
                "district": district,
                "country": country
            ],
            "place_name": placeName,
            "state_name": stateName,
            "pin_code": pinCode
        ]

        NetworkManager.shared.request(
            urlString: API.CREATE_ADDRESS,
            method: .POST,
            parameters: body,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<CreateAddressResponseModel>, NetworkError>) in

            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "Success", message: "Address saved successfully")
                    self?.getAddressAPI()
                case .failure:
                    self?.showAlert(title: "Error", message: "Failed to save address.")
                }
            }
        }
    }
}

extension MakePaymentViewController {

    func callCreateOrderAPI() {
        let cleanedString = finalPriceLbl.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        guard let amountStr = cleanedString,
              let amount = Double(amountStr),
              let product = selectedProduct,
              let address = selectedAddress else {
            showAlert(title: "Error", message: "Invalid order details")
            return
        }
        
        let addressData: [String: Any] = [
            "street": address.fullAddress?.street ?? "",
            "city": address.fullAddress?.district ?? "",
            "state": address.stateName ?? "",
            "country": address.fullAddress?.country ?? "India"
        ]
        
        let backendBody: [String: Any] = [
            "item": product.id ?? "",
            "quantity": selectedQuantity,
            "variants": "color: Black, storage: 128GB",
            "full_name": address.fullName ?? "",
            "full_address": addressData,
            "place_name": address.placeName ?? "",
            "state_name": address.stateName ?? "",
            "pin_code": address.pinCode ?? "",
            "contact_number": address.contactNumber ?? 0,
            "final_price": amount,
            "order_value": amount,
            "gst_percentage": 18.0,
            "gst_amount": amount * 0.18,
            "order_status": "Pending",
            "remarks": ["note": "Order created"],
            "tracking_id": "",
            "courier_name": "",
            "payment_id": "",
            "last_status_update_by": ""
        ]
        
        let loadingAlert = UIAlertController(title: nil, message: "Creating order...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        NetworkManager.shared.request(
            urlString: API.CREATE_ORDER,
            method: .POST,
            parameters: backendBody,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<CreateOrderResponseModel>, NetworkError>) in
            
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success(let response):
                        if let orderId = response.data?.orderId,
                           let paymentSessionId = response.data?.paymentSessionId {
                            self?.startCashfreePayment(orderId: orderId, paymentSessionId: paymentSessionId)
                        } else {
                            self?.showAlert(title: "Error", message: "Failed to get order details from server.")
                        }
                    case .failure:
                        self?.showAlert(title: "Error", message: "Failed to create order. Please try again.")
                    }
                }
            }
        }
    }

    func startCashfreePayment(orderId: String, paymentSessionId: String) {
        CFPaymentGatewayService.getInstance().setCallback(self)

        do {
            let session = try CFSession.CFSessionBuilder()
                .setOrderID(orderId)
                .setPaymentSessionId(paymentSessionId)
                .setEnvironment(CFENVIRONMENT.SANDBOX)
                .build()

            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()

            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: self)

        } catch let cfError as CFErrorResponse {
            showAlert(title: "Payment Error", message: cfError.message ?? "Failed to initialize payment.")
        } catch {
            showAlert(title: "Payment Error", message: "Failed to initialize payment. Please try again.")
        }
    }
}

extension MakePaymentViewController: CFResponseDelegate {

    func onSuccess(_ order_id: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Payment Successful! 🎉",
                message: "Your order has been placed successfully.\nOrder ID: \(order_id)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }

    func onError(_ error: CFErrorResponse, order_id: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Payment Failed", message: error.message ?? "Something went wrong")
        }
    }

    func verifyPayment(order_id: String) { }
}

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
