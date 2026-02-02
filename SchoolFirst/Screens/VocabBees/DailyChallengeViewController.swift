//
//  DailyChallengeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import UIKit
import AVFoundation
import Lottie

class DailyChallengeViewController: UIViewController {
    
    var player: AVPlayer?
    var playerObserver: Any?
    var timer: Timer?
    var remainingSeconds: Int = 60
    var isTimeOutSubmission: Bool = false

    @IBOutlet weak var viewLottie: LottieAnimationView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var audioButtonsStackView: UIStackView!
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var bottomlbl: UILabel!
    @IBOutlet weak var topLbl: UILabel!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var lblActualSpelling: UILabel!
    @IBOutlet weak var lblEnteredSpelling: UILabel!
    @IBOutlet weak var lblWordsCount: UILabel!
    
    @IBOutlet weak var definitionStack: UIStackView!
    @IBOutlet weak var originStack: UIStackView!
    @IBOutlet weak var usageStack: UIStackView!
    @IBOutlet weak var otherStack: UIStackView!
    
    var typedText: String = ""
    var words = [WordInfo]()
    var totalWords = 10
    
    var currentWordIndex = 0 {
        didSet { updateProgressLabel() }
    }
    
    var hasValidWord: Bool {
        return currentWordIndex >= 0 && currentWordIndex < words.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        slider.minimumValue = 0
        slider.maximumValue = 10
        viewLottie.isHidden = true
        lblTitle.text = "Daily Challenge - \(UserManager.shared.vocabBee_selected_date.date.fromyyyyMMddtoDDMMYYYY())"
        timerLbl.text = "60 Seconds Left..."

        getWords()
    }
    
    func resetResultView() {
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        lblActualSpelling.isHidden = true
        bottomlbl.isHidden = true
        topLbl.isHidden = true
        congratsLbl.isHidden = true
        txtField.text = ""
        typedText = ""
        viewLottie.stop()
        viewLottie.isHidden = true
    }
    
    func playSuccessLottie() {
        viewLottie.animation = LottieAnimation.named("vocabbee_success")
        viewLottie.loopMode = .playOnce
        viewLottie.isHidden = false
        viewLottie.play()
    }
    
    @IBAction func onClickExit(_ sender: UIButton) {
        stopTimer()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        stopTimer()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNextWord(_ sender: UIButton) {
        stopTimer()
        resetResultView()
        
        guard currentWordIndex + 1 < totalWords else {
            showChallengeCompleteAlert()
            return
        }
        currentWordIndex += 1
        setupPlayer()
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        guard hasValidWord else { return }
        isTimeOutSubmission = false
        submitWord()
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        guard hasValidWord else { return }
        
        stopTimer()
        
        submitSkippedWord()
        
        resultView.isHidden = false
        
        viewLottie.stop()
        viewLottie.isHidden = true
        
        congratsLbl.text = "Word Skipped!"
        congratsLbl.isHidden = false
        
        topLbl.text = "You skipped this word"
        topLbl.textAlignment = .center
        topLbl.isHidden = false
        
        bottomlbl.isHidden = true
        
        lblEnteredSpelling.text = "The correct spelling is:"
        lblEnteredSpelling.font = UIFont(name: "Lexend-Medium", size: 16)
        lblEnteredSpelling.textColor = .black
        lblEnteredSpelling.textAlignment = .center
        lblEnteredSpelling.isHidden = false
        
        let userFont = txtField.font ?? UIFont.systemFont(ofSize: 24)
        let correctWordAttr = NSAttributedString(
            string: words[currentWordIndex].word.uppercased(),
            attributes: [
                .font: userFont,
                .foregroundColor: UIColor.black
            ]
        )
        
        lblActualSpelling.attributedText = correctWordAttr
        lblActualSpelling.textAlignment = .center
        lblActualSpelling.isHidden = false
        lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)
        
        txtField.text = ""
    }
    
