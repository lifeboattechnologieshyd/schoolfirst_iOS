//
//  QuestionCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class QuestionCell: UICollectionViewCell {

    @IBOutlet weak var optionE: UIButton!
    @IBOutlet weak var optionD: UIButton!
    @IBOutlet weak var optionC: UIButton!
    @IBOutlet weak var optionB: UIButton!
    @IBOutlet weak var optionA: UIButton!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var Question: UITextView!
    @IBOutlet weak var QuestionNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Prevent UITextViews from blocking touches
        Question.isScrollEnabled = false
        Question.isEditable = false
        Question.isUserInteractionEnabled = false

        Description.isScrollEnabled = false
        Description.isEditable = false
        Description.isUserInteractionEnabled = false
        
        resetOptions()
    }

    // ⭐ RESET BUTTON COLORS (FIX OVERLAP BUG)
    func resetOptions() {
        let yellow = UIColor(red: 254/255, green: 242/255, blue: 0/255, alpha: 1)
        let blue = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1)
        
        [optionA, optionB, optionC, optionD, optionE].forEach {
            $0?.backgroundColor = blue
            $0?.setTitleColor(yellow, for: .normal)
            $0?.layer.cornerRadius = 20
            $0?.clipsToBounds = true
        }
    }

    // Ensure buttons always get touch
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for btn in [optionA, optionB, optionC, optionD, optionE] {
            if let b = btn {
                let converted = b.convert(point, from: self)
                if b.point(inside: converted, with: event) {
                    return b
                }
            }
        }
        return super.hitTest(point, with: event)
    }
}
