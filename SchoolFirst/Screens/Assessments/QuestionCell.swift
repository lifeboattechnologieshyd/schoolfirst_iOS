//
//  QuestionCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 10/11/25.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var aVw: UIView!
    @IBOutlet weak var QuestionButton: UIButton!
    @IBOutlet weak var bVw: UIView!
    @IBOutlet weak var TopVw: UIView!
    @IBOutlet weak var BlueVw: UIView!
    @IBOutlet weak var cVw: UIView!
    @IBOutlet weak var dVw: UIView!
    @IBOutlet weak var QuestionVw: UILabel!
    @IBOutlet weak var BottomVw: UIView!

    @IBOutlet weak var topVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        setupGestures()
        
        // Default state
        topVwHeightConstraint.constant = 302
        bottomHeightConstraint.constant = 0
        questionHeightConstraint.constant = 0
    }
    
    private func setupUI() {
        [aVw, bVw, cVw, dVw].forEach {
            $0?.layer.cornerRadius = 21
            $0?.layer.borderWidth = 1.5
            $0?.layer.borderColor = UIColor(red: 0.04, green: 0.34, blue: 0.60, alpha: 1).cgColor
            $0?.backgroundColor = .white
            $0?.isUserInteractionEnabled = true
        }

        // ✅ BLUE VIEW BORDER (#0B569A)
        BlueVw.layer.cornerRadius = 21
        BlueVw.layer.borderWidth = 1.5
        BlueVw.layer.borderColor = UIColor(red: 0.04, green: 0.34, blue: 0.60, alpha: 1).cgColor
        BlueVw.backgroundColor = .white
    }
    
    private func setupGestures() {
        aVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aTapped)))
        cVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cTapped)))

        QuestionButton.addTarget(self, action: #selector(questionTapped), for: .touchUpInside)
    }
    
    @objc private func aTapped() {
        topVwHeightConstraint.constant = 0
        bottomHeightConstraint.constant = 302
        questionHeightConstraint.constant = 0
        layoutIfNeeded()
    }
    
    @objc private func cTapped() {
        [aVw, bVw, cVw, dVw].forEach { $0?.backgroundColor = .white }
        cVw.backgroundColor = UIColor(red: 0.93, green: 0.30, blue: 0.37, alpha: 1)
        layoutIfNeeded()
    }
    
    @objc private func questionTapped() {
        topVwHeightConstraint.constant = 0
        bottomHeightConstraint.constant = 0
        questionHeightConstraint.constant = 231
        layoutIfNeeded()
    }
}

