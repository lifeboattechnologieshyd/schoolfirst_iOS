//
//  EventTableCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 31/08/25.
//

import UIKit

class EventTableCell: UITableViewCell {

    @IBOutlet weak var heightOfStudentView: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var eventImageView: UIImageView!
    
    
    @IBOutlet weak var topToStudentView: NSLayoutConstraint!
    @IBOutlet weak var topToLayout: NSLayoutConstraint!
    
    
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func config(event: Event) {
        self.heightOfStudentView.constant = 0
        self.eventImageView.loadImage(url: event.image)
        self.lblTitle.text = event.name
        self.lblDescription.text = event.description
        self.lblDate.text = event.date.fromyyyyMMddtoDDMMMYYYY() + " | " + event.time.to12HourTime()
    }
    
}
