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
        case .mathematics: return "function"
        case .science: return "atom"
        case .history: return "book.closed.fill"
        case .english: return "textformat"
        case .socialStudies: return "globe"
        case .computerScience: return "desktopcomputer"
        case .physics: return "bolt.fill"
        case .chemistry: return "flame.fill"
        case .biology: return "leaf.fill"
        case .geography: return "map.fill"
        }
    }

    var assetImageName: String {
        switch self {
        case .mathematics: return "Mathsicon"
        case .science: return "ic_science"
        case .history: return "ic_history"
        case .english: return "ic_english"
        case .socialStudies: return "ic_social"
        case .computerScience: return "ic_computer"
        case .physics: return "ic_physics"
        case .chemistry: return "ic_chemistry"
        case .biology: return "ic_biology"
        case .geography: return "ic_geography"
        }
    }
}

// MARK: - Homework Model
struct HomeworkModel {
    let priorityType: HomeworkPriorityType
    let subject: HomeworkSubjectType
    let title: String
    let description: String
    let dueDate: String
    let teacherName: String
}

class HomeworkwithsubTableViewCell2: UITableViewCell {

    // MARK: - Outlets (Existing — Reused)
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
    
    // MARK: - Programmatic "View Details" Button (Only for Done state)
    private lazy var viewDetailsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("View Details", for: .normal)
        btn.setTitleColor(UIColor(hex: "#1B3A5C") ?? .systemBlue, for: .normal)
        btn.titleLabel?.font = .lexend(.semiBold, size: 14)
        btn.backgroundColor = .clear
        btn.isHidden = true
        return btn
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupContainerView()
        setupBadgeLabel()
        setupImageBackground()
        setupViewDetailsButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        ContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: ContainerView.bounds,
            cornerRadius: 12
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        SubjectImage.image = nil
        Subject.text = nil
        Homeworktitle.text = nil
        Description.text = nil
        Duedate.text = nil
        Teachername.text = nil
        PrioritbadgeLabel.text = nil
        
        // Reset buttons visibility
        DownloadButton.isHidden = false
        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true
    }

    // MARK: - Setup Methods
    private func setupContainerView() {
        ContainerView.backgroundColor = .white
        ContainerView.layer.cornerRadius = 12

        ContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        ContainerView.layer.shadowOpacity = 0.25
        ContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ContainerView.layer.shadowRadius = 4
        ContainerView.layer.masksToBounds = false
    }

    private func setupBadgeLabel() {
        PrioritbadgeLabel.layer.cornerRadius = 10
        PrioritbadgeLabel.clipsToBounds = true
        PrioritbadgeLabel.textAlignment = .center
    }

    private func setupImageBackground() {
        ImageBackgroundview.layer.cornerRadius = 10
        ImageBackgroundview.clipsToBounds = true
        SubjectImage.contentMode = .scaleAspectFit
    }
    
    // MARK: - Setup "View Details" Button
    private func setupViewDetailsButton() {
        ContainerView.addSubview(viewDetailsButton)
        
        NSLayoutConstraint.activate([
            // Align it where Mark Complete button is
            viewDetailsButton.centerYAnchor.constraint(equalTo: MarkCompletebutton.centerYAnchor),
            viewDetailsButton.trailingAnchor.constraint(equalTo: ContainerView.trailingAnchor, constant: -20),
            viewDetailsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Configure Cell
    func configure(with model: HomeworkModel) {

        Homeworktitle.text = model.title
        Description.text = model.description
        Duedate.text = model.dueDate
        Teachername.text = model.teacherName
        Subject.text = model.subject.rawValue

        loadSubjectImage(for: model.subject)

        switch model.priorityType {

        case .highPriority:
            applyHighPriorityStyle()

        case .medPriority:
            applyMedPriorityStyle()

        case .done:
            applyDoneStyle()
        }
    }

    // MARK: - Load Subject Image
    private func loadSubjectImage(for subject: HomeworkSubjectType) {

        if let assetImage = UIImage(named: subject.assetImageName) {
            SubjectImage.image = assetImage.withRenderingMode(.alwaysTemplate)
        } else {
            SubjectImage.image = UIImage(systemName: subject.iconName)
        }
    }

    // MARK: - High Priority Style (Red)
    private func applyHighPriorityStyle() {

        let color = UIColor.systemRed

        // Badge
        PrioritbadgeLabel.text = "High Priority"
        PrioritbadgeLabel.backgroundColor = color.withAlphaComponent(0.15)
        PrioritbadgeLabel.textColor = color

        // Subject
        ImageBackgroundview.backgroundColor = color.withAlphaComponent(0.15)
        SubjectImage.tintColor = color
        Subject.textColor = color

        // Buttons → Show Mark Complete + Download | Hide View Details
        DownloadButton.isHidden = false
        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true
    }

    // MARK: - Medium Priority Style (Orange)
    private func applyMedPriorityStyle() {

        let color = UIColor.systemOrange

        // Badge
        PrioritbadgeLabel.text = "Med Priority"
        PrioritbadgeLabel.backgroundColor = color.withAlphaComponent(0.15)
        PrioritbadgeLabel.textColor = color

        // Subject
        ImageBackgroundview.backgroundColor = color.withAlphaComponent(0.15)
        SubjectImage.tintColor = color
        Subject.textColor = color

        // Buttons → Show Mark Complete + Download | Hide View Details
        DownloadButton.isHidden = false
        MarkCompletebutton.isHidden = false
        viewDetailsButton.isHidden = true
    }

    // MARK: - Done Style (Green)
    private func applyDoneStyle() {

        let color = UIColor.systemGreen

        // Badge
        PrioritbadgeLabel.text = "Done"
        PrioritbadgeLabel.backgroundColor = color.withAlphaComponent(0.15)
        PrioritbadgeLabel.textColor = color

        // Subject
        ImageBackgroundview.backgroundColor = color.withAlphaComponent(0.15)
        SubjectImage.tintColor = color
        Subject.textColor = color

        // Buttons → Hide Mark Complete + Download | Show View Details
        DownloadButton.isHidden = true
        MarkCompletebutton.isHidden = true
        viewDetailsButton.isHidden = false
        
        // Bring view details button to front so it's tappable
        ContainerView.bringSubviewToFront(viewDetailsButton)
    }
}
