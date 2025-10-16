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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(news: Bulletin) {
        lblTItle.text = news.title
        lblDescription.text = news.description
        imgVw.loadImage(url: news.images?.first ?? "")
        if let cats = news.categories {
            lblheading.text = "\(cats[0]) | \(news.approvedAt!.getTimeAgo())"
        }
    }
    
    @IBAction func onClickReadMore(_ sender: Any) {
        
    }
}
