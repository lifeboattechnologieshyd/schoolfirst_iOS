//
//  ExameventTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

//
//  ExameventTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 30/05/26.
//

import UIKit

class ExameventTableViewCell2: UITableViewCell {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!

    private let leftRedView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {

        // Main Card
        ContainerView.layer.cornerRadius = 16
        ContainerView.layer.masksToBounds = false

        ContainerView.layer.shadowColor = UIColor.black.cgColor
        ContainerView.layer.shadowOpacity = 0.08
        ContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ContainerView.layer.shadowRadius = 4

        // Image
        ImageView.contentMode = .scaleAspectFit

        // Left Red Strip
        leftRedView.backgroundColor = UIColor(
            red: 147/255.0,
            green: 0/255.0,
            blue: 10/255.0,
            alpha: 1.0
        )
        leftRedView.layer.cornerRadius = 4
        leftRedView.translatesAutoresizingMaskIntoConstraints = false

        ContainerView.addSubview(leftRedView)

        NSLayoutConstraint.activate([
            leftRedView.leadingAnchor.constraint(equalTo: ContainerView.leadingAnchor),
            leftRedView.topAnchor.constraint(equalTo: ContainerView.topAnchor, constant: 12),
            leftRedView.bottomAnchor.constraint(equalTo: ContainerView.bottomAnchor, constant: -12),
            leftRedView.widthAnchor.constraint(equalToConstant: 6)
        ])
    }
}
