//
//  DailyChallengeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit
import AVFoundation

class PracticeGameController:UIViewController, AlphabetKeyboardDelegate{
    var player: AVPlayer?
    var playerObserver: Any?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblQuestions: UILabel!
    
    @IBOutlet weak var keyboardView: AlphabetKeyboardView!
    @IBOutlet weak var btnBack: UIButton!

    var typedText: String = ""
    
    
    var words = [WordInfo]()
    
    var totalWords = 10
    var currentWordIndex = 0 {
        didSet {
            updateProgressLabel()
        }
    }
    func updateProgressLabel() {
        
        DispatchQueue.main.async {
            self.lblQuestions.text = "\(self.currentWordIndex) / \(self.totalWords)"
        }
    }
    
     @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        self.submitWord()
        
    }
    
    @IBAction func onTapListen(_ sender: UIButton) {
        self.setupPlayer()
        
    }
    @IBAction func onTapListen2(_ sender: UIButton) {
        self.setupPlayer()
    }
    
    
    func setupPlayer(){
        DispatchQueue.main.async {
            self.playWordAudio(url: self.words[self.currentWordIndex].pronunciation)
        }
    }
    
    func submitWord(){
        
        var payload = [
            "user_answer":txtField.text!,
            "word_id":self.words[currentWordIndex].id
        ]
        
        NetworkManager.shared.request(urlString: API.VOCABEE_SUBMIT_WORD, method: .POST, parameters: payload) { (result: Result<APIResponse<WordAnswer>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        if self.currentWordIndex < self.totalWords-1 {
                            self.currentWordIndex += 1
                            DispatchQueue.main.async {
                                self.txtField.text = ""
                                self.typedText = ""
                                self.updateProgressLabel()
                                self.setupPlayer()
                            }
                        }
                        if self.currentWordIndex == self.totalWords-1 {
                            // showCompletionAlert()
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
                    }
                }
            }
        }
    }
    
    func showResultPopup(word: String) {
        let popup = VocabBeeResultPopup.instantiate()
//        popup.wordLabel.text = word
//        popup.levelLabel.text = "Level \(level) → Level \(nextLevel)"
//        popup.messageLabel.text = "Congratulations! You’re in Level \(nextLevel)"
        popup.show(on: self.view)
    }
    
    func getWords(){
        let url = API.VOCABEE_GET_WORDS_BY_DATES + "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)&grade=\(UserManager.shared.vocabBee_selected_grade.id)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[WordInfo]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.words = data
                    }
                    DispatchQueue.main.async {
                        self.setupPlayer()
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
                    }
                }
            }
        }
    }
    func playWordAudio(url: String) {
        guard let url = URL(string: url) else {
            print("❌ Invalid audio URL")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            print("✅ Audio finished playing")
        }
        player?.play()
        print("🔊 Played a word audio...")
    }
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView.delegate = self
        getWords()
        updateProgressLabel()
    }
    
    
    
    func didTapLetter(_ letter: String) {
        typedText.append(letter)
        txtField.text = typedText
    }
    
    func didTapDelete() {
        guard !typedText.isEmpty else { return }
        typedText.removeLast()
        txtField.text = typedText
    }
    
    func didTapSubmit() {
        print("Submitted: \(typedText)")
    }
    
}
