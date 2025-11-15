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
        lblTItle.setHTML("", font: .lexend(.semiBold, size: 16))
        lblDescription.setHTML("", font: .lexend(.regular, size: 14))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func config(news: Bulletin) {
        lblTItle.setHTML(news.title, font: .lexend(.bold, size: 16))
        lblDescription.setHTML( news.description ?? "", font: .lexend(.regular, size: 14))
        imgVw.loadImage(url: news.images?.first ?? "")
        lblTItle.font = .lexend(.semiBold, size: 16)
        lblDescription.font = .lexend(.regular, size: 14)
        if let cats = news.categories {
            lblheading.text = "\(cats[0]) | \(news.approvedAt!.getTimeAgo())"
        }
    }
    
    @IBAction func onClickReadMore(_ sender: Any) {
        
    }
}
