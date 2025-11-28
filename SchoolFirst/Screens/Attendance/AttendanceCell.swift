//
//  AttendanceCell.swift
//  SchoolFirst
//
//  Created by Lifeboat on 28/10/25.
//

import UIKit

class AttendanceCell: UITableViewCell {
    
    @IBOutlet weak var lblAbsentDays: UILabel!
    @IBOutlet weak var presentVw: UIView!
    @IBOutlet weak var presentdays: UILabel!
    @IBOutlet weak var attendanceLbl: UILabel!
    @IBOutlet weak var progressVw: UIView!
    @IBOutlet weak var absentVw: UIView!
    @IBOutlet weak var attendanceVw: UIView!
    @IBOutlet weak var requestleaveButton: UIButton!
    @IBOutlet weak var leavehistoryButton: UIButton!
    
    var presentCount: Int = 0
    var absentCount: Int = 0
    var totalDays: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         [presentVw, absentVw].forEach {

            $0?.layer.cornerRadius = 8
        }
        
        attendanceVw.addCardShadow()

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
    
    func setupcell(attendance : Attendance){
        self.lblAbsentDays.text = "\(attendance.absentDays)"
        self.presentdays.text = "\(attendance.presentDays)"
        presentCount = attendance.presentDays
        absentCount = attendance.absentDays
        totalDays = presentCount + absentCount
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
