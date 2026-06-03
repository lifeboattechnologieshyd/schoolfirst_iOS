//
//  P&TmeetTableViewCell1.swift
//  SchoolFirst
//

import UIKit

class P_TmeetTableViewCell1: UITableViewCell {

    @IBOutlet weak var Containerview: UIView!
    @IBOutlet weak var containerview2: UIView!
    @IBOutlet weak var containerview3: UIView!
    @IBOutlet weak var containerview4: UIView!
    @IBOutlet weak var ReminderButton: UIButton!

    private let dateIconView = UIView()
    private let dateIconImageView = UIImageView()
    private let dateTitleLabel = UILabel()
    private let dateValueLabel = UILabel()

    private let timeIconView = UIView()
    private let timeIconImageView = UIImageView()
    private let timeTitleLabel = UILabel()
    private let timeValueLabel = UILabel()

    private let locationIconView = UIView()
    private let locationIconImageView = UIImageView()
    private let locationTitleLabel = UILabel()
    private let locationValueLabel = UILabel()

    private let dateStackView = UIStackView()
    private let timeStackView = UIStackView()
    private let locationStackView = UIStackView()
    private let mainStackView = UIStackView()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        ReminderButton.layer.cornerRadius = 30
            ReminderButton.clipsToBounds = true
        setupContainerView()
        setupSubviews()
        setupConstraints()
        configureDefaultData()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Icon Views
        [dateIconView, timeIconView, locationIconView].forEach {
            $0.layer.cornerRadius = 12
        }

        // Reminder Button
        ReminderButton.layer.cornerRadius = ReminderButton.frame.height / 2
        ReminderButton.clipsToBounds = true

        // Dashed Border
        addDashedBorder()
    }

    // MARK: - Setup UI

    private func setupContainerView() {

        // Main Container
        applyCardStyle(to: Containerview)

        // Container 2
        applyCardStyle(to: containerview2)

        // Container 3
        applyCardStyle(to: containerview3)

        // Notes Container (containerview4)
        containerview4.backgroundColor = UIColor(
            red: 245/255,
            green: 243/255,
            blue: 255/255,
            alpha: 1.0
        )

        containerview4.layer.cornerRadius = 16
        containerview4.clipsToBounds = true
    }

    private func applyCardStyle(to view: UIView) {

        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(
            white: 0.92,
            alpha: 1.0
        ).cgColor

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.masksToBounds = false
    }

    private func addDashedBorder() {

        containerview4.layer.sublayers?
            .filter { $0.name == "DashedBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBorderLayer"

        shapeLayer.path = UIBezierPath(
            roundedRect: containerview4.bounds,
            cornerRadius: 16
        ).cgPath

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.systemPurple.withAlphaComponent(0.4).cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineDashPattern = [6, 4]

        containerview4.layer.addSublayer(shapeLayer)
    }

    // MARK: - Existing Code

    private func setupSubviews() {

        let purpleColor = UIColor(
            red: 124/255,
            green: 92/255,
            blue: 252/255,
            alpha: 1.0
        )

        let lightPurpleBg = UIColor(
            red: 237/255,
            green: 230/255,
            blue: 255/255,
            alpha: 1.0
        )

        // Date Row
        configureIconView(
            dateIconView,
            imageView: dateIconImageView,
            systemImage: "calendar",
            bgColor: lightPurpleBg,
            tintColor: purpleColor
        )

        configureTitleLabel(dateTitleLabel, text: "Date")
        configureValueLabel(dateValueLabel, text: "May 22, 2024")

        let dateTextStack = UIStackView(
            arrangedSubviews: [dateTitleLabel, dateValueLabel]
        )

        dateTextStack.axis = .vertical
        dateTextStack.spacing = 2

        dateStackView.axis = .horizontal
        dateStackView.spacing = 14
        dateStackView.alignment = .center

        dateStackView.addArrangedSubview(dateIconView)
        dateStackView.addArrangedSubview(dateTextStack)

        // Time Row
        configureIconView(
            timeIconView,
            imageView: timeIconImageView,
            systemImage: "clock",
            bgColor: lightPurpleBg,
            tintColor: purpleColor
        )

        configureTitleLabel(timeTitleLabel, text: "Time")
        configureValueLabel(timeValueLabel, text: "04:00 PM")

        let timeTextStack = UIStackView(
            arrangedSubviews: [timeTitleLabel, timeValueLabel]
        )

        timeTextStack.axis = .vertical
        timeTextStack.spacing = 2

        timeStackView.axis = .horizontal
        timeStackView.spacing = 14
        timeStackView.alignment = .center

        timeStackView.addArrangedSubview(timeIconView)
        timeStackView.addArrangedSubview(timeTextStack)

        // Location Row
        configureIconView(
            locationIconView,
            imageView: locationIconImageView,
            systemImage: "mappin.and.ellipse",
            bgColor: lightPurpleBg,
            tintColor: purpleColor
        )

        configureTitleLabel(locationTitleLabel, text: "Location")
        configureValueLabel(locationValueLabel, text: "Room 101")

        let locationTextStack = UIStackView(
            arrangedSubviews: [locationTitleLabel, locationValueLabel]
        )

        locationTextStack.axis = .vertical
        locationTextStack.spacing = 2

        locationStackView.axis = .horizontal
        locationStackView.spacing = 14
        locationStackView.alignment = .center

        locationStackView.addArrangedSubview(locationIconView)
        locationStackView.addArrangedSubview(locationTextStack)

        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        mainStackView.addArrangedSubview(dateStackView)
        mainStackView.addArrangedSubview(timeStackView)
        mainStackView.addArrangedSubview(locationStackView)

        Containerview.addSubview(mainStackView)
    }

    private func configureIconView(
        _ view: UIView,
        imageView: UIImageView,
        systemImage: String,
        bgColor: UIColor,
        tintColor: UIColor
    ) {

        view.backgroundColor = bgColor
        view.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = UIImage(systemName: systemImage)
        imageView.tintColor = tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 44),
            view.heightAnchor.constraint(equalToConstant: 44),

            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    private func configureTitleLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
    }

    private func configureValueLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: Containerview.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: Containerview.leadingAnchor, constant: 18),
            mainStackView.trailingAnchor.constraint(equalTo: Containerview.trailingAnchor, constant: -18),
            mainStackView.bottomAnchor.constraint(equalTo: Containerview.bottomAnchor, constant: -20)
        ])
    }

    private func configureDefaultData() {
        dateValueLabel.text = "May 22, 2024"
        timeValueLabel.text = "04:00 PM"
        locationValueLabel.text = "Room 101"
    }

    func configure(date: String, time: String, location: String) {
        dateValueLabel.text = date
        timeValueLabel.text = time
        locationValueLabel.text = location
    }
}
