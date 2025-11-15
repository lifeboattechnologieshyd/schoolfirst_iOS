//
//  FeeSummaryCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 14/11/25.
//
import UIKit

class FeeSummaryCell: UITableViewCell {

    @IBOutlet weak var transactionsButton: UIButton!
    @IBOutlet weak var installmentVw: UIView!
    
    @IBOutlet weak var dueamount: UILabel!
    @IBOutlet weak var dueLbl: UILabel!
    @IBOutlet weak var duemonth: UIButton!
    
    @IBOutlet weak var installmentVw1: UIView!
    @IBOutlet weak var buttonsContainer1: UIView!
    @IBOutlet weak var partPaymentBtn1: UIButton!
    @IBOutlet weak var payFullBtn1: UIButton!
    
    @IBOutlet weak var installmentVw2: UIView!
    @IBOutlet weak var buttonsContainer2: UIView!
    @IBOutlet weak var partPaymentBtn2: UIButton!
    @IBOutlet weak var payFullBtn2: UIButton!
    
    @IBOutlet weak var installmentVw3: UIView!
    @IBOutlet weak var buttonsContainer3: UIView!
    @IBOutlet weak var partPaymentBtn3: UIButton!
    @IBOutlet weak var payFullBtn3: UIButton!

    var isFirstTap = true

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonsContainer1.isHidden = true
        buttonsContainer2.isHidden = true
        buttonsContainer3.isHidden = true
        
        installmentVw1.addCardShadow()
        installmentVw2.addCardShadow()
        installmentVw3.addCardShadow()
        installmentVw.addCardShadow()

        installmentVw1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle1)))
        installmentVw2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle2)))
        installmentVw3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle3)))
    }

    private func closeAll() {
        buttonsContainer1.isHidden = true
        buttonsContainer2.isHidden = true
        buttonsContainer3.isHidden = true
    }

    @objc func toggle1() {
        let willOpen = buttonsContainer1.isHidden
        closeAll()
        buttonsContainer1.isHidden = !willOpen
        UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
    }

    @objc func toggle2() {
        let willOpen = buttonsContainer2.isHidden
        closeAll()
        buttonsContainer2.isHidden = !willOpen
        UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
    }

    @objc func toggle3() {
        let willOpen = buttonsContainer3.isHidden
        closeAll()
        buttonsContainer3.isHidden = !willOpen
        UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
    }

    @IBAction func onClickTransactions(_ sender: UIButton) {
        if let vc = self.parentViewController() {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = sb.instantiateViewController(withIdentifier: "FeeTransactionsVC") as! FeeTransactionsVC
            vc.navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    @IBAction func onClickDueMonth(_ sender: UIButton) {

        let red = UIColor(red: 0xEE/255, green: 0x4E/255, blue: 0x5E/255, alpha: 1.0)

        let currentTitle = duemonth.titleLabel?.text ?? ""

        let attributed = NSAttributedString(
            string: currentTitle,
            attributes: [
                .foregroundColor: red,
                .font: duemonth.titleLabel?.font ?? UIFont.systemFont(ofSize: 14)
            ]
        )
        
        duemonth.setAttributedTitle(attributed, for: .normal)

        if isFirstTap {
            // FIRST TAP
            dueLbl.text = "Only 2 Days remaining"
            dueLbl.textColor = red

        } else {
            // SECOND TAP
            dueLbl.text = "Fine: ₹100 * 4 Days"
            dueLbl.textColor = red

            dueamount.text = "₹35,400"
        }

        isFirstTap.toggle()
    }
}

extension UIView {
    func addCardShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let vc = responder as? UIViewController {
                return vc
            }
        }
        return nil
    }
}
