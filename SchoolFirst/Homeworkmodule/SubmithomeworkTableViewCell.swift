//
//  SubmithomeworkTableViewCell.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/09/26.
//

import UIKit

class SubmithomeworkTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectLbl: NSLayoutConstraint!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var Textfield: UITextField!
    @IBOutlet weak var FilenameLbl: UILabel!
    
    @IBOutlet weak var HomeworkfileLbl: UILabel!
    @IBOutlet weak var AttachmentView: UIView!
    @IBOutlet weak var NametwocharectersLbl: UILabel!
    @IBOutlet weak var AttachmentButton: UIButton!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var TeachernameLbl: NSLayoutConstraint!
    @IBOutlet weak var HomeworktitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
