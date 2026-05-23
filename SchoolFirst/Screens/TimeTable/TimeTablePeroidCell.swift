//
//  TimeTablePeroidCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 12/11/25.
//

import UIKit

class TimeTablePeroidCell: UITableViewCell {

    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var lblSessionName: UILabel!
    @IBOutlet weak var lblTeacherName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    
    @IBOutlet weak var bottomLine: UIView!

    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupSession(session : ScheduleItem, isLast: Bool = false) {
        self.lblStartTime.text = session.start_display
        self.lblDuration.text = "\(session.session_duration) Mins"
        self.lblSessionName.text = session.subject_name ?? session.session_name
        self.lblTeacherName.text = session.teacher_name
        self.imgView.loadImage(url: session.session_icon ?? "")
        self.bottomLine.isHidden = isLast
    }
    
}
