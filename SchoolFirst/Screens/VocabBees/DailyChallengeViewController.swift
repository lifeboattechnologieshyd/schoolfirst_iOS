//
//  DailyChallengeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit
import AVFoundation

class DailyChallengeViewController:UIViewController {
    var player: AVPlayer?
    var playerObserver: Any?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!

    @IBOutlet weak var lblWordsCount: UILabel!
    var typedText: String = ""
    var words = [WordInfo]()
    
    var totalWords = 10
    var currentWordIndex = 0 {
        didSet {
            updateProgressLabel()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getWords()
        self.slider.minimumValue = 0
        self.slider.maximumValue = 10
        updateProgressLabel()
    }
    
    func updateProgressLabel() {
        
        DispatchQueue.main.async {
            self.lblWordsCount.text = "\(self.currentWordIndex + 1) / \(self.totalWords)"
            self.slider.value = Float((self.currentWordIndex + 1)/10)
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
   
    
    @IBAction func onClickDefination(_ sender: UITapGestureRecognizer) {
        self.playWordAudio(url: self.words[self.currentWordIndex].definitionVoice)
        
    }
    
    
    @IBAction func onClickOrigin(_ sender: UITapGestureRecognizer) {
        self.playWordAudio(url: self.words[self.currentWordIndex].originVoice)

    }
    
    
    @IBAction func onClickUsage(_ sender: UITapGestureRecognizer) {
        self.playWordAudio(url: self.words[self.currentWordIndex].usageVoice)

    }
    
    
    @IBAction func onClickOther(_ sender: UITapGestureRecognizer) {
        if let ov = self.words[self.currentWordIndex].othersVoice {
            self.playWordAudio(url: ov)
        }
    }
    
    @IBAction func onClickSkip(_ sender: UIButton) {
        self.submitWord()
    }
    
    func setupPlayer(){
        DispatchQueue.main.async {
            self.playWordAudio(url: self.words[self.currentWordIndex].pronunciation)
        }
    }
    
    func submitWord(){
        
        let payload = [
            "answer":txtField.text ?? "",
            "word_id":self.words[currentWordIndex].id,
            "grade_id":UserManager.shared.vocabBee_selected_grade.id,
            "student_id": UserManager.shared.vocabBee_selected_student.studentID
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
                                self.setupPlayer()
                            }
                        }
                        if self.currentWordIndex == self.totalWords-1 {
                            print("daily challenge completed")
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
    
//    func showResultPopup(word: String) {
//        let popup = VocabBeeResultPopup.instantiate()
////        popup.wordLabel.text = word
////        popup.levelLabel.text = "Level \(level) → Level \(nextLevel)"
////        popup.messageLabel.text = "Congratulations! You’re in Level \(nextLevel)"
//        popup.show(on: self.view)
//    }
    
    func getWords() {
        let url = API.VOCABEE_GET_WORDS_BY_DATES + "?student_id=\(UserManager.shared.vocabBee_selected_student.studentID)&grade=\(UserManager.shared.vocabBee_selected_grade.id)&date=\(UserManager.shared.vocabBee_selected_date.date)"
        
        NetworkManager.shared.request(urlString: url, method: .GET) { (result: Result<APIResponse<[WordInfo]>, NetworkError>)  in
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.words = data
                        self.totalWords =  self.words.count
                        self.currentWordIndex = 0
                    }
                    DispatchQueue.main.async {
                        if self.totalWords > 0 {
                            self.setupPlayer()
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
}
