//
//  DailyChallengeViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 22/10/25.
//

import  UIKit
import AVFoundation

class DailyChallengeViewController:UIViewController, AlphabetKeyboardDelegate{
    var player: AVPlayer?
    var playerObserver: Any?

    
    @IBOutlet weak var keyboardView: AlphabetKeyboardView!
    @IBOutlet weak var btnBack: UIButton!
    var typedText: String = ""
    
    @IBAction func onClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playWordAudio()

    }
    func playWordAudio() {
        guard let url = URL(string: "https://your-s3-bucket.s3.amazonaws.com/word.mp3") else {
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
                self?.playWordAudio()
            }
        player?.play()
        print("🔊 Playing word audio...")
    }
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView.delegate = self

    }
    
    func didTapLetter(_ letter: String) {
           typedText.append(letter)
           print(typedText)
       }

       func didTapDelete() {
           guard !typedText.isEmpty else { return }
           typedText.removeLast()
           print(typedText)
       }

       func didTapSubmit() {
           print("Submitted: \(typedText)")
       }

}
