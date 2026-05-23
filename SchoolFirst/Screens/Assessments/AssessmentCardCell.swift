//
//  AssessmentCardCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 24/11/25.
//

import UIKit

class AssessmentCardCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var btnSeeAns: UIButton!
    @IBOutlet weak var imgStudent: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    var onSelectAns: ((Int) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(assessment : AssessmentSummary){
        self.lblTitle.text = assessment.assessmentName
        self.lblDescription.text = assessment.description
        self.lblScore.text = "You’ve scored \(assessment.studentMarks)/\(assessment.totalMarks)"
        
        let progress = Float(assessment.studentMarks) / Float(assessment.totalMarks)
        progressView.setProgress(progress, animated: false)
        
        self.imgStudent.loadImage(url: UserManager.shared.assessmentSelectedStudent.image ?? "")
    }
    
    @IBAction func onClickSeeAnswers(_ sender: UIButton) {
        onSelectAns(sender.tag)
    }
    
}
