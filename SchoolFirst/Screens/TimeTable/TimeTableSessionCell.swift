//
//  TimeTableSessionCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/11/25.
//

import UIKit

class TimeTableSessionCell: UITableViewCell {

    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSessionName: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupSession(session : ScheduleItem) {
        self.lblStartTime.text = session.start_display
        self.lblDuration.text = "\(session.session_duration) Mins"
        self.lblSessionName.text = session.session_name
        self.imgView.loadImage(url: session.session_icon ?? "")
    }
    
}
