//
//  HomeworkwithsubTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 09/06/26.
//

import UIKit

// MARK: - Homework Priority Type

enum HomeworkPriorityType {
    case highPriority
    case medPriority
    case done
}

// MARK: - Homework Subject Type

enum HomeworkSubjectType: String {

    case mathematics = "Mathematics"
    case science = "Science"
    case history = "History"
    case english = "English"
    case socialStudies = "Social Studies"
    case computerScience = "Computer Science"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case biology = "Biology"
    case geography = "Geography"

    var iconName: String {

        switch self {

        case .mathematics:
            return "function"

        case .science:
            return "atom"

        case .history:
            return "book.closed.fill"

        case .english:
            return "textformat"

        case .socialStudies:
            return "globe"

        case .computerScience:
            return "desktopcomputer"

        case .physics:
            return "bolt.fill"

        case .chemistry:
            return "flame.fill"

        case .biology:
            return "leaf.fill"

        case .geography:
            return "map.fill"
        }
    }

    var assetImageName: String {

        switch self {

        case .mathematics:
            return "Mathsicon"

        case .science:
            return "ic_science"

        case .history:
            return "ic_history"

        case .english:
            return "ic_english"

        case .socialStudies:
            return "ic_social"

        case .computerScience:
            return "ic_computer"

        case .physics:
            return "ic_physics"

        case .chemistry:
            return "ic_chemistry"

        case .biology:
            return "ic_biology"

        case .geography:
            return "ic_geography"
        }
    }
}

// MARK: - Model

struct HomeworkModel {

    let priorityType: HomeworkPriorityType
    let subject: HomeworkSubjectType
    let title: String
    let description: String
    let dueDate: String
    let teacherName: String
}

class HomeworkwithsubTableViewCell2: UITableViewCell {

    @IBOutlet weak var DownloadButton: UIButton!
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

    private lazy var viewDetailsButton: UIButton = {

        let btn = UIButton(type: .system)

        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.setTitle(
            "View Details",
            for: .normal
        )

        btn.setTitleColor(
            UIColor.systemBlue,
            for: .normal
        )

        btn.titleLabel?.font =
        UIFont.systemFont(
            ofSize: 14,
            weight: .semibold
        )

        btn.isHidden = true

        return btn

    }()

    override func awakeFromNib() {

        super.awakeFromNib()

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

        DownloadButton.isHidden = false
        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true

        // MARK: Clear callback on reuse to avoid retain issues
        onViewDetailsTapped = nil
    }

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
    }

    private func setupBadgeLabel() {

        PrioritbadgeLabel.layer.cornerRadius = 10

        PrioritbadgeLabel.clipsToBounds = true
    }

    private func setupImageBackground() {

        ImageBackgroundview.layer.cornerRadius = 10
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

    @objc
    private func viewDetailsTapped() {

        onViewDetailsTapped?()
    }

    func configure(
        with model: HomeworkModel
    ) {

        Homeworktitle.text =
        model.title

        Description.text =
        model.description

        Duedate.text =
        model.dueDate

        Teachername.text =
        model.teacherName

        Subject.text =
        model.subject.rawValue

        loadSubjectImage(
            for: model.subject
        )

        switch model.priorityType {

        case .highPriority:

            applyStyle(
                color: .systemRed,
                text: "High Priority"
            )

        case .medPriority:

            applyStyle(
                color: .systemOrange,
                text: "Med Priority"
            )

        case .done:

            applyStyle(
                color: .systemGreen,
                text: "Done"
            )

            DownloadButton.isHidden = true
            MarkCompletebutton.isHidden = true
            viewDetailsButton.isHidden = false
        }
    }

    private func loadSubjectImage(
        for subject: HomeworkSubjectType
    ) {

        SubjectImage.image =
        UIImage(
            named: subject.assetImageName
        )
    }

    private func applyStyle(
        color: UIColor,
        text: String
    ) {

        PrioritbadgeLabel.text =
        text

        PrioritbadgeLabel.backgroundColor =
        color.withAlphaComponent(0.15)

        PrioritbadgeLabel.textColor =
        color

        Subject.textColor =
        color

        SubjectImage.tintColor =
        color

        ImageBackgroundview.backgroundColor =
        color.withAlphaComponent(0.15)
    }
}
