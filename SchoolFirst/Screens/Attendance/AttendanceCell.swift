//
//  AttendanceCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit

class AttendanceCell: UITableViewCell {
    
    @IBOutlet weak var abhiLbl: UILabel!
    @IBOutlet weak var abhiBgVw: UIView!
    @IBOutlet weak var presentVw: UIView!
    @IBOutlet weak var attendanceLbl: UILabel!
    @IBOutlet weak var progressVw: UIView!
    @IBOutlet weak var absentVw: UIView!
    @IBOutlet weak var shrvVw: UIView!
    @IBOutlet weak var voiletVw: UIView!
    @IBOutlet weak var shrvImg: UIImageView!
    @IBOutlet weak var blueVw: UIView!
    @IBOutlet weak var attendanceVw: UIView!
    @IBOutlet weak var greenImg: UIImageView!
    @IBOutlet weak var requestleaveButton: UIButton!
    @IBOutlet weak var leavehistoryButton: UIButton!
    @IBOutlet weak var shrvLbl: UILabel!
    @IBOutlet weak var abhiImg: UIImageView!
    
    var presentCount: Int = 10
    var absentCount: Int = 16
    var totalDays: Int = 26
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [blueVw, voiletVw, abhiBgVw, shrvVw, presentVw, absentVw].forEach {
            $0?.layer.cornerRadius = 8
        }
        
        attendanceVw.layer.cornerRadius = 14
        attendanceVw.layer.shadowColor = UIColor.black.cgColor
        attendanceVw.layer.shadowOpacity = 0.2
        attendanceVw.layer.shadowOffset = CGSize(width: 0, height: 2)
        attendanceVw.layer.shadowRadius = 4
        attendanceVw.layer.masksToBounds = false
        
        abhiBgVw.layer.cornerRadius = 25
        abhiBgVw.layer.borderWidth = 1
        abhiBgVw.layer.borderColor = UIColor(red: 11/255, green: 86/255, blue: 154/255, alpha: 1).cgColor
        
        shrvVw.layer.cornerRadius = 25
        shrvVw.layer.borderWidth = 1
        shrvVw.layer.borderColor = UIColor(red: 203/255, green: 229/255, blue: 253/255, alpha: 1).cgColor
    }

    @IBAction func requestLeaveButtonTapped(_ sender: UIButton) {

        if let parentVC = self.parentViewController() {
            let sb = UIStoryboard(name: "Attendance", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "SubmitLeaveViewController") as! SubmitLeaveViewController
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func leaveHistoryButtonTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let sb = UIStoryboard(name: "Attendance", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LeaveHistoryViewController") as! LeaveHistoryViewController
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawAttendanceChart()
    }
    
    func drawAttendanceChart() {
        guard totalDays > 0 else { return }

        progressVw.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        progressVw.subviews.forEach { $0.removeFromSuperview() }

        let center = CGPoint(x: progressVw.bounds.midX, y: progressVw.bounds.midY)
        let radius = progressVw.bounds.width / 2 - 8
        let lineWidth: CGFloat = 12

        let bgCircle = CAShapeLayer()
        bgCircle.path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi/2,
            endAngle: 1.5 * .pi,
            clockwise: true
        ).cgPath
        bgCircle.strokeColor = UIColor.systemGray5.cgColor
        bgCircle.fillColor = UIColor.clear.cgColor
        bgCircle.lineWidth = lineWidth
        progressVw.layer.addSublayer(bgCircle)

        let presentFraction = CGFloat(presentCount) / CGFloat(totalDays)
        let absentFraction = CGFloat(absentCount) / CGFloat(totalDays)
        var startAngle = -CGFloat.pi / 2

        if presentCount > 0 {
            let endAngle = startAngle + 2 * .pi * presentFraction
            addSegment(from: startAngle, to: endAngle, color: UIColor(red: 15/255, green: 175/255, blue: 19/255, alpha: 1), center: center, radius: radius, lineWidth: lineWidth)
            startAngle = endAngle
        }

        if absentCount > 0 {
            let endAngle = startAngle + 2 * .pi * absentFraction
            addSegment(from: startAngle, to: endAngle, color: UIColor(red: 255/255, green: 0/255, blue: 25/255, alpha: 1), center: center, radius: radius, lineWidth: lineWidth)
        }

        let presentPercent = Int((CGFloat(presentCount) / CGFloat(totalDays)) * 100)
        let percentLabel = UILabel(frame: progressVw.bounds)
        percentLabel.text = "\(presentPercent)%"
        percentLabel.font = UIFont.boldSystemFont(ofSize: 20)
        percentLabel.textAlignment = .center
        percentLabel.textColor = .black
        progressVw.addSubview(percentLabel)
    }

    private func addSegment(from startAngle: CGFloat, to endAngle: CGFloat, color: UIColor, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {
        let segment = CAShapeLayer()
        segment.path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        ).cgPath
        segment.strokeColor = color.cgColor
        segment.fillColor = UIColor.clear.cgColor
        segment.lineWidth = lineWidth
        segment.lineCap = .round
        progressVw.layer.addSublayer(segment)
    }
}
