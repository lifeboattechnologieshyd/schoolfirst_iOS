//
//  NewsCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var lblheading: UILabel!
    
    
    @IBOutlet weak var imgVw: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblDescription.numberOfLines = 0
        lblDescription.lineBreakMode = .byWordWrapping
        lblDescription.setContentCompressionResistancePriority(.required, for: .vertical)
        lblTItle.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func config(news: Bulletin) {
        lblDescription.attributedText = news.cachedDescriptionHTML
        lblTItle.attributedText = news.cachedTitleHTML
        
        self.imgVw.loadImage(url: news.images?.first ?? "")
        if let cats = news.categories {
            self.lblheading.text = "\(news.approvedAt!.getTimeAgo())"
        }
        self.lblDescription.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTItle.attributedText = nil
        lblDescription.attributedText = nil
        lblheading.text = nil
        imgVw.image = nil
    }

    
    @IBAction func onClickReadMore(_ sender: Any) {
        
    }
}
