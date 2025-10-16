//
//  FeelsCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 26/08/25.
//

import UIKit
import YouTubeiOSPlayerHelper

class FeelsCell: UITableViewCell {

    @IBOutlet weak var playerView: YTPlayerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func config(feel: ReadingShort){
        let playerVars: [String: Any] = [
            "playsinline": 1,   // plays inside the cell
            "autoplay": 1,
            "modestbranding": 1,
            "showinfo": 0,
            "rel": 0
        ]
        playerView.load(withVideoId: feel.youtubeID!, playerVars: playerVars)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
