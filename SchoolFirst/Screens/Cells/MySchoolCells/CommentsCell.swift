//
//  CommentsCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 03/01/26.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var updatedTimeLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var topLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }
    
    func setupUI() {
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topLbl.isHidden = true
        userId.text = nil
        commentLbl.text = nil
        updatedTimeLbl.text = nil
        profileImg.image = nil
    }
    
    func configure(with comment: Comment, showTopLabel: Bool) {
        userId.text = comment.userName
        commentLbl.text = comment.comment
        updatedTimeLbl.text = comment.formattedTime
        profileImg.loadImage(url: comment.profilePic ?? "", placeHolderImage: "userImage")
        
        // Show topLbl only for first comment
        topLbl.isHidden = !showTopLabel
    }
}
