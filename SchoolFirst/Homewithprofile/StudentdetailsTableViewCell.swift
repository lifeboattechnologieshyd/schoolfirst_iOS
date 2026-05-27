//
//  StudentdetailsTableViewCell.swift
//  SchoolFirst
//

//
//  StudentdetailsTableViewCell.swift
//  SchoolFirst
//

import UIKit

// MARK: - DELEGATE PROTOCOL

protocol StudentdetailsTableViewCellDelegate: AnyObject {
    func didTapEditButton()
}

class StudentdetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var Viewcontainer: UIView!
    
    // MARK: - DELEGATE
    
    weak var delegate: StudentdetailsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCards()
        setupEditButton()
    }
    
    // MARK: - Setup Edit Button
    
    private func setupEditButton() {
        EditButton.addTarget(self,
                             action: #selector(editButtonTapped),
                             for: .touchUpInside)
    }
    
    // MARK: - Edit Button Action
    
    @objc private func editButtonTapped() {
        delegate?.didTapEditButton()
    }

    // MARK: - Setup Cards

    func setupCards() {

        Viewcontainer.subviews.forEach { $0.removeFromSuperview() }

        // MARK: Main Stack

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Row 1

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 12
        row1.distribution = .fillEqually

        // MARK: Row 2

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually

        // MARK: Cards

        row1.addArrangedSubview(
            createCard(
                title: "Date of Birth",
                value: "15 May 2008",
                icon: "dateofbirth"
            )
        )

        row1.addArrangedSubview(
            createCard(
                title: "Gender",
                value: "Male",
                icon: "gender"
            )
        )

        row2.addArrangedSubview(
            createCard(
                title: "Blood Group",
                value: "O+",
                icon: "bloodgroup"
            )
        )

        row2.addArrangedSubview(
            createCard(
                title: "Contact",
                value: "+1 555-0123",
                icon: "call 1"
            )
        )

        mainStack.addArrangedSubview(row1)
        mainStack.addArrangedSubview(row2)

        Viewcontainer.addSubview(mainStack)

        NSLayoutConstraint.activate([

            mainStack.topAnchor.constraint(equalTo: Viewcontainer.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: Viewcontainer.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: Viewcontainer.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: Viewcontainer.bottomAnchor, constant: -10),

            row1.heightAnchor.constraint(equalToConstant: 110),
            row2.heightAnchor.constraint(equalToConstant: 110)
        ])
    }

    // MARK: - Create Card

    func createCard(title: String,
                    value: String,
                    icon: String) -> UIView {

        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor

        // Shadow

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4

        // MARK: Icon

        let iconImage = UIImageView()
        if let customImage = UIImage(named: icon) {
            iconImage.image = customImage
        } else {
            iconImage.image = UIImage(systemName: icon)
        }
        iconImage.tintColor = .systemBlue
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Title

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Value

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = .black
        valueLabel.numberOfLines = 2
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Add Views

        cardView.addSubview(iconImage)
        cardView.addSubview(titleLabel)
        cardView.addSubview(valueLabel)

        NSLayoutConstraint.activate([

            // Icon

            iconImage.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            iconImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            iconImage.widthAnchor.constraint(equalToConstant: 22),
            iconImage.heightAnchor.constraint(equalToConstant: 22),

            // Title

            titleLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            // Value

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
        ])

        return cardView
    }
}
