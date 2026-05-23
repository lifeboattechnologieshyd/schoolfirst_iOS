//
//  QuestionOneCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 11/11/25.
//

import UIKit

class QuestionOneCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblQuestionNumber: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var stackViewOptions: UIStackView!
    @IBOutlet weak var optionAView: UIView!
    @IBOutlet weak var lblTitleA: UILabel!
    @IBOutlet weak var lblOptionA: UILabel!
    @IBOutlet weak var optionBView: UIView!
    @IBOutlet weak var lblTitleB: UILabel!
    @IBOutlet weak var lblOptionB: UILabel!
    @IBOutlet weak var optionCView: UIView!
    @IBOutlet weak var lblTitleC: UILabel!
    @IBOutlet weak var lblOptionC: UILabel!
    @IBOutlet weak var optionDView: UIView!
    @IBOutlet weak var lblTitleD: UILabel!
    @IBOutlet weak var lblOptionD: UILabel!
    @IBOutlet weak var btnAnswer: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setup(row: Int, question: AssessmentQuestionHistoryDetails, ques: Int = 15){
        lblOptionA.text = ""
        lblOptionB.text = ""
        lblOptionC.text = ""
        lblOptionD.text = ""
        
        self.lblDesciption.text = ""
        setupQuestionsView()
        changeQuestion(row: row, question: question, ques:ques)
    }
    
    func setupQuestionsView() {
        bgView.layer.cornerRadius = 16
        lblTitleA.text = "A"
        lblTitleA.layer.cornerRadius = lblTitleA.frame.size.width/2
        lblTitleB.layer.cornerRadius = lblTitleB.frame.size.width/2
        lblTitleC.layer.cornerRadius = lblTitleC.frame.size.width/2
        lblTitleD.layer.cornerRadius = lblTitleD.frame.size.width/2
        
        lblTitleD.layer.masksToBounds = true
        lblTitleC.layer.masksToBounds = true
        lblTitleB.layer.masksToBounds = true
        lblTitleA.layer.masksToBounds = true
        
        lblTitleB.text = "B"
        lblTitleC.text = "C"
        lblTitleD.text = "D"
    }
    
    
    func changeQuestion(row : Int,  question: AssessmentQuestionHistoryDetails, ques: Int = 15) {
        lblQuestionNumber.text = "Question \(row+1)/\(ques)"
        lblScore.text = "Score  \(question.isCorrect ? question.marks : 0)/\(question.questionMarks)"
        btnAnswer.setImage(question.isCorrect ? UIImage(named: "check-2") : UIImage(named: "redNo"), for: .normal)
        lblQuestion.text = question.questionName
        lblDesciption.text = question.answerDescription
        // after a sec
        self.lblOptionA.text = question.options[0]
        self.lblOptionB.text = question.options[1]
        self.lblOptionC.text = question.options[2]
        self.lblOptionD.text = question.options[3]
        
        self.optionAView.backgroundColor = question.options[0] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[0] ? UIColor(hex: "#FFA700") : .white
        self.optionBView.backgroundColor = question.options[1] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[1] ? UIColor(hex: "#FFA700") : .white
        self.optionCView.backgroundColor = question.options[2] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[2] ? UIColor(hex: "#FFA700") : .white
        self.optionDView.backgroundColor = question.options[3] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[3] ? UIColor(hex: "#FFA700") : .white
        
        self.lblTitleA.backgroundColor = question.options[0] == question.correctAnswer ? .white : question.userAnswer == question.options[0] ? .white : .primary
        self.lblTitleB.backgroundColor = question.options[1] == question.correctAnswer ? .white : question.userAnswer == question.options[1] ? .white : .primary
        self.lblTitleC.backgroundColor = question.options[2] == question.correctAnswer ? .white : question.userAnswer == question.options[2] ? .white : .primary
        self.lblTitleD.backgroundColor = question.options[3] == question.correctAnswer ? .white : question.userAnswer == question.options[3] ? .white : .primary
        
        self.lblTitleA.textColor = question.options[0] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[0] ? UIColor(hex: "#FFA700") : .secondary
        
        self.lblTitleB.textColor = question.options[1] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[1] ? UIColor(hex: "#FFA700") : .secondary
        
        self.lblTitleC.textColor = question.options[2] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[2] ? UIColor(hex: "#FFA700") : .secondary
        
        self.lblTitleD.textColor = question.options[3] == question.correctAnswer ? UIColor(hex: "#00BB00") : question.userAnswer == question.options[3] ? UIColor(hex: "#FFA700") : .secondary
        
    }
}
