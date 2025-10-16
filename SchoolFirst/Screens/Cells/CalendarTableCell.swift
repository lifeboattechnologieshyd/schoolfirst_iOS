//
//  CalendarTableCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 31/08/25.
//

import UIKit
import YouTubeiOSPlayerHelper
import AVFoundation

class CalendarTableCell: UITableViewCell {
    
    
    
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblWriteup: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblBenifit: UILabel!
    var videoUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.isHidden = true
        btnPlay.isHidden = false
    }
    override func prepareForReuse() {
           super.prepareForReuse()
           resetPlayer()
       }
    private func resetPlayer() {
        imgVw.isHidden = false
        btnPlay.isHidden = false
        playerView.isHidden = true
        playerView.stopVideo()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(calender: LifeSkillPrompt) {
        imgVw.loadImage(url: calender.image)
        let prompt = madeAttributeString(boldPart: "Prompt:", desc: " \(calender.prompt)")
        let benifit = madeAttributeString(boldPart: "Benifit:", desc: " \(calender.benefit)")
        let writeup = madeAttributeString(boldPart: "Writeup:", desc: " \(calender.description)")
        lblPrompt.numberOfLines = 0
        lblBenifit.numberOfLines = 0
        lblWriteup.numberOfLines = 0
        
        lblPrompt.lineBreakMode = .byWordWrapping
        lblBenifit.lineBreakMode = .byWordWrapping
        lblWriteup.lineBreakMode = .byWordWrapping
        
        lblPrompt.attributedText = prompt
        lblBenifit.attributedText = benifit
        lblWriteup.attributedText = writeup
        
        videoUrl = calender.youtubeVideoURL
        

        
        
    }
    
    func madeAttributeString(boldPart: String, desc:String) -> NSMutableAttributedString{
        let normalPart = desc
        let attributedString = NSMutableAttributedString(
            string: boldPart,
            attributes: [
                .font: UIFont.lexend(.bold, size: 16)
            ]
        )
        attributedString.append(NSAttributedString(
            string: normalPart,
            attributes: [
                .font: UIFont.lexend(.regular, size: 16)
            ]
        ))
        return attributedString
    }
    
    private func extractYoutubeId(from url: String) -> String? {
        if let url = URL(string: url), let host = url.host {
            if host.contains("youtu.be") {
                return url.lastPathComponent
            } else if host.contains("youtube.com"),
                      let queryItems = URLComponents(string: url.absoluteString)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
        }
        return nil
    }
    @IBAction func onClickPlay(_ sender: UIButton) {
        if let url = videoUrl {
            btnPlay.isHidden = true
            playerView.isHidden = false
            guard let videoID = extractYoutubeId(from: url) else { return }
            playerView.load(withVideoId: videoID, playerVars: ["playsinline": 1, "autoplay": 1])
        }
    }
}
