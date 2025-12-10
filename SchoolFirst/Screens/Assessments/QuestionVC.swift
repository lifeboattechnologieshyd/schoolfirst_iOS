//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//
import UIKit
import Lottie

class QuestionVC: UIViewController {
    
    @IBOutlet weak var lottieViewImage: LottieAnimationView!
    @IBOutlet weak var resultPopup: UIView!
    @IBOutlet weak var scoreVw: UIView!
    @IBOutlet weak var scoreNumberLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewanswersButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblQuestionNumber: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
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
    @IBOutlet weak var optionHintView: UIView!
    @IBOutlet weak var lblTitleHint: UILabel!
    @IBOutlet weak var lblOptionHint: UILabel!
    
    
    @IBOutlet weak var lblMarks: UILabel!
    
    
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblSkipAns: UILabel!
    @IBOutlet weak var lblwrongAns: UILabel!
    @IBOutlet weak var lblCorrectAns: UILabel!
    @IBOutlet weak var lblTotalMarks: UILabel!
    
    var current_question = 0
    
    let slashLayer = CAShapeLayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblOptionA.text = ""
        lblOptionB.text = ""
        lblOptionC.text = ""
        lblOptionD.text = ""
        lblOptionHint.text = ""
        
        self.lblDesciption.text = ""
        self.stackViewOptions.isHidden = true
        self.resultPopup.isHidden = true
        self.setupQuestionsView()

