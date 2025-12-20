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
    
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblWordsCount: UILabel!
    
    @IBOutlet weak var congratsLbl: UILabel!
    @IBOutlet weak var bottomlbl: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var lblActualSpelling: UILabel!
    @IBOutlet weak var lblEnteredSpelling: UILabel!
    @IBOutlet weak var viewLottie: LottieAnimationView!
    
    var word_info: WordInfo?
    var wordsCompleted: Int = 0
    
    // Safety check
    var hasWord: Bool {
        return word_info != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        updateWordsCount()
        getWords()
    }
    
    func updateWordsCount() {
        lblWordsCount.text = "Words: \(wordsCompleted)"
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        guard hasWord else {
            showAlert(msg: "No word available")
            return
        }
        submitWord()
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        guard hasWord else { return }
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        txtField.text = ""
        viewLottie.stop()
        viewLottie.isHidden = true
        getWords()
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNextWord(_ sender: UIButton) {
        resultView.isHidden = true
        lblEnteredSpelling.isHidden = true
        txtField.text = ""
        viewLottie.stop()
        viewLottie.isHidden = true
        getWords()
    }
    
    func setupPlayer() {
        guard let word = word_info else {
            print("⚠️ No word available for player")
            return
        }
        playWordAudio(url: word.pronunciation)
    }
    
    func submitWord() {
        guard let word = word_info else {
            print("⚠️ No word available to submit")
            return
        }
        
        let enteredText = txtField.text ?? ""
        
        let payload: [String: Any] = [
            "answer": enteredText,
            "word_id": word.id,
            "grade_id": UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
        ]
        
        NetworkManager.shared.request(
            urlString: API.VOCABEE_SUBMIT_WORD,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<WordAnswer>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let info):
                    guard info.success, let data = info.data else {
                        self.showAlert(msg: info.description ?? "Something went wrong")
                        return
                    }
                    
                    self.resultView.isHidden = false
                
                    
                    if data.isCorrect {
                        // CORRECT ANSWER
                        self.wordsCompleted += 1
                        self.updateWordsCount()
                        
                       
    
                        self.bottomlbl.isHidden = true
                        self.topLbl.isHidden = true

                        // Play Success Lottie
                        self.playSuccessLottie()
                        
                        
                        self.congratsLbl.text = "Congratulations! Try new word"
                       // self.lblEnteredSpelling.attributedText = fullText
                        self.lblEnteredSpelling.textAlignment = .center
                        self.lblEnteredSpelling.numberOfLines = 0
                        self.lblEnteredSpelling.isHidden = false
                        
                          self.lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 28)
                        
                    } else {

                        self.viewLottie.stop()
                        self.viewLottie.isHidden = true

                        self.resultView.isHidden = false

                        let wrongText = self.txtField.text ?? ""
                        self.congratsLbl.text = "That’s Okay! Try the next word!"
                        self.topLbl.text = "Oops! You got it wrong"
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

                        self.lblActualSpelling.text = data.correctAnswer.uppercased()
                        self.lblEnteredSpelling.font = UIFont(name: "Lora-Bold", size: 32)
                        self.lblActualSpelling.textColor = .black
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false

                        self.bottomlbl.textAlignment = .center
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
        
        let url = API.VOCABEE_GET_PRACTISE_WORDS +
            "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)" +
            "&grade=\(UserManager.shared.vocabBee_selected_grade.id)"

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { (result: Result<APIResponse<WordInfo>, NetworkError>) in

            DispatchQueue.main.async {
                switch result {

                case .success(let info):
                    if info.success, let data = info.data {
                        self.word_info = data
                        self.resultView.isHidden = true
                        self.lblEnteredSpelling.isHidden = true
                        self.viewLottie.isHidden = true
                        self.setupPlayer()
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
