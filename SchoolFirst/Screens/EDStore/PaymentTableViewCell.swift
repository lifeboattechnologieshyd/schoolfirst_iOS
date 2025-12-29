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
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var colorCheckbox: UIButton!
    @IBOutlet weak var quantitynoLbl: UILabel!
    @IBOutlet weak var ageCheckbox: UIButton!
    
    @IBOutlet weak var specification1: UILabel!
    @IBOutlet weak var specification2: UILabel!
    @IBOutlet weak var specification3: UILabel!
    @IBOutlet weak var specification4: UILabel!
    
    @IBOutlet weak var specificationView1: UIView!
    @IBOutlet weak var specificationView2: UIView!
    @IBOutlet weak var specificationView3: UIView!
    @IBOutlet weak var specificationView4: UIView!
    
    @IBOutlet weak var bigsizeCheckbox: UIButton!
    @IBOutlet weak var quantityVw: UIView!
    @IBOutlet weak var sizeCheckbox: UIButton!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var managingLbl: UILabel!
    
    enum OptionType {
        case bigSize, size, age, color
    }
    
    private var selectedOption: OptionType?
    var onQuantityChanged: ((Int) -> Void)?
    var specificationCount: Int = 0
    
    private var specViews: [UIView] {
        [specificationView1, specificationView2, specificationView3, specificationView4]
    }
    
    private var specLabels: [UILabel] {
        [specification1, specification2, specification3, specification4]
    }
    
    
    private var quantity: Int = 1 {
        didSet {
            quantitynoLbl.text = "\(quantity)"
            minusButton.isEnabled = quantity > 1
            onQuantityChanged?(quantity)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        quantity = 1
        setupSelectView()
        setupCheckboxes()
        setupButtons()
        hideAllSpecifications()
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        selectVw?.layer.shadowPath = UIBezierPath(roundedRect: selectVw.bounds, cornerRadius: 12).cgPath
        
    }

    private func setupSelectView() {
        selectVw?.layer.cornerRadius = 12
        selectVw?.layer.masksToBounds = false
        selectVw?.layer.shadowColor = UIColor.black.cgColor
        selectVw?.layer.shadowOpacity = 0.2
        selectVw?.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func setupCheckboxes() {
        [bigsizeCheckbox, sizeCheckbox, ageCheckbox, colorCheckbox].forEach {
            $0?.setImage(UIImage(named: "checkbox_unchecked"), for: .normal)
        }
        bigsizeCheckbox?.addTarget(self, action: #selector(bigSizeTapped), for: .touchUpInside)
        sizeCheckbox?.addTarget(self, action: #selector(sizeTapped), for: .touchUpInside)
        ageCheckbox?.addTarget(self, action: #selector(ageTapped), for: .touchUpInside)
        colorCheckbox?.addTarget(self, action: #selector(colorTapped), for: .touchUpInside)
    }

    private func setupButtons() {
        addButton?.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        minusButton?.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
    }
    
    private func hideAllSpecifications() {
        // Just hide views - no height constraint changes needed
        specificationView1?.isHidden = true
        specificationView2?.isHidden = true
        specificationView3?.isHidden = true
        specificationView4?.isHidden = true
        
        specification1?.isHidden = true
        specification2?.isHidden = true
        specification3?.isHidden = true
        specification4?.isHidden = true
    }
    
    
    func configureSpecifications(specifications: [String]?) {
        hideAllSpecifications()
        

        guard let specs = specifications else { return }

        for (index, spec) in specs.prefix(4).enumerated() {
            specViews[index].isHidden = false
            specLabels[index].isHidden = false  
            specLabels[index].text = "• \(parseSpecification(spec))"
        }
    }
    private func parseSpecification(_ spec: String) -> String {
        if let colonRange = spec.range(of: ":", options: .backwards) {
            let afterColon = String(spec[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            if Int(afterColon) != nil || afterColon.isEmpty {
                return String(spec[..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        return spec.trimmingCharacters(in: .whitespaces)
    }

    @objc private func addTapped() { quantity += 1 }
    @objc private func minusTapped() { if quantity > 1 { quantity -= 1 } }
    @objc private func bigSizeTapped() { select(option: .bigSize) }
    @objc private func sizeTapped() { select(option: .size) }
    @objc private func ageTapped() { select(option: .age) }
    @objc private func colorTapped() { select(option: .color) }

    private func select(option: OptionType) {
        selectedOption = option
        bigsizeCheckbox?.setImage(UIImage(named: option == .bigSize ? "Circle_checkbox" : "BlueCircle"), for: .normal)
        sizeCheckbox?.setImage(UIImage(named: option == .size ? "Circle_checkbox" : "BlueCircle"), for: .normal)
        ageCheckbox?.setImage(UIImage(named: option == .age ? "Circle_checkbox" : "BlueCircle"), for: .normal)
        colorCheckbox?.setImage(UIImage(named: option == .color ? "Circle_checkbox" : "BlueCircle"), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedOption = nil
        hideAllSpecifications()
        specificationCount = 0
        [bigsizeCheckbox, sizeCheckbox, ageCheckbox, colorCheckbox].forEach {
            $0?.setImage(UIImage(named: "BlueCircle"), for: .normal)
        }
        quantity = 1
    }
}