        drawSlash()
    }
    
    
    @IBAction func onClickHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onClickPlayMore() {
        let vc = storyboard?.instantiateViewController(identifier: "AssessmentsViewController") as! AssessmentsViewController
        self.navigationController?.popToViewController(vc, animated: true)
    }
    
    func changeQuestion() {
        lblQuestionNumber.text = "Question \(current_question+1)/\(UserManager.shared.assessment_created_assessment.numberOfQuestions)"
        lblQuestion.animateTyping(text: UserManager.shared.assessment_created_assessment.questions[current_question].question) {
            self.lblDesciption.animateTyping(text: UserManager.shared.assessment_created_assessment.questions[self.current_question].description) {
                // after a sec
                self.lblOptionA.text = UserManager.shared.assessment_created_assessment.questions[self.current_question].options[0]
                self.lblOptionB.text = UserManager.shared.assessment_created_assessment.questions[self.current_question].options[1]
                self.lblOptionC.text = UserManager.shared.assessment_created_assessment.questions[self.current_question].options[2]
                self.lblOptionD.text = UserManager.shared.assessment_created_assessment.questions[self.current_question].options[3]
                self.lblOptionHint.text = "I do not know"
                self.stackViewOptions.isHidden = false
            }
            
        }
    }
    
    func setupQuestionsView() {
        bgView.layer.cornerRadius = 16
        lblTitleA.text = "A"
        lblTitleA.layer.cornerRadius = lblTitleA.frame.size.width/2
        lblTitleB.layer.cornerRadius = lblTitleB.frame.size.width/2
        lblTitleC.layer.cornerRadius = lblTitleC.frame.size.width/2
        lblTitleD.layer.cornerRadius = lblTitleD.frame.size.width/2
        lblTitleHint.layer.cornerRadius = lblTitleHint.frame.size.width/2
        
        lblTitleHint.layer.masksToBounds = true
        lblTitleD.layer.masksToBounds = true
        lblTitleC.layer.masksToBounds = true
        lblTitleB.layer.masksToBounds = true
        lblTitleA.layer.masksToBounds = true
        
        lblTitleB.text = "B"
        lblTitleC.text = "C"
        lblTitleD.text = "D"
        lblTitleHint.text = "E"
        
        for (index, view) in stackViewOptions.arrangedSubviews.enumerated() {
            view.tag = index
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            view.addGestureRecognizer(tap)
        }
        changeQuestion()
    }
    func displayResultPopup(){
        self.bgView.isHidden = true
        self.resultPopup.isHidden = false
        self.slider.maximumValue = Float(UserManager.shared.assessment_created_assessment.totalMarks)
        self.lblTotalMarks.text = "\((UserManager.shared.assessment_created_assessment.totalMarks))"
    }
    
    func getStats(){
        let payload = [
            "assessment_id":"\(UserManager.shared.assessment_created_assessment.id)",
            "student_id":"\(UserManager.shared.assessmentSelectedStudent.studentID)"
        ]
        NetworkManager.shared.request(urlString: API.ASSESSMENT_RESULTS,method: .POST, parameters: payload) { (result: Result<APIResponse<AssessmentResult>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.displayResultPopup()
                            self.slider.value = Float(data.studentMarks)
                            self.slider.maximumValue = Float(data.totalMarks)
                            var percentage = Int(Float(data.studentMarks)/Float(data.totalMarks) * 100)
                            self.lblPercentage.text = "\(percentage) %"

                            self.slider.minimumValue = 0
                            self.lblMarks.text = "\(data.studentMarks)"
                            self.lblTotalMarks.text = "\(data.totalMarks)"
                            self.lblwrongAns.text = "\(data.wrongQuestions)"
                            self.lblCorrectAns.text = "\(data.correctQuestions)"
                            self.lblSkipAns.text = "\(data.skippedQuestions)"
                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func attemptAns(ans: String, index: Int){
        let url = API.ASSESSMENT_ATTEMPT
        let payload  =
        ["question_id":"\(UserManager.shared.assessment_created_assessment.questions[self.current_question].id)","assessment_id":"\(UserManager.shared.assessment_created_assessment.id)","student_id":"\(UserManager.shared.assessmentSelectedStudent.studentID)",
         "answer":ans]
        
        NetworkManager.shared.request(urlString: url,method: .POST, parameters: payload) { (result: Result<APIResponse<AssessmentAnswerResponse>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        DispatchQueue.main.async {
                            self.highlightSelection(at: index)
                        }
                    }
                }else{
                    print(info.description)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
    }
    
    @objc func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        print("Option tapped: \(view.tag)")
        UIView.animate(withDuration: 0.1,
                       animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        })
        if view.tag == 4 {
            // hint
            self.attemptAns(ans: "", index: view.tag)
        }else {
            let selected_ans = UserManager.shared.assessment_created_assessment.questions[self.current_question].options[view.tag]
            self.attemptAns(ans: selected_ans, index: view.tag)
        }
        for view in stackViewOptions.arrangedSubviews {
            view.isUserInteractionEnabled = false
        }
    }
    
    func highlightSelection(at index: Int) {
        let ans = UserManager.shared.assessment_created_assessment.questions[self.current_question].answer
        switch index {
        case 0:
            self.optionAView.backgroundColor = ans == lblOptionA.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
        case 1:
            self.optionBView.backgroundColor = ans == lblOptionB.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
            
        case 2:
            self.optionCView.backgroundColor = ans == lblOptionC.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
            
        case 3:
            self.optionDView.backgroundColor = ans == lblOptionD.text ? UIColor(hex: "00BB00") : UIColor(hex: "#FFA700")
            
        case 4:
            self.optionHintView.backgroundColor = UIColor(hex: "#FFA700")
            
        default:
            break
        }
        if ans == lblOptionA.text {
            self.optionAView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionB.text {
            self.optionBView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionC.text {
            self.optionCView.backgroundColor = UIColor(hex: "00BB00")
        } else if ans == lblOptionD.text {
            self.optionDView.backgroundColor = UIColor(hex: "00BB00")
        }
        print(UserManager.shared.assessment_created_assessment.numberOfQuestions)
        if UserManager.shared.assessment_created_assessment.numberOfQuestions > current_question+1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                for (_, v) in self.stackViewOptions.arrangedSubviews.enumerated() {
                    v.backgroundColor = .systemBackground
                    v.isUserInteractionEnabled = true
                    v.layer.borderColor = UIColor.primary.cgColor
                }
                self.lblDesciption.text = ""
                self.stackViewOptions.isHidden = true
                self.lblTitleA.backgroundColor = .primary
                self.lblTitleA.textColor = .secondary
                self.lblOptionA.textColor = .black
                
                self.lblTitleB.backgroundColor = .primary
                self.lblTitleB.textColor = .secondary
                self.lblOptionB.textColor = .black
                
                self.lblTitleC.backgroundColor = .primary
                self.lblTitleC.textColor = .secondary
                self.lblOptionC.textColor = .black
                
                self.lblTitleD.backgroundColor = .primary
                self.lblTitleD.textColor = .secondary
                self.lblOptionD.textColor = .black
                
                self.lblTitleHint.backgroundColor = .primary
                self.lblTitleHint.textColor = .secondary
                self.lblOptionHint.textColor = .black
                
                self.current_question += 1
                self.changeQuestion()
            }
        }else{
            self.getStats()
        }
    }
    
    @IBAction func onClickAnswers(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllQuestionsVC") as! AllQuestionsVC
        vc.assessmentId = UserManager.shared.assessment_created_assessment.id
        vc.is_back_to_root = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func drawSlash() {
        slashLayer.removeFromSuperlayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: scoreVw.bounds.width * 0.20, y: scoreVw.bounds.height * 0.85))
        path.addLine(to: CGPoint(x: scoreVw.bounds.width * 0.85, y: scoreVw.bounds.height * 0.20))
        slashLayer.path = path.cgPath
        slashLayer.strokeColor = UIColor.primary.cgColor
        slashLayer.lineWidth = 4
        scoreVw.layer.addSublayer(slashLayer)
    }
    
}


