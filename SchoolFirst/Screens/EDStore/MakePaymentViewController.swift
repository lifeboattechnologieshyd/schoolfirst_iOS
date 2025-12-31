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
    private var loadingView: UIView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var makepaymentBtn: UIButton!
    @IBOutlet weak var bottomVw: UIView!
    @IBOutlet weak var finalPriceLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        topbarVw.addBottomShadow()
        bottomVw.addTopShadow()
        setupTableView()
        getAddressAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateFinalPriceLabel()
        CFPaymentGatewayService.getInstance().setCallback(self)
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
        guard let deliveryCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DeliveryTableViewCell else {
            showAlert(title: "Error", message: "Unable to get address details")
            return
        }
        
        let name = deliveryCell.nameTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let phone = deliveryCell.phoneTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let houseNo = deliveryCell.businessTv.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let city = deliveryCell.cityTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let state = deliveryCell.stateTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let pincode = deliveryCell.pincodeTf.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if name.isEmpty {
            showAlert(title: "Missing Information", message: "Please enter your name.")
            return
        }
        if phone.isEmpty || phone.count < 10 {
            showAlert(title: "Missing Information", message: "Please enter a valid phone number.")
            return
        }
        if state.isEmpty {
            showAlert(title: "Missing Information", message: "Please enter your state.")
            return
        }
        if pincode.isEmpty || pincode.count < 6 {
            showAlert(title: "Missing Information", message: "Please enter a valid pincode.")
            return
        }
        
        createOrderWithAddress(name: name, phone: phone, houseNo: houseNo, city: city, state: state, pincode: pincode)
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
    
    private func showLoadingView(message: String = "Creating order...") {
        hideLoadingView()
        
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.tag = 999
        
        let boxView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 120))
        boxView.backgroundColor = .white
        boxView.layer.cornerRadius = 12
        boxView.center = containerView.center
        containerView.addSubview(boxView)
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = CGPoint(x: 70, y: 45)
        indicator.color = .darkGray
        indicator.startAnimating()
        boxView.addSubview(indicator)
        
        let label = UILabel(frame: CGRect(x: 10, y: 80, width: 120, height: 30))
        label.text = message
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .darkGray
        boxView.addSubview(label)
        
        view.addSubview(containerView)
        loadingView = containerView
    }
    
    private func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
        view.viewWithTag(999)?.removeFromSuperview()
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
        case 0:
            return calculatePaymentCellHeight()
        case 1:
            return 720
        case 2:
            return 356
        default:
            return 0
        }
    }

    private func calculatePaymentCellHeight() -> CGFloat {
        let baseHeight: CGFloat = 200
        
        guard let specs = selectedProduct?.specification else {
            return baseHeight
        }
        
        let visibleSpecCount = min(specs.count, 4)
        let specificationHeight: CGFloat = CGFloat(visibleSpecCount) * 45
        
        return baseHeight + specificationHeight
    }
    
    private func configurePaymentCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PaymentTableViewCell",
            for: indexPath
        ) as! PaymentTableViewCell
        
        if let product = selectedProduct {
            if let url = URL(string: product.thumbnailImage) {
                cell.imgVw.loadImage(from: url)
            }
            cell.managingLbl.text = product.itemName
            cell.configureSpecifications(specifications: product.specification)
        }
        
        cell.onQuantityChanged = { [weak self] quantity in
            guard let self = self else { return }
            self.selectedQuantity = quantity
            let invoiceIndexPath = IndexPath(row: 2, section: 0)
            self.tableView.reloadRows(at: [invoiceIndexPath], with: .none)
            self.updateFinalPriceLabel()
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    private func configureDeliveryCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTableViewCell", for: indexPath) as! DeliveryTableViewCell
        
        if let address = selectedAddress {
            cell.nameTf.text = address.fullName
            cell.phoneTf.text = "\(address.contactNumber ?? 0)"
            cell.businessTv.text = address.fullAddress?.houseNo
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

        let unitMrp = Int(Double(product.mrp) ?? 0)
        let unitFinalPrice = Int(Double(product.finalPrice) ?? 0)

        let mrp = unitMrp * selectedQuantity
        let finalPrice = unitFinalPrice * selectedQuantity

        let gst = Int(Double(finalPrice) * 0.18)
        let total = finalPrice + gst
        let discountAmount = mrp - finalPrice

        cell.mrpamtLbl.text = "₹\(mrp)"
        cell.finalamountLbl.text = "₹\(finalPrice)"
        cell.discountamtLbl.text = "-₹\(discountAmount)"

        if let discountTag = product.discountTag, !discountTag.isEmpty {
            cell.discountLbl.text = discountTag.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces)
        } else {
            cell.discountLbl.text = "0% off"
        }

        cell.gstamtLbl.text = "₹\(gst)"
        cell.totalPayableLbl.text = "₹\(total)"
        cell.exclusiveGstamtLbl.text = "₹\(total)"
        finalPriceLbl.text = "₹\(total)"
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
        let houseNo = cell.businessTv.text ?? ""
        let street = cell.cityTf.text ?? ""
        let district = cell.cityTf.text ?? ""
        let stateName = cell.stateTf.text ?? ""
        let pinCode = cell.pincodeTf.text ?? ""
        
        if contact.isEmpty || fullName.isEmpty || stateName.isEmpty || pinCode.isEmpty {
            showAlert(title: "Missing Fields", message: "Please fill all required fields")
            return
        }
        
        callCreateAddressAPI(
            contact: contact, fullName: fullName, houseNo: houseNo,
            street: street, landmark: "", village: "", district: district,
            country: "India", placeName: district, stateName: stateName, pinCode: pinCode
        )
    }
    
    func callCreateAddressAPI(
        contact: String, fullName: String, houseNo: String, street: String,
        landmark: String, village: String, district: String, country: String,
        placeName: String, stateName: String, pinCode: String
    ) {
        let body: [String: Any] = [
            "contact_number": Int(contact) ?? 0,
            "full_name": fullName,
            "full_address": [
                "house_no": houseNo, "street": street, "landmark": landmark,
                "village": village, "district": district, "country": country
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
    
    func createOrderWithAddress(name: String, phone: String, houseNo: String, city: String, state: String, pincode: String) {
        
        let cleanedString = finalPriceLbl.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        guard let amountStr = cleanedString,
              let amount = Double(amountStr),
              let product = selectedProduct else {
            showPaymentPopUp(isSuccess: false)
            return
        }
        
        let addressData: [String: Any] = [
            "house_no": houseNo, "street": city, "city": city, "state": state, "country": "India"
        ]
        
        let backendBody: [String: Any] = [
            "item": product.id ?? "",
            "quantity": selectedQuantity,
            "variants": "color: Black, storage: 128GB",
            "full_name": name,
            "full_address": addressData,
            "place_name": city,
            "state_name": state,
            "pin_code": pincode,
            "contact_number": Int(phone) ?? 0,
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
        
        showLoadingView(message: "Creating order...")
        
        NetworkManager.shared.request(
            urlString: API.CREATE_ORDER,
            method: .POST,
            parameters: backendBody,
            headers: nil
        ) { [weak self] (result: Result<APIResponse<CreateOrderResponseModel>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.hideLoadingView()
                
                switch result {
                case .success(let response):
                    if let orderId = response.data?.orderId,
                       let paymentSessionId = response.data?.paymentSessionId,
                       !orderId.isEmpty,
                       !paymentSessionId.isEmpty {
                        self.startCashfreePayment(orderId: orderId, paymentSessionId: paymentSessionId)
                    } else {
                        self.showPaymentPopUp(isSuccess: false)
                    }
                case .failure:
                    self.showPaymentPopUp(isSuccess: false)
                }
            }
        }
    }
    
    func startCashfreePayment(orderId: String, paymentSessionId: String) {
        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.initiatePayment(orderId: orderId, paymentSessionId: paymentSessionId)
            }
        } else {
            initiatePayment(orderId: orderId, paymentSessionId: paymentSessionId)
        }
    }

    private func initiatePayment(orderId: String, paymentSessionId: String) {
        CFPaymentGatewayService.getInstance().setCallback(self)
        
        do {
            let session = try CFSession.CFSessionBuilder()
                .setOrderID(orderId)
                .setPaymentSessionId(paymentSessionId)
                .setEnvironment(.PRODUCTION)
                .build()
            
            let webCheckout = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(session)
                .build()
            
            try CFPaymentGatewayService.getInstance().doPayment(webCheckout, viewController: self)
            
        } catch let cfError as CFErrorResponse {
            print("❌ Cashfree Error: \(cfError.message ?? "Unknown error")")
            showPaymentPopUp(isSuccess: false)
        } catch {
            print("❌ Payment Error: \(error.localizedDescription)")
            showPaymentPopUp(isSuccess: false)
        }
    }
    
    func showPaymentPopUp(isSuccess: Bool) {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false) { [weak self] in
                self?.presentPopUp(isSuccess: isSuccess)
            }
        } else {
            presentPopUp(isSuccess: isSuccess)
        }
    }
    
    private func presentPopUp(isSuccess: Bool) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "PopUpVC") as? PopUpVC else {
            print("Could not instantiate PopUpVC")
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.isSuccess = isSuccess
        
        present(vc, animated: true)
    }
}

extension MakePaymentViewController: CFResponseDelegate {
    
    func onSuccess(_ order_id: String) {
        print("✅ Payment Success - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showPaymentPopUp(isSuccess: true)
        }
    }
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print("❌ Payment Error - Order ID: \(order_id), Error: \(error.message ?? "Unknown")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showPaymentPopUp(isSuccess: false)
        }
    }
    
    func verifyPayment(order_id: String) {
        print("🔄 Payment Verification - Order ID: \(order_id)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Treat verification as pending/failed for now
            self?.showPaymentPopUp(isSuccess: false)
        }
    }
}

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
