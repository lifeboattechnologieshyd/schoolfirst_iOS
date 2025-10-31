//
//  SelectDateTableViewCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

 
import UIKit

protocol SelectDateCellDelegate: AnyObject {
    func didTaphalfday()
}

class SelectDateTableViewCell: UITableViewCell {

    @IBOutlet weak var multipleVw: UIView!
    @IBOutlet weak var shravVw: UIView!
    @IBOutlet weak var singleVw: UIView!
    @IBOutlet weak var abhiVw: UIView!
    @IBOutlet weak var fulldayButton: UIButton!
    @IBOutlet weak var halfdayButton: UIButton!
    @IBOutlet weak var fulldayVw: UIView!
    @IBOutlet weak var dateVw: UIView!
    @IBOutlet weak var halfdayVw: UIView!

    weak var delegate: SelectDateCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        setStyle(for: abhiVw, radius: 25, borderHex: "#0B569A")
        setStyle(for: shravVw, radius: 25, borderHex: "#CBE5FD")
        setStyle(for: singleVw, radius: 8, borderHex: "#0B569A", shadow: true)
        setStyle(for: multipleVw, radius: 8, shadow: true)
        setStyle(for: dateVw, radius: 5, shadow: true)
        setStyle(for: halfdayVw, radius: 16)
        setStyle(for: fulldayVw, radius: 16)
    }

    private func setStyle(for view: UIView, radius: CGFloat, borderHex: String? = nil, shadow: Bool = false) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = false
        
        if let hex = borderHex, let color = UIColor.fromHex(hex) {
            view.layer.borderWidth = 1.5
            view.layer.borderColor = color.cgColor
        }

        if shadow {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.15
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
        }
    }

    @IBAction func halfdayTapped(_ sender: UIButton) {
        delegate?.didTaphalfday()
    }
}

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let rgb = Int(s, radix: 16) else { return nil }
        return UIColor(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

