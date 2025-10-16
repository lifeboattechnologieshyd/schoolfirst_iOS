//
//  CourseCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 29/07/25.
//

import UIKit
import Kingfisher

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var lblAudience: UILabel!
    @IBOutlet weak var btnWatchDemo: UIButton!
    @IBOutlet weak var btnCost: UIButton!
    @IBOutlet weak var lblRemarks: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblCourseName: UILabel!
    @IBOutlet weak var imgCourse: UIImageView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
        btnWatchDemo.applyCardShadow()
        btnWatchDemo.titleLabel?.font = UIFont.lexend(.bold, size: 14)
        btnCost.titleLabel?.font = UIFont.lexend(.bold, size: 14)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupCell(course: Course) {
        self.imgCourse.loadImage(url: course.thumbnailImage)
        self.lblCourseName.text = course.name
        self.lblDuration.text = "\(course.duration) Hours"
        self.lblAudience.text = "\(course.audience)"
    }
    
    @IBAction func onClickPay(_ sender: UIButton) {
        print("user wants to buy")
    }
    
    @IBAction func onClickWatchDemo(_ sender: UIButton) {
        print("demo played")
    }
}