    @IBAction func onTapListen(_ sender: UIButton) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].pronunciation)
    }
    
    @IBAction func onClickDefination(_ sender: UITapGestureRecognizer) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].definitionVoice)
    }
    
    @IBAction func onClickOrigin(_ sender: UITapGestureRecognizer) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].originVoice)
    }
    
    @IBAction func onClickUsage(_ sender: UITapGestureRecognizer) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].usageVoice)
    }
    
    @IBAction func onClickOther(_ sender: UITapGestureRecognizer) {
        guard hasValidWord else { return }
        if let ov = words[currentWordIndex].othersVoice {
            playWordAudio(url: ov)
        }
    }
    
    @IBAction func onDefinationClick(_ sender: UIButton) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].definitionVoice)
    }
    
    @IBAction func onOriginClick(_ sender: UIButton) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].originVoice)
    }
    
    @IBAction func onUsageClick(_ sender: UIButton) {
        guard hasValidWord else { return }
        playWordAudio(url: words[currentWordIndex].usageVoice)
    }
    
    @IBAction func onOtherClick(_ sender: UIButton) {
        guard hasValidWord else { return }
        if let ov = words[currentWordIndex].othersVoice {
            playWordAudio(url: ov)
        }
    }
    
    func updateProgressLabel() {
        DispatchQueue.main.async {
            self.lblWordsCount.text = "\(self.currentWordIndex + 1) / \(self.totalWords)"
            self.slider.maximumValue = Float(self.totalWords)
            self.slider.value = Float(self.currentWordIndex + 1)
        }
    }
    
    func setupPlayer() {
        guard hasValidWord else {
            print("⚠️ Invalid word index for setupPlayer: \(currentWordIndex)")
            return
        }
        startTimer()
        playWordAudio(url: words[currentWordIndex].pronunciation)
    }
    
    func playWordAudio(url: String) {
        guard let audioURL = URL(string: url) else {
            print("❌ Invalid audio URL")
            return
        }

        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }

        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)

        player?.play()

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("✅ Audio finished playing")
        }
    }

    func startTimer() {
        stopTimer()
        remainingSeconds = 60
        timerLbl.text = "\(remainingSeconds) Seconds Left..."
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.timerLbl.text = "\(self.remainingSeconds) Seconds Left..."
            
            if self.remainingSeconds <= 0 {
                t.invalidate()
                self.timer = nil
                self.autoSubmitEmptyAnswer()
            }
        }
    }
    
    func autoSubmitEmptyAnswer() {
        isTimeOutSubmission = true
        txtField.text = ""
        submitWord()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func submitSkippedWord() {
        guard hasValidWord else { return }
        
        let payload: [String: Any] = [
            "answer": "",
            "word_id": words[currentWordIndex].id,
            "grade_id": UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
        ]
        
        NetworkManager.shared.request(
            urlString: API.VOCABEE_SUBMIT_WORD,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<WordAnswer>, NetworkError>) in
            switch result {
            case .success(let info):
                print("Skip submitted: \(info.success)")
            case .failure(let error):
                print("Skip submit error: \(error.localizedDescription)")
            }
        }
    }

    func submitWord() {
        guard hasValidWord else {
            print("⚠️ Invalid word index on submitWord: \(currentWordIndex)")
            return
        }
        showLoader()
        let enteredText = txtField.text ?? ""
        
        let payload: [String: Any] = [
            "answer": enteredText,
            "word_id": words[currentWordIndex].id,
            "grade_id": UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
        ]
        
        NetworkManager.shared.request(
            urlString: API.VOCABEE_SUBMIT_WORD,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<WordAnswer>, NetworkError>) in
            
            DispatchQueue.main.async {
                self.stopTimer()
                self.hideLoader()
                switch result {
                    
                case .success(let info):
                    guard info.success, let data = info.data else {
                        self.showAlert(msg: info.description ?? "Something went wrong")
                        return
                    }
                    
                    self.resultView.isHidden = false
                    
                    if data.isCorrect {
                        
                        self.bottomlbl.isHidden = true
                        self.topLbl.isHidden = true
                        self.congratsLbl.isHidden = false
                        
                        self.playSuccessLottie()
                        
                        self.congratsLbl.text = "Congratulations! Try the next word!"
                        self.lblEnteredSpelling.text = "You've got it right!"
                        self.lblEnteredSpelling.textAlignment = .center
                        self.lblEnteredSpelling.numberOfLines = 0
                        self.lblEnteredSpelling.isHidden = false
                        
                        self.lblActualSpelling.text = data.correctAnswer.uppercased()
                        self.lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 28)
                        self.lblActualSpelling.textColor = UIColor.black
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false
                        
                    } else {

                        self.viewLottie.stop()
                        self.viewLottie.isHidden = true

                        if self.isTimeOutSubmission {
                            self.topLbl.text = "You ran out of time"
                            self.congratsLbl.text = "Time's up! ⏰"
                        } else {
                            self.topLbl.text = "Oops! You got it wrong"
                            self.congratsLbl.text = "That's Okay! Try the next word!"
                        }

                        self.topLbl.textAlignment = .center
                        self.topLbl.isHidden = false
                        self.congratsLbl.isHidden = false

                        let wrongText = self.txtField.text ?? ""
                        let wrongAttr = NSAttributedString(
                            string: wrongText.uppercased(),
                            attributes: [
                                .font: UIFont.boldSystemFont(ofSize: 24),
                                .foregroundColor: UIColor.systemRed,
                                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                .strikethroughColor: UIColor.systemRed
                            ]
                        )

                        self.bottomlbl.attributedText = wrongAttr
                        self.bottomlbl.textAlignment = .center
                        self.bottomlbl.numberOfLines = 0
                        self.bottomlbl.isHidden = false

                        self.lblActualSpelling.text = data.correctAnswer.uppercased()
                        self.lblActualSpelling.font = UIFont(name: "Lora-Bold", size: 32) ?? UIFont.boldSystemFont(ofSize: 32)
                        self.lblActualSpelling.textColor = UIColor.black
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false

                        self.lblEnteredSpelling.text = "Correct Spelling is as follows!"
                        self.lblEnteredSpelling.isHidden = false
                    }
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getWords() {
        showLoader()
        let url = API.VOCABEE_GET_WORDS_BY_DATES +
            "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)" +
            "&grade=\(UserManager.shared.vocabBee_selected_grade.id)" +
            "&date=\(UserManager.shared.vocabBee_selected_date.date)"
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { (result: Result<APIResponse<[WordInfo]>, NetworkError>) in
            
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                    
                case .success(let info):
                    if info.success, let data = info.data {
                        self.words = data
                        self.totalWords = self.words.count
                        self.currentWordIndex = 0
                        if self.totalWords > 0 {
                            self.resetResultView()
                            self.setupPlayer()
                        } else {
                            self.showNoWordsMessage()
                        }
                    }
                    
                case .failure(let error):
                    switch error {
                    case .noaccess:
                        self.handleLogout()
                    default:
                        self.showAlert(msg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func showNoWordsMessage() {
        let alert = UIAlertController(
            title: "No Words",
            message: "There are no words available for today. Please check another date.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    func showChallengeCompleteAlert() {
        let alert = UIAlertController(
            title: "Challenge Complete! 🎉",
            message: "You've completed today's daily challenge. Great job!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        player?.pause()
        player = nil
    }
}
