//
//  PracticeGameController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import UIKit
import AVFoundation
import Lottie

class PracticeGameController: UIViewController {
    
    var player: AVPlayer?
    var playerObserver: Any?
    var timer: Timer?
    var remainingSeconds: Int = 60
    var isTimeOutSubmission: Bool = false

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblWordsCount: UILabel!
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var bottomlbl: UILabel!
    @IBOutlet weak var SkipBtn: UIButton!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var lblActualSpelling: UILabel!
    @IBOutlet weak var lblEnteredSpelling: UILabel!
    @IBOutlet weak var viewLottie: LottieAnimationView!
    
    var word_info: WordInfo?
    var wordsCompleted: Int = 0
    
    var hasWord: Bool {
        return word_info != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradeName = UserManager.shared.vocabBee_selected_grade.name ?? "Grade"
        lblTitle.text = "Practice | \(gradeName)"

        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        updateWordsCount()
        getWords()
    }

    func updateWordsCount() {
        lblWordsCount.text = "Words: \(wordsCompleted)"
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        stopTimer()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        guard hasWord else {
            showAlert(msg: "No word available")
            return
        }
        isTimeOutSubmission = false
        submitWord()
    }

    @IBAction func onClickSkip(_ sender: UIButton) {
        guard let word = word_info else { return }
        
        stopTimer()
        
        submitSkippedWord()
        
        resultView.isHidden = false
        
        viewLottie.stop()
        viewLottie.isHidden = true
        
        congratsLbl.text = "Word Skipped!"
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
            string: word.word.uppercased(),
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

    @IBAction func onClickNextWord(_ sender: UIButton) {
        stopTimer()
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        txtField.text = ""
        viewLottie.stop()
        viewLottie.isHidden = true
        getWords(playAudio: true)
    }

    func submitSkippedWord() {
        guard let word = word_info else { return }
        
        let payload: [String: Any] = [
            "user_answer": "",
            "word_id": word.id,
            "grade_id": UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
        ]
        
        NetworkManager.shared.request(
            urlString: API.VOCABEE_PRACTICE_SUBMIT,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<VocabBeeWordResponse>, NetworkError>) in
            switch result {
            case .success(let info):
                print("Skip submitted: \(info.success)")
            case .failure(let error):
                print("Skip submit error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func onTapListen(_ sender: UIButton) {
        guard hasWord else {
            showAlert(msg: "No word available")
            return
        }
        setupPlayer()
    }
    
    @IBAction func onClickDefination(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.definitionVoice)
    }
    
    @IBAction func onClickOrigin(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.originVoice)
    }
    
    @IBAction func onClickUsage(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        playWordAudio(url: word.usageVoice)
    }
    
    @IBAction func onClickOther(_ sender: UITapGestureRecognizer) {
        guard let word = word_info else { return }
        if let ov = word.othersVoice {
            playWordAudio(url: ov)
        }
    }
    
    @IBAction func onClickExit(_ sender: UIButton) {
        stopTimer()
        navigationController?.popViewController(animated: true)
    }
    
   
    func setupPlayer() {
        guard let word = word_info else {
            print("⚠️ No word available for player")
            return
        }

        startTimer()
        playWordAudio(url: word.pronunciation)
    }

    func submitWord() {
        guard let word = word_info else {
            print("⚠️ No word available to submit")
            return
        }
        showLoader()
        let enteredText = txtField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        let payload: [String: Any] = [
            "user_answer": enteredText,
            "word_id": word.id,
            "grade_id": UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
        ]
        
        NetworkManager.shared.request(
            urlString: API.VOCABEE_PRACTICE_SUBMIT,
            method: .POST,
            parameters: payload
        ) { [weak self] (result: Result<APIResponse<VocabBeeWordResponse>, NetworkError>) in

            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                case .success(let info):
                    guard info.success, let data = info.data else {
                        self.showAlert(msg: info.description ?? "Something went wrong")
                        return
                    }

                    self.resultView.isHidden = false

                    if data.isCorrect {

                        self.wordsCompleted += 1
                        self.updateWordsCount()
                        self.bottomlbl.isHidden = true
                        self.topLbl.isHidden = true
                        self.playSuccessLottie()
                        self.congratsLbl.text = "Congratulations! Try new word"

                        self.lblEnteredSpelling.text = "You've got it right!"
                        self.lblEnteredSpelling.font = self.txtField.font
                        self.lblEnteredSpelling.textColor = .black
                        self.lblEnteredSpelling.textAlignment = .center
                        self.lblEnteredSpelling.numberOfLines = 0
                        self.lblEnteredSpelling.isHidden = false

                        let userFont = self.txtField.font ?? UIFont.systemFont(ofSize: 24)
                        let correctAttr = NSAttributedString(
                            string: data.correctAnswer.uppercased(),
                            attributes: [
                                .font: userFont,
                                .foregroundColor: UIColor.black
                            ]
                        )

                        self.lblActualSpelling.attributedText = correctAttr
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false
                        self.lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)

                    } else {

                        self.viewLottie.stop()
                        self.viewLottie.isHidden = true

                        let wrongText = self.txtField.text ?? ""

                        if self.isTimeOutSubmission {
                            self.congratsLbl.text = "Time's up! ⏰"
                            self.topLbl.text = "You ran out of time"
                        } else {
                            self.congratsLbl.text = "That's Okay! Try the next word!"
                            self.topLbl.text = "Oops! You got it wrong"
                        }

                        self.topLbl.textAlignment = .center
                        self.topLbl.isHidden = false

                        let wrongAttr = NSAttributedString(
                            string: wrongText.uppercased(),
                            attributes: [
                                .font: UIFont.boldSystemFont(ofSize: 24),
                                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                .strikethroughColor: UIColor.systemRed
                            ]
                        )

                        self.bottomlbl.attributedText = wrongAttr
                        self.bottomlbl.textAlignment = .center
                        self.bottomlbl.numberOfLines = 0
                        self.bottomlbl.isHidden = false

                        self.lblEnteredSpelling.text = "Correct Spelling is as follows!"
                        self.lblEnteredSpelling.font = UIFont(name: "Lexend-Medium", size: 16)
                        self.lblEnteredSpelling.textColor = .black
                        self.lblEnteredSpelling.textAlignment = .center
                        self.lblEnteredSpelling.isHidden = false

                        let userFont = self.txtField.font ?? UIFont.systemFont(ofSize: 24)
                        let correctWordAttr = NSAttributedString(
                            string: data.correctAnswer,
                            attributes: [
                                .font: userFont,
                                .foregroundColor: UIColor.black
                            ]
                        )

                        self.lblActualSpelling.attributedText = correctWordAttr
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false
                        self.lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 24)
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

    func getWords(playAudio: Bool = true) {
        showLoader()
        
        let url = API.VOCABEE_GET_PRACTISE_WORDS +
            "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)" +
            "&grade=\(UserManager.shared.vocabBee_selected_grade.id)"
        
        let shouldPlayAudio = playAudio

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { (result: Result<APIResponse<WordInfo>, NetworkError>) in

            DispatchQueue.main.async {
                self.hideLoader()
                switch result {

                case .success(let info):
                    if info.success, let data = info.data {
                        self.word_info = data
                        self.resultView.isHidden = true
                        self.lblEnteredSpelling.isHidden = true
                        self.viewLottie.isHidden = true
                        
                        if shouldPlayAudio {
                            self.setupPlayer()
                        } else {
                            self.startTimer()
                        }
                    } else {
                        self.showNoMoreWordsAlert()
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

    @IBAction func onDefinitionClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.definitionVoice)
    }

    @IBAction func onUsageCLick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.usageVoice)
    }

    @IBAction func onOriginClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        playWordAudio(url: word.originVoice)
    }

    @IBAction func onOthersClick(_ sender: UIButton) {
        guard let word = word_info else { return }
        if let ov = word.othersVoice {
            playWordAudio(url: ov)
        }
    }

    func showNoMoreWordsAlert() {
        let alert = UIAlertController(
            title: "Practice Complete! 🎉",
            message: "You've practiced \(wordsCompleted) words. Great job!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
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

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("✅ Audio finished playing")
        }

        player?.play()
        print("🔊 Playing audio...")
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

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func autoSubmitEmptyAnswer() {
        isTimeOutSubmission = true
        txtField.text = ""
        submitWord()
    }

    func playSuccessLottie() {
        viewLottie.animation = LottieAnimation.named("vocabbee_success")
        viewLottie.loopMode = .playOnce
        viewLottie.isHidden = false
        viewLottie.play()
    }

    func playWrongLottie() {
        viewLottie.animation = LottieAnimation.named("vocabbee_wrong")
        viewLottie.loopMode = .playOnce
        viewLottie.isHidden = false
        viewLottie.play()
    }

    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        player?.pause()
        player = nil
    }
}
