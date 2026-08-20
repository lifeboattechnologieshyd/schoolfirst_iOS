//
//  HomeworkwithsubTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

class HomeworkwithsubTableViewCell2: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var MarkCompletebutton: UIButton!
    @IBOutlet weak var Teachername: UILabel!
    @IBOutlet weak var Duedate: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Homeworktitle: UILabel!
    @IBOutlet weak var PrioritbadgeLabel: UILabel!
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var SubjectImage: UIImageView!
    @IBOutlet weak var ImageBackgroundview: UIView!
    @IBOutlet weak var ContainerView: UIView!

    // MARK: - Callback

    var onViewDetailsTapped: (() -> Void)?

    // MARK: - View Details Button

    private lazy var viewDetailsButton: UIButton = {

        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(
            "View Details",
            for: .normal
        )

        button.setTitleColor(
            .systemBlue,
            for: .normal
        )

        button.titleLabel?.font =
            UIFont.systemFont(
                ofSize: 14,
                weight: .semibold
            )

        button.isHidden = true

        return button
    }()

    // MARK: - Date Formatters

    private lazy var apiDateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "en_US_POSIX")

        formatter.calendar =
            Calendar(identifier: .gregorian)

        formatter.timeZone =
            TimeZone(secondsFromGMT: 0)

        formatter.dateFormat =
            "yyyy-MM-dd"

        return formatter
    }()

    private lazy var displayDateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "en_US_POSIX")

        formatter.dateFormat =
            "MMM dd, yyyy"

        return formatter
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupContainerView()
        setupBadgeLabel()
        setupImageBackground()
        setupViewDetailsButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        ContainerView.layer.shadowPath =
            UIBezierPath(
                roundedRect: ContainerView.bounds,
                cornerRadius: 12
            ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        onViewDetailsTapped = nil

        Homeworktitle.text = nil
        Description.text = nil
        Duedate.text = nil
        Teachername.text = nil
        Subject.text = nil
        PrioritbadgeLabel.text = nil
        SubjectImage.image = nil

        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true

        PrioritbadgeLabel.backgroundColor = .clear
        PrioritbadgeLabel.textColor = .label

        Subject.textColor = .label
        SubjectImage.tintColor = nil

        ImageBackgroundview.backgroundColor = .clear
    }

    // MARK: - UI Setup

    private func setupContainerView() {

        ContainerView.layer.cornerRadius = 12

        ContainerView.layer.shadowColor =
            UIColor.lightGray.cgColor

        ContainerView.layer.shadowOpacity = 0.2

        ContainerView.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 2
            )

        ContainerView.layer.shadowRadius = 4
        ContainerView.layer.masksToBounds = false
    }

    private func setupBadgeLabel() {

        PrioritbadgeLabel.layer.cornerRadius = 10
        PrioritbadgeLabel.clipsToBounds = true
    }

    private func setupImageBackground() {

        ImageBackgroundview.layer.cornerRadius = 10
        ImageBackgroundview.clipsToBounds = true
    }

    private func setupViewDetailsButton() {

        ContainerView.addSubview(
            viewDetailsButton
        )

        viewDetailsButton.addTarget(
            self,
            action: #selector(viewDetailsTapped),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([

            viewDetailsButton.centerYAnchor.constraint(
                equalTo: MarkCompletebutton.centerYAnchor
            ),

            viewDetailsButton.trailingAnchor.constraint(
                equalTo: ContainerView.trailingAnchor,
                constant: -20
            ),

            viewDetailsButton.heightAnchor.constraint(
                equalToConstant: 40
            )
        ])
    }

    // MARK: - Action

    @objc
    private func viewDetailsTapped() {
        onViewDetailsTapped?()
    }

    // MARK: - Configure API Data

    func configure(
        with homework: StudentHomework
    ) {

        // Reset reusable state.
        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true

        Homeworktitle.text =
            homework.title

        Description.text =
            homework.description

        Duedate.text =
            formattedDueDate(
                homework.dueDate
            )

        Teachername.text =
            homework.teacher.name

        Subject.text =
            homework.subject.name.capitalized

        configureSubjectImage(
            subjectName: homework.subject.name
        )

        configureSubmissionStatus(
            homework.submission.status,
            dueDate: homework.dueDate
        )
    }

    // MARK: - Submission Status

    private func configureSubmissionStatus(
        _ status: String,
        dueDate: String
    ) {

        let normalizedStatus =
            status
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        switch normalizedStatus {

        case "COMPLETED",
             "SUBMITTED",
             "APPROVED":

            applyStyle(
                color: .systemGreen,
                text: formattedStatus(normalizedStatus)
            )

            MarkCompletebutton.isHidden = true
            viewDetailsButton.isHidden = false

        case "REJECTED":

            applyStyle(
                color: .systemRed,
                text: "Rejected"
            )

            MarkCompletebutton.isHidden = false
            viewDetailsButton.isHidden = true

        case "PENDING":

            if isOverdue(dueDate) {

                applyStyle(
                    color: .systemRed,
                    text: "Overdue"
                )

            } else {

                applyStyle(
                    color: .systemOrange,
                    text: "Pending"
                )
            }

            MarkCompletebutton.isHidden = false
            viewDetailsButton.isHidden = true

        default:

            applyStyle(
                color: .systemOrange,
                text: formattedStatus(normalizedStatus)
            )

            MarkCompletebutton.isHidden = false
            viewDetailsButton.isHidden = true
        }
    }

    // MARK: - Subject Image

    private func configureSubjectImage(
        subjectName: String
    ) {

        let normalizedSubject =
            subjectName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let imageName: String

        switch normalizedSubject {

        case "math",
             "maths",
             "mathematics":

            imageName = "Mathsicon"

        case "science",
             "general science":

            imageName = "ic_science"

        case "history":

            imageName = "ic_history"

        case "english":

            imageName = "ic_english"

        case "social",
             "social studies",
             "social science":

            imageName = "ic_social"

        case "computer",
             "computers",
             "computer science":

            imageName = "ic_computer"

        case "physics":

            imageName = "ic_physics"

        case "chemistry":

            imageName = "ic_chemistry"

        case "biology":

            imageName = "ic_biology"

        case "geography":

            imageName = "ic_geography"

        default:

            SubjectImage.image =
                UIImage(
                    systemName: "book.closed.fill"
                )

            return
        }

        SubjectImage.image =
            UIImage(named: imageName)
            ?? UIImage(
                systemName: "book.closed.fill"
            )
    }

    // MARK: - Style

    private func applyStyle(
        color: UIColor,
        text: String
    ) {

        PrioritbadgeLabel.text = text

        PrioritbadgeLabel.backgroundColor =
            color.withAlphaComponent(0.15)

        PrioritbadgeLabel.textColor = color
        Subject.textColor = color
        SubjectImage.tintColor = color

        ImageBackgroundview.backgroundColor =
            color.withAlphaComponent(0.15)
    }

    // MARK: - Date Helpers

    private func formattedDueDate(
        _ dateString: String
    ) -> String {

        guard let date =
                apiDateFormatter.date(
                    from: dateString
                ) else {

            return "Due: \(dateString)"
        }

        return "Due: \(displayDateFormatter.string(from: date))"
    }

    private func isOverdue(
        _ dateString: String
    ) -> Bool {

        guard let dueDate =
                apiDateFormatter.date(
                    from: dateString
                ) else {

            return false
        }

        let calendar = Calendar.current

        let today =
            calendar.startOfDay(
                for: Date()
            )

        let normalizedDueDate =
            calendar.startOfDay(
                for: dueDate
            )

        return normalizedDueDate < today
    }

    private func formattedStatus(
        _ status: String
    ) -> String {

        return status
            .lowercased()
            .replacingOccurrences(
                of: "_",
                with: " "
            )
            .capitalized
    }
}
