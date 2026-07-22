//
//  paymentgatewaytestVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 16/06/26.
//

/*import UIKit

class paymentgatewaytestVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var PayButton: UIButton!
    @IBOutlet weak var EnteramountTextField: UITextField!
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - SETUP UI
    
    private func setupUI() {
        
        EnteramountTextField.keyboardType   = .numberPad
        EnteramountTextField.placeholder    = "Enter Amount (₹)"
        
        // DISMISS KEYBOARD ON TAP
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - BACK BUTTON
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {
        
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - PAY BUTTON
    
    @IBAction func PayButtonTapped(_ sender: UIButton) {
        
        view.endEditing(true)
        
        // VALIDATE AMOUNT
        guard let amountText = EnteramountTextField.text,
              !amountText.isEmpty,
              let amount = Int(amountText),
              amount > 0 else {
            showAlert(
                title   : "Invalid Amount ⚠️",
                message : "Please enter a valid amount greater than 0."
            )
            return
        }
        
        // SHOW LOADING
        showLoading(true)
        
        // GENERATE UNIQUE TRANSACTION ID
        let uniqueTransactionId = "TXN_\(Int(Date().timeIntervalSince1970))"
        
        print("🚀 Starting Payment")
        print("💰 Amount: ₹\(amount)")
        print("🔑 Transaction ID: \(uniqueTransactionId)")
        
        // START PAYMENT
        PhonePeManager.shared.initiateTestPayment(
            amount        : amount,
            transactionId : uniqueTransactionId,
            from          : self
        ) { [weak self] success, message in
            
            DispatchQueue.main.async {
                
                self?.showLoading(false)
                
                if success {
                    self?.showPaymentSuccess(message: message)
                } else {
                    self?.showPaymentFailure(message: message)
                }
            }
        }
    }
    
    // MARK: - SHOW LOADING
    
    private func showLoading(_ show: Bool) {
        PayButton.isEnabled  = !show
        PayButton.alpha      = show ? 0.6 : 1.0
        PayButton.setTitle(
            show ? "Processing..." : "Pay Now",
            for: .normal
        )
    }
    
    // MARK: - SUCCESS ALERT
    
    private func showPaymentSuccess(message: String) {
        
        let alert = UIAlertController(
            title          : "Payment Successful ✅",
            message        : message,
            preferredStyle : .alert
        )
        
        alert.addAction(UIAlertAction(
            title  : "OK",
            style  : .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - FAILURE ALERT
    
    private func showPaymentFailure(message: String) {
        
        let alert = UIAlertController(
            title          : "Payment Failed ❌",
            message        : message,
            preferredStyle : .alert
        )
        
        alert.addAction(UIAlertAction(
            title  : "Retry",
            style  : .default
        ) { [weak self] _ in
            self?.showLoading(false)
        })
        
        alert.addAction(UIAlertAction(
            title  : "Cancel",
            style  : .cancel
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - GENERIC ALERT
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(
            title          : title,
            message        : message,
            preferredStyle : .alert
        )
        
        alert.addAction(UIAlertAction(
            title : "OK",
            style : .default
        ))
        
        present(alert, animated: true)
    }
}*/
