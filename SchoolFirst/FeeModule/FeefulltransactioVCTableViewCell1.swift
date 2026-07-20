//
//  FeefulltransactioVCTableViewCell1.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 25/06/26.
//

import UIKit

class FeefulltransactioVCTableViewCell1: UITableViewCell {

    @IBOutlet weak var containerview: UIView!

    // MARK: - UI Elements

    private let totalPaidTitle = UILabel()
    private let totalPaidAmount = UILabel()

    private let totalDueTitle = UILabel()
    private let totalDueAmount = UILabel()

    private let separatorView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupContainer()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerview.layer.shadowPath =
        UIBezierPath(
            roundedRect: containerview.bounds,
            cornerRadius: 12
        ).cgPath
    }

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {
        super.setSelected(
            selected,
            animated: animated
        )
    }

    // MARK: - Container

    private func setupContainer() {

        containerview.backgroundColor =
        UIColor(
            red: 0/255,
            green: 63/255,
            blue: 117/255,
            alpha: 0.05
        )

        containerview.layer.cornerRadius = 12

        containerview.layer.borderWidth = 0.2

        containerview.layer.borderColor =
        UIColor.lightGray.withAlphaComponent(
            0.3
        ).cgColor

        containerview.layer.shadowColor =
        UIColor.lightGray.cgColor

        containerview.layer.shadowOpacity = 0.2

        containerview.layer.shadowOffset =
        CGSize(
            width: 0,
            height: 3
        )

        containerview.layer.shadowRadius = 4
    }

    // MARK: - UI Setup

    private func setupUI() {

        let stack =
        UIStackView()

        stack.axis = .horizontal

        stack.distribution = .fillEqually

        stack.translatesAutoresizingMaskIntoConstraints =
        false

        containerview.addSubview(stack)

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(
                equalTo: containerview.topAnchor,
                constant: 20
            ),

            stack.bottomAnchor.constraint(
                equalTo: containerview.bottomAnchor,
                constant: -20
            ),

            stack.leadingAnchor.constraint(
                equalTo: containerview.leadingAnchor
            ),

            stack.trailingAnchor.constraint(
                equalTo: containerview.trailingAnchor
            )
        ])

        // Left View
        let leftView =
        createSummaryView(
            title: totalPaidTitle,
            amount: totalPaidAmount,
            titleText: "Total Paid",
            amountText: "₹ 2,25,600"
        )

        // Right View
        let rightView =
        createSummaryView(
            title: totalDueTitle,
            amount: totalDueAmount,
            titleText: "Total Due",
            amountText: "• 22,500"
        )

        separatorView.backgroundColor =
        UIColor.lightGray

        separatorView.translatesAutoresizingMaskIntoConstraints =
        false

        let centerView = UIView()

        centerView.addSubview(
            separatorView
        )

        NSLayoutConstraint.activate([

            separatorView.centerXAnchor.constraint(
                equalTo: centerView.centerXAnchor
            ),

            separatorView.topAnchor.constraint(
                equalTo: centerView.topAnchor
            ),

            separatorView.bottomAnchor.constraint(
                equalTo: centerView.bottomAnchor
            ),

            separatorView.widthAnchor.constraint(
                equalToConstant: 1
            )
        ])

        stack.addArrangedSubview(
            leftView
        )

        stack.addArrangedSubview(
            centerView
        )

        stack.addArrangedSubview(
            rightView
        )
    }

    // MARK: - Create Summary Block

    private func createSummaryView(
        title: UILabel,
        amount: UILabel,
        titleText: String,
        amountText: String
    ) -> UIView {

        let view = UIView()

        title.text = titleText

        title.textAlignment =
        .center

        title.font =
        .systemFont(
            ofSize: 18,
            weight: .medium
        )

        title.textColor =
        .darkGray

        amount.text = amountText

        amount.textAlignment =
        .center

        amount.font =
        .systemFont(
            ofSize: 20,
            weight: .bold
        )

        amount.textColor =
        UIColor(
            red: 0/255,
            green: 63/255,
            blue: 117/255,
            alpha: 1
        )

        let stack =
        UIStackView(
            arrangedSubviews: [
                title,
                amount
            ]
        )

        stack.axis =
        .vertical

        stack.spacing =
        12

        stack.translatesAutoresizingMaskIntoConstraints =
        false

        view.addSubview(
            stack
        )

        NSLayoutConstraint.activate([

            stack.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            stack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])

        return view
    }

    // MARK: - Dynamic API Data

    func configure(
        totalPaid: String,
        totalDue: String
    ) {

        totalPaidAmount.text =
        "₹ \(totalPaid)"

        totalDueAmount.text =
        "• \(totalDue)"
    }
}
