//
//  ExameventTableViewCell3.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 01/06/26.


import UIKit

class ExameventTableViewCell3: UITableViewCell {

    @IBOutlet weak var ReminderButton: UIButton!
    @IBOutlet weak var ContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

      
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupDashedBorder()

        ReminderButton.layer.cornerRadius = ReminderButton.frame.height / 2
    }

   

    private func setupDashedBorder() {

        // Remove old dashed border if exists
        ContainerView.layer.sublayers?.removeAll(where: {
            $0.name == "DashedBorder"
        })

        let dashedLayer = CAShapeLayer()
        dashedLayer.name = "DashedBorder"

        dashedLayer.strokeColor = UIColor.lightGray.cgColor
        dashedLayer.fillColor = UIColor.clear.cgColor

        // Dash pattern
        dashedLayer.lineDashPattern = [6, 4]

        dashedLayer.lineWidth = 3

        dashedLayer.path = UIBezierPath(
            roundedRect: ContainerView.bounds,
            cornerRadius: 16
        ).cgPath

        ContainerView.layer.addSublayer(dashedLayer)
    }
}
