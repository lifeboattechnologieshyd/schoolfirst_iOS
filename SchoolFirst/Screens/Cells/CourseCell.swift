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
    
    var onWatchDemoTapped: (() -> Void)?
    var onBuyTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyCardShadow()
        btnWatchDemo.applyCardShadow()
        btnWatchDemo.titleLabel?.font = UIFont.lexend(.bold, size: 14)
        btnCost.titleLabel?.font = UIFont.lexend(.bold, size: 14)
    }
    
    func setupCell(course: Course) {
        imgCourse.loadImage(url: course.thumbnailImage)
        lblCourseName.text = course.name
        lblDuration.text = "\(course.duration) Hours"
        lblAudience.text = "\(course.audience)"
    }
    
    @IBAction func onClickPay(_ sender: UIButton) {
        onBuyTapped?()
    }
    
    @IBAction func onClickWatchDemo(_ sender: UIButton) {
        onWatchDemoTapped?()
    }
}
