//
//  PaymentTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectLbl: UIView!
    @IBOutlet weak var selectVw: UIView!
    @IBOutlet weak var bigVw: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var colorCheckbox: UIButton!
    @IBOutlet weak var quantitynoLbl: UILabel!
    @IBOutlet weak var ageCheckbox: UIButton!
    @IBOutlet weak var redVw: UIView!
    @IBOutlet weak var bigsizeCheckbox: UIButton!
    @IBOutlet weak var quantityVw: UIView!
    @IBOutlet weak var blueVw: UIView!
    @IBOutlet weak var sizeCheckbox: UIButton!
    @IBOutlet weak var sizeVw: UIView!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var managingLbl: UILabel!

    enum OptionType {
        case bigSize
        case size
        case age
        case color
    }

    private var selectedOption: OptionType?
    var onQuantityChanged: ((Int) -> Void)?

    private var quantity: Int = 1 {
        didSet {
            quantitynoLbl.text = "\(quantity)"
            minusButton.isEnabled = quantity > 1
            onQuantityChanged?(quantity) // 🔥 notify VC
        }
    
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        quantity = 1  // Default quantity
        setupSelectView()
        setupCheckboxes()
        setupButtons()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectVw.layer.shadowPath =
            UIBezierPath(roundedRect: selectVw.bounds, cornerRadius: 12).cgPath
    }

    private func setupSelectView() {
        selectVw.layer.cornerRadius = 12
        selectVw.layer.masksToBounds = false
        selectVw.layer.shadowColor = UIColor.black.cgColor
        selectVw.layer.shadowOpacity = 0.2
        selectVw.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func setupCheckboxes() {
        let buttons = [bigsizeCheckbox, sizeCheckbox, ageCheckbox, colorCheckbox]

        buttons.forEach {
            $0?.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        }

        bigsizeCheckbox.addTarget(self, action: #selector(bigSizeTapped), for: .touchUpInside)
        sizeCheckbox.addTarget(self, action: #selector(sizeTapped), for: .touchUpInside)
        ageCheckbox.addTarget(self, action: #selector(ageTapped), for: .touchUpInside)
        colorCheckbox.addTarget(self, action: #selector(colorTapped), for: .touchUpInside)
    }

    private func setupButtons() {
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
    }

    @objc private func addTapped() {
        quantity += 1
    }

    @objc private func minusTapped() {
        if quantity > 1 {
            quantity -= 1
        }
    }

    @objc private func bigSizeTapped() {
        select(option: .bigSize)
    }

    @objc private func sizeTapped() {
        select(option: .size)
    }

    @objc private func ageTapped() {
        select(option: .age)
    }

    @objc private func colorTapped() {
        select(option: .color)
    }

    private func select(option: OptionType) {
        selectedOption = option

        bigsizeCheckbox.setImage(
            UIImage(named: option == .bigSize ? "Circle_checkbox" : "BlueCircle"),
            for: .normal
        )

        sizeCheckbox.setImage(
            UIImage(named: option == .size ? "Circle_checkbox" : "BlueCircle"),
            for: .normal
        )

        ageCheckbox.setImage(
            UIImage(named: option == .age ? "Circle_checkbox" : "BlueCircle"),
            for: .normal
        )

        colorCheckbox.setImage(
            UIImage(named: option == .color ? "Circle_checkbox" : "BlueCircle"),
            for: .normal
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedOption = nil

        let buttons = [bigsizeCheckbox, sizeCheckbox, ageCheckbox, colorCheckbox]
        buttons.forEach {
            $0?.setImage(UIImage(named: "BlueCircle"), for: .normal)
        }

        quantity = 1 // Reset quantity when reused
    }
}
