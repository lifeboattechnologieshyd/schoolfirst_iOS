//
//  DemoVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 07/01/26.
//
import UIKit
import AVKit

class DemoVC: UIViewController {
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var lblCourseName: UILabel!
    
    var videoURL: String?
    var courseName: String?
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCourseName.text = courseName
        setupVideo()
    }
    
    func setupVideo() {
        guard let urlString = videoURL, let url = URL(string: urlString) else { return }
        
        player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        addChild(playerVC)
        playerVC.view.frame = videoContainerView.bounds
        videoContainerView.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)
        
        player?.play()
    }
    
    @IBAction func onClickClose(_ sender: UIButton) {
        player?.pause()
        dismiss(animated: true)
    }
}
