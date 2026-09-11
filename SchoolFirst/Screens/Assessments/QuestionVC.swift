//
//  QuestionVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 08/11/25.
//

import UIKit
import Lottie
import AVFoundation

class QuestionVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var Backbutton: UIButton!
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
    @IBOutlet weak var questionscoreLbl: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var hintVw: UIView!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var stackViewOptions: UIStackView!
    @IBOutlet weak var okBtn: UIButton!

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

    // MARK: - Properties

    var current_question = 0

    var darkOverlayView: UIView!

    let slashLayer = CAShapeLayer()

    let speechSynthesizer = AVSpeechSynthesizer()

    var celebrationLottieView: LottieAnimationView!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        print("========================================")
        print("📚 QuestionVC Loaded")
        print("========================================")

        // Initial UI
        lblOptionA.text = ""
        lblOptionB.text = ""
        lblOptionC.text = ""
        lblOptionD.text = ""
        lblOptionHint.text = ""

        lblDesciption.text = ""
        questionscoreLbl.text = ""

        stackViewOptions.isHidden = true
        resultPopup.isHidden = true
        lottieViewImage.isHidden = true

        setupHintView()
        setupQuestionsView()
        drawSlash()
        setupCelebrationLottie()
    }

    // MARK: - Get Current Assessment

    private func getQuestions() -> [AssessmentQuestion] {

        return UserManager.shared.assessment_created_assessment.questions
    }

    // MARK: - Validate Current Question

    private func getCurrentQuestion() -> AssessmentQuestion? {

        let questions = getQuestions()

        guard !questions.isEmpty else {

            print("❌ Assessment contains 0 questions")

            return nil
        }

        guard current_question >= 0,
              current_question < questions.count else {

            print("❌ Current question index out of range")
            print("Current index: \(current_question)")
            print("Total questions: \(questions.count)")

            return nil
        }

        return questions[current_question]
    }

    // MARK: - Back

    @IBAction func onClickBack(_ sender: UIButton) {

        if let navigationController = self.navigationController {

            navigationController.popViewController(animated: true)

        } else {

            self.dismiss(animated: true)
        }
    }

    // MARK: - Celebration Lottie

    func setupCelebrationLottie() {

        celebrationLottieView = LottieAnimationView()

        celebrationLottieView.animation =
            LottieAnimation.named("Celebration")

        celebrationLottieView.contentMode = .scaleAspectFit
        celebrationLottieView.loopMode = .playOnce
        celebrationLottieView.animationSpeed = 1.0
        celebrationLottieView.backgroundColor = .clear
        celebrationLottieView.isHidden = true
        celebrationLottieView.isUserInteractionEnabled = false

        view.addSubview(celebrationLottieView)

        celebrationLottieView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            celebrationLottieView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            celebrationLottieView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            celebrationLottieView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            celebrationLottieView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }

    func playCorrectAnswerLottie() {

        guard celebrationLottieView != nil else {
            return
        }

        guard celebrationLottieView.animation != nil else {
            return
        }

        view.bringSubviewToFront(celebrationLottieView)

        celebrationLottieView.isHidden = false
        celebrationLottieView.currentProgress = 0

        celebrationLottieView.play { [weak self] completed in

            guard let self = self else {
                return
            }

            print("DEBUG: Lottie completed = \(completed)")

            DispatchQueue.main.async {

                self.celebrationLottieView.stop()
                self.celebrationLottieView.isHidden = true
                self.celebrationLottieView.currentProgress = 0
            }
        }
    }

    // MARK: - Hint

    func setupHintView() {

        hintVw.isHidden = true
        hintVw.layer.masksToBounds = true

        darkOverlayView = UIView(frame: view.bounds)

        darkOverlayView.backgroundColor =
            UIColor.black.withAlphaComponent(0.4)

        darkOverlayView.isHidden = true

        darkOverlayView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(overlayTapped)
        )

        darkOverlayView.addGestureRecognizer(tapGesture)

        view.addSubview(darkOverlayView)

        view.bringSubviewToFront(hintVw)

        okBtn.addTarget(
            self,
            action: #selector(okButtonTapped),
            for: .touchUpInside
        )
    }

    @objc func okButtonTapped() {

        hideHintView()
    }

    @objc func overlayTapped() {

        hideHintView()
    }

    func showHintView() {

        guard let question = getCurrentQuestion() else {
            return
        }

        hintLbl.text = question.hint

        darkOverlayView.isHidden = false
        darkOverlayView.alpha = 0

        hintVw.isHidden = false

        view.bringSubviewToFront(darkOverlayView)
        view.bringSubviewToFront(hintVw)

        okBtn.isUserInteractionEnabled = true
        hintVw.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0) {

            self.darkOverlayView.alpha = 0.5
        }
    }

    func hideHintView() {

        UIView.animate(
            withDuration: 0,
            animations: {

                self.darkOverlayView.alpha = 0

            },
            completion: { completed in

                if completed {

                    self.darkOverlayView.isHidden = true
                    self.hintVw.isHidden = true
                }
            }
        )
    }

    // MARK: - Speech

    @IBAction func onClickPlayBtn(_ sender: UIButton) {

        guard let question = getCurrentQuestion() else {
            return
        }

        let questionText = question.question
        let descriptionText = question.description

        let fullText = "\(questionText). \(descriptionText)"

        if speechSynthesizer.isSpeaking {

            speechSynthesizer.stopSpeaking(
                at: .immediate
            )
        }

        let utterance = AVSpeechUtterance(
            string: fullText
        )

        utterance.voice =
            AVSpeechSynthesisVoice(language: "en-US")

        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0

        speechSynthesizer.speak(utterance)
    }

    @IBAction func onClickOkBtn(_ sender: UIButton) {

        self.okBtn.titleLabel?.font =
            UIFont.lexend(.semiBold, size: 16)

        hideHintView()
    }

    // MARK: - Home

    @IBAction func onClickHome() {

        if speechSynthesizer.isSpeaking {

            speechSynthesizer.stopSpeaking(
                at: .immediate
            )
        }

        self.navigationController?.popToRootViewController(
            animated: true
        )
    }

    // MARK: - Play More

    @IBAction func onClickPlayMore() {

        guard let vc = storyboard?.instantiateViewController(
            identifier: "AssessmentsViewController"
        ) as? AssessmentsViewController else {

            print("❌ Could not open AssessmentsViewController")
            return
        }

        self.navigationController?.pushViewController(
            vc,
            animated: true
        )
    }

    // MARK: - Change Question

    func changeQuestion() {

        hintVw.isHidden = true
        darkOverlayView.isHidden = true

        // IMPORTANT:
        // Validate question before accessing array
        guard let question = getCurrentQuestion() else {

            print("❌ Cannot display question")

            stackViewOptions.isHidden = true

            lblQuestion.text = ""
            lblDesciption.text = ""

            let alert = UIAlertController(
                title: "No Questions Available",
                message: "No questions are available for this assessment.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                if let nav = self?.navigationController {
                    nav.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true)
                }
            })
            present(alert, animated: true)

            return
        }

        print("========================================")
        print("📖 Displaying Question")
        print("Question Index: \(current_question)")
        print("Question ID: \(question.id)")
        print("Question: \(question.question)")
        print("Options Count: \(question.options.count)")
        print("========================================")

        guard question.options.count >= 1 else {

            print("❌ Question has 0 options")

            self.showAlert(
                msg: "This question does not have options."
            )

            stackViewOptions.isHidden = true

            return
        }

        let questionMarks = question.marks

        self.questionscoreLbl.text =
            "\(questionMarks)"

        let totalQuestions = getQuestions().count

        lblQuestionNumber.text =
            "Question \(current_question + 1)/\(totalQuestions)"

        lblQuestion.animateTyping(
            text: question.question
        ) {

            self.lblDesciption.animateTyping(
                text: question.description
            ) {

                self.lblOptionA.text = question.options.indices.contains(0) ? question.options[0] : ""
                self.optionAView.isHidden = !question.options.indices.contains(0)

                self.lblOptionB.text = question.options.indices.contains(1) ? question.options[1] : ""
                self.optionBView.isHidden = !question.options.indices.contains(1)

                self.lblOptionC.text = question.options.indices.contains(2) ? question.options[2] : ""
                self.optionCView.isHidden = !question.options.indices.contains(2)

                self.lblOptionD.text = question.options.indices.contains(3) ? question.options[3] : ""
                self.optionDView.isHidden = !question.options.indices.contains(3)

                self.lblOptionHint.text =
                    "I don't know"

                self.stackViewOptions.isHidden = false
            }
        }
    }

    // MARK: - Setup Questions View

    func setupQuestionsView() {

        bgView.layer.cornerRadius = 16

        lblTitleA.text = "A"
        lblTitleB.text = "B"
        lblTitleC.text = "C"
        lblTitleD.text = "D"
        lblTitleHint.text = "E"

        lblTitleA.layer.cornerRadius =
            lblTitleA.frame.size.width / 2

        lblTitleB.layer.cornerRadius =
            lblTitleB.frame.size.width / 2

        lblTitleC.layer.cornerRadius =
            lblTitleC.frame.size.width / 2

        lblTitleD.layer.cornerRadius =
            lblTitleD.frame.size.width / 2

        lblTitleHint.layer.cornerRadius =
            lblTitleHint.frame.size.width / 2

        lblTitleHint.layer.masksToBounds = true
        lblTitleD.layer.masksToBounds = true
        lblTitleC.layer.masksToBounds = true
        lblTitleB.layer.masksToBounds = true
        lblTitleA.layer.masksToBounds = true

        // Add tap gesture
        for (index, view) in
                stackViewOptions.arrangedSubviews.enumerated() {

            view.tag = index

            view.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(optionTapped(_:))
            )

            view.addGestureRecognizer(tap)
        }

        // Only load question after validating data
        changeQuestion()
    }

    // MARK: - Result Popup

    func displayResultPopup() {

        self.bgView.isHidden = true
        self.resultPopup.isHidden = false
        self.topVw.isHidden = true

        let totalMarks =
            UserManager.shared
                .assessment_created_assessment
                .totalMarks

        self.slider.maximumValue =
            Float(totalMarks)

        self.lblTotalMarks.text =
            "\(totalMarks)"

        self.viewanswersButton.titleLabel?.font =
            UIFont.lexend(.semiBold, size: 20)

        if speechSynthesizer.isSpeaking {

            speechSynthesizer.stopSpeaking(
                at: .immediate
            )
        }
    }

    // MARK: - Get Stats

    func getStats() {

        showLoader()

        let payload = [

            "assessment_id":
                "\(UserManager.shared.assessment_created_assessment.id)",

            "student_id":
                "\(UserManager.shared.assessmentSelectedStudent.studentID)"
        ]

        NetworkManager.shared.request(
            urlString: API.ASSESSMENT_RESULTS,
            method: .POST,
            parameters: payload
        ) { (
            result: Result<
                APIResponse<AssessmentResult>,
                NetworkError
            >
        ) in

            self.hideLoader()

            switch result {

            case .success(let info):

                if info.success {

                    if let data = info.data {

                        DispatchQueue.main.async {

                            self.displayResultPopup()

                            self.slider.value =
                                Float(data.studentMarks)

                            self.slider.maximumValue =
                                Float(data.totalMarks)

                            // Prevent division by zero
                            if data.totalMarks > 0 {

                                let percentage =
                                    Int(
                                        Float(data.studentMarks)
                                        / Float(data.totalMarks)
                                        * 100
                                    )

                                self.lblPercentage.text =
                                    "\(percentage) %"

                            } else {

                                self.lblPercentage.text =
                                    "0 %"
                            }

                            self.slider.minimumValue = 0

                            self.lblMarks.text =
                                "\(data.studentMarks)"

                            self.lblTotalMarks.text =
                                "\(data.totalMarks)"

                            self.lblwrongAns.text =
                                "\(data.wrongQuestions)"

                            self.lblCorrectAns.text =
                                "\(data.correctQuestions)"

                            self.lblSkipAns.text =
                                "\(data.skippedQuestions)"
                        }
                    }

                } else {

                    print(info.description)
                }

            case .failure(let error):

                DispatchQueue.main.async {

                    switch error {

                    case .noaccess:

                        self.handleLogout()

                    default:

                        self.showAlert(
                            msg: error.localizedDescription
                        )

                        self.navigationController?.popViewController(
                            animated: true
                        )
                    }
                }
            }
        }
    }

    // MARK: - Attempt Answer

    func attemptAns(
        ans: String,
        index: Int
    ) {

        guard getCurrentQuestion() != nil else {
            return
        }

        showLoader()

        let question =
            UserManager.shared
                .assessment_created_assessment
                .questions[current_question]

        let url = API.ASSESSMENT_ATTEMPT

        let payload = [

            "question_id":
                "\(question.id)",

            "assessment_id":
                "\(UserManager.shared.assessment_created_assessment.id)",

            "student_id":
                "\(UserManager.shared.assessmentSelectedStudent.studentID)",

            "answer":
                ans
        ]

        NetworkManager.shared.request(
            urlString: url,
            method: .POST,
            parameters: payload
        ) { (
            result: Result<
                APIResponse<AssessmentAnswerResponse>,
                NetworkError
            >
        ) in

            self.hideLoader()

            switch result {

            case .success(let info):

                if info.success {

                    DispatchQueue.main.async {

                        self.highlightSelection(
                            at: index
                        )
                    }

                } else {

                    print(info.description)
                }

            case .failure(let error):

                DispatchQueue.main.async {

                    switch error {

                    case .noaccess:

                        self.handleLogout()

                    default:

                        self.showAlert(
                            msg: error.localizedDescription
                        )

                        self.navigationController?.popViewController(
                            animated: true
                        )
                    }
                }
            }
        }
    }

    // MARK: - Option Tapped

    @objc func optionTapped(
        _ sender: UITapGestureRecognizer
    ) {

        guard let view = sender.view else {
            return
        }

        guard let question = getCurrentQuestion() else {
            return
        }

        let generator =
            UIImpactFeedbackGenerator(style: .medium)

        generator.prepare()
        generator.impactOccurred()

        UIView.animate(
            withDuration: 0.1,
            animations: {

                view.transform =
                    CGAffineTransform(
                        scaleX: 0.95,
                        y: 0.95
                    )

            },
            completion: { _ in

                UIView.animate(withDuration: 0) {

                    view.transform = .identity
                }
            }
        )

        // E - Hint
        if view.tag == 4 {

            self.showHintView()
            return
        }

        // A/B/C/D
        guard view.tag >= 0,
              view.tag < 4 else {

            print("❌ Invalid option tag: \(view.tag)")
            return
        }

        // Make sure API returned 4 options
        guard question.options.count >= 4 else {

            print("❌ Not enough options")
            return
        }

        let selected_ans =
            question.options[view.tag]

        self.attemptAns(
            ans: selected_ans,
            index: view.tag
        )

        for v in stackViewOptions.arrangedSubviews {

            v.isUserInteractionEnabled = false
        }
    }

    // MARK: - Highlight Selection

    func highlightSelection(at index: Int) {

        guard let question = getCurrentQuestion() else {
            return
        }

        let ans = question.answer

        var isCorrectAnswer = false

        switch index {

        case 0:

            isCorrectAnswer =
                (ans == lblOptionA.text)

            self.optionAView.backgroundColor =
                isCorrectAnswer
                ? UIColor(hex: "00BB00")
                : UIColor(hex: "#FFA700")

        case 1:

            isCorrectAnswer =
                (ans == lblOptionB.text)

            self.optionBView.backgroundColor =
                isCorrectAnswer
                ? UIColor(hex: "00BB00")
                : UIColor(hex: "#FFA700")

        case 2:

            isCorrectAnswer =
                (ans == lblOptionC.text)

            self.optionCView.backgroundColor =
                isCorrectAnswer
                ? UIColor(hex: "00BB00")
                : UIColor(hex: "#FFA700")

        case 3:

            isCorrectAnswer =
                (ans == lblOptionD.text)

            self.optionDView.backgroundColor =
                isCorrectAnswer
                ? UIColor(hex: "00BB00")
                : UIColor(hex: "#FFA700")

        case 4:

            self.optionHintView.backgroundColor =
                UIColor(hex: "#FFA700")

        default:

            break
        }

        if isCorrectAnswer {

            playCorrectAnswerLottie()
        }

        if !isCorrectAnswer {

            if ans == lblOptionA.text {

                self.optionAView.backgroundColor =
                    UIColor(hex: "00BB00")

            } else if ans == lblOptionB.text {

                self.optionBView.backgroundColor =
                    UIColor(hex: "00BB00")

            } else if ans == lblOptionC.text {

                self.optionCView.backgroundColor =
                    UIColor(hex: "00BB00")

            } else if ans == lblOptionD.text {

                self.optionDView.backgroundColor =
                    UIColor(hex: "00BB00")
            }
        }

        let totalQuestions =
            UserManager.shared
                .assessment_created_assessment
                .questions
                .count

        if totalQuestions >
            current_question + 1 {

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3
            ) {

                self.resetOptionsAndMoveToNextQuestion()
            }

        } else {

            self.getStats()
        }
    }

    // MARK: - Reset And Next Question

    func resetOptionsAndMoveToNextQuestion() {

        for v in
                self.stackViewOptions.arrangedSubviews {

            v.backgroundColor = .systemBackground
            v.isUserInteractionEnabled = true
            v.layer.borderColor =
                UIColor.primary.cgColor
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

        self.hintVw.isHidden = true
        self.darkOverlayView.isHidden = true

        self.lottieViewImage.isHidden = true
        self.lottieViewImage.stop()

        self.celebrationLottieView?.stop()
        self.celebrationLottieView?.isHidden = true
        self.celebrationLottieView?.currentProgress = 0

        if speechSynthesizer.isSpeaking {

            speechSynthesizer.stopSpeaking(
                at: .immediate
            )
        }

        let totalQuestions =
            UserManager.shared
                .assessment_created_assessment
                .questions
                .count

        // Prevent going beyond array
        guard current_question + 1 < totalQuestions else {

            print("⚠️ No more questions")
            return
        }

        current_question += 1

        print(
            "➡️ Moving to question \(current_question + 1)"
        )

        self.changeQuestion()
    }

    // MARK: - View Answers

    @IBAction func onClickAnswers(_ sender: UIButton) {

        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "AllQuestionsVC"
        ) as? AllQuestionsVC else {

            print("❌ Could not open AllQuestionsVC")
            return
        }

        vc.assessmentId =
            UserManager.shared
                .assessment_created_assessment.id

        vc.is_back_to_root = true

        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }

    // MARK: - Draw Slash

    func drawSlash() {

        slashLayer.removeFromSuperlayer()

        let path = UIBezierPath()

        path.move(
            to: CGPoint(
                x: scoreVw.bounds.width * 0.20,
                y: scoreVw.bounds.height * 0.85
            )
        )

        path.addLine(
            to: CGPoint(
                x: scoreVw.bounds.width * 0.85,
                y: scoreVw.bounds.height * 0.20
            )
        )

        slashLayer.path = path.cgPath

        slashLayer.strokeColor =
            UIColor.primary.cgColor

        slashLayer.lineWidth = 4

        scoreVw.layer.addSublayer(
            slashLayer
        )
    }
}
