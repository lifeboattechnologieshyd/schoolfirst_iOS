//
//  HWFooterCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/11/25.
//

import UIKit

class HWFooterCell: UITableViewCell {
    
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var completeVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        resetState()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetState()
    }
    
    private func resetState() {
        completeVw.isHidden = true
        lblCount.isHidden = false
        lblCount.text = ""
    }
    
    func configure(studentsCompleted: Int, userDoneCount: Int, totalCount: Int) {
        guard totalCount > 0 else {
            lblCount.text = "No homework items"
            completeVw.isHidden = true
            return
        }
        
        let allCompleted = userDoneCount >= totalCount
        let otherStudents = max(0, studentsCompleted - 1)
        
        if allCompleted {
            completeVw.isHidden = false
            lblCount.isHidden = otherStudents > 0
            lblCount.text = otherStudents == 0 ? " You are the first one who completed!" : ""
        } else {
            completeVw.isHidden = true
            lblCount.text = studentsCompleted > 0
                ? "\(studentsCompleted) Students have completed this. Have you?"
                : "Be the first to complete this homework!"
        }
    }
}
