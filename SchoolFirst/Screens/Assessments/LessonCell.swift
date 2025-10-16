//
//  LessonCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 11/10/25.
//

import UIKit

class LessonCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var btnSelect: UIButton!
    
    var onSelectingLesson: ((Int) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func onClickSelectLesson(_ sender: UIButton) {
        onSelectingLesson(sender.tag)
    }
}
