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
    
    @IBOutlet weak var viewLottie: LottieAnimationView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var audioButtonsStackView: UIStackView!
    
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickNextWord(_ sender: UIButton) {
        resetResultView()
        
        guard currentWordIndex + 1 < totalWords else {
            print("✅ Daily challenge completed")
            navigationController?.popViewController(animated: true)
            return
        }
        currentWordIndex += 1
        setupPlayer()
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        guard hasValidWord else { return }
        submitWord()
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        guard hasValidWord else { return }
        resetResultView()
        
        guard currentWordIndex + 1 < totalWords else {
            print("✅ Daily challenge completed")
            navigationController?.popViewController(animated: true)
            return
        }
        currentWordIndex += 1
        setupPlayer()
    }
    
    @IBAction func onTapListen(_ sender: UIButton) {
        guard hasValidWord else { return }
        setupPlayer()
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
        playWordAudio(url: words[currentWordIndex].pronunciation)
    }
    
    func playWordAudio(url: String) {
        guard let audioURL = URL(string: url) else {
            print("❌ Invalid audio URL")
            return
        }
        
        // Remove previous observer
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
    
    func submitWord() {
        guard hasValidWord else {
            print("⚠️ Invalid word index on submitWord: \(currentWordIndex)")
            return
        }
        
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
                switch result {
                    
                case .success(let info):
                    guard info.success, let data = info.data else {
                        self.showAlert(msg: info.description ?? "Something went wrong")
                        return
                    }
                    
                    self.resultView.isHidden = false
                    
                    if data.isCorrect {
                        
                        // Hide wrong answer UI elements
                        self.bottomlbl.isHidden = true
                        self.topLbl.isHidden = true
                        self.congratsLbl.isHidden = false
                        
                        // Play Success Lottie
                        self.playSuccessLottie()
                        
                        self.congratsLbl.text = "Congratulations! Try the next word!"
                        self.lblEnteredSpelling.text = "You’ve got it right!"
                        self.lblEnteredSpelling.textAlignment = .center
                        self.lblEnteredSpelling.numberOfLines = 0
                        self.lblEnteredSpelling.isHidden = false
                        
                        // Show correct spelling in green
                        self.lblActualSpelling.text = data.correctAnswer.uppercased()
                        self.lblActualSpelling.font = UIFont.boldSystemFont(ofSize: 28)
                        self.lblActualSpelling.textColor = UIColor.black
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false
                        
                    } else {
                        
                        // Stop and hide lottie
                        self.viewLottie.stop()
                        self.viewLottie.isHidden = true
                        
                        // Show wrong answer UI elements
                        self.topLbl.text = "Oops! You got it wrong"
                        self.topLbl.textAlignment = .center
                        self.topLbl.isHidden = false
                        
                        self.congratsLbl.text = "That's Okay! Try the next word!"
                        self.congratsLbl.isHidden = false
                        
                        // Show wrong answer with strikethrough
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
                        
                        // Show correct answer in green
                        self.lblActualSpelling.text = data.correctAnswer.uppercased()
                        self.lblActualSpelling.font = UIFont(name: "Lora-Bold", size: 32) ?? UIFont.boldSystemFont(ofSize: 32)
                        self.lblActualSpelling.textColor = UIColor.black
                        self.lblActualSpelling.textAlignment = .center
                        self.lblActualSpelling.isHidden = false
                        
                        // Hide lblEnteredSpelling for wrong answer
                        self.lblEnteredSpelling.isHidden = false 
                        self.lblEnteredSpelling.text = "Correct Spelling is as follows!"
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
        let url = API.VOCABEE_GET_WORDS_BY_DATES +
            "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)" +
            "&grade=\(UserManager.shared.vocabBee_selected_grade.id)" +
            "&date=\(UserManager.shared.vocabBee_selected_date.date)"
        
        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { (result: Result<APIResponse<[WordInfo]>, NetworkError>) in
            
            DispatchQueue.main.async {
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
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        player?.pause()
        player = nil
    }
}
