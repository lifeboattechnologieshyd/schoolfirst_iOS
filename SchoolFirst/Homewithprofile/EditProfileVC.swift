//
//  EditProfileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 25/05/26.
//
//
//  EditProfileVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 25/05/26.
//

import UIKit

// MARK: - PaddingLabel


class EditProfileVC: UIViewController {
    
    // MARK: - Properties
    private let primaryColor = UIColor(red: 0.05, green: 0.27, blue: 0.55, alpha: 1)
    private let backgroundGray = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    
    // MARK: - Header
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SAVE", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Scroll
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = backgroundGray
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = backgroundGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Form Fields
    private var gradeField: UITextField!
    private var rollNumberField: UITextField!
    private var studentIDField: UITextField!
    private var dobField: UITextField!
    private var genderField: UITextField!
    private var bloodGroupField: UITextField!
    private var contactField: UITextField!
    private var addressView: UITextView!
    private var fatherNameField: UITextField!
    private var fatherOccupationField: UITextField!
    private var motherNameField: UITextField!
    private var motherOccupationField: UITextField!
    
    // Card references (to chain layout)
    private var profileCard: UIView!
    private var academicCard: UIView!
    private var personalCard: UIView!
    private var fatherCard: UIView!
    private var motherCard: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundGray
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(headerTitleLabel)
        headerView.addSubview(saveButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            headerTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 28),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupProfileCard()
        setupAcademicCard()
        setupPersonalCard()
        setupParentCards()
    }
    
    // MARK: - Profile Card
    private func setupProfileCard() {
        profileCard = makeCard()
        contentView.addSubview(profileCard)
        
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(imageContainer)
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 45
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(profileImageView)
        
        let cameraButton = UIButton(type: .system)
        let camConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        cameraButton.setImage(UIImage(systemName: "camera.fill", withConfiguration: camConfig), for: .normal)
        cameraButton.tintColor = .white
        cameraButton.backgroundColor = primaryColor
        cameraButton.layer.cornerRadius = 13
        cameraButton.layer.borderWidth = 2
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        imageContainer.addSubview(cameraButton)
        
        let fullNameLabel = UILabel()
        fullNameLabel.text = "FULL NAME"
        fullNameLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        fullNameLabel.textColor = .gray
        fullNameLabel.textAlignment = .center
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(fullNameLabel)
        
        let nameField = createTextField(text: "Alex Johnson")
        nameField.font = .systemFont(ofSize: 15, weight: .semibold)
        nameField.textAlignment = .center
        profileCard.addSubview(nameField)
        
        let activeBadge = PaddingLabel()
        activeBadge.text = "ACTIVE"
        activeBadge.font = .systemFont(ofSize: 10, weight: .bold)
        activeBadge.textColor = UIColor(red: 0.75, green: 0.55, blue: 0, alpha: 1)
        activeBadge.backgroundColor = UIColor(red: 1.0, green: 0.92, blue: 0.6, alpha: 1)
        activeBadge.layer.cornerRadius = 10
        activeBadge.layer.masksToBounds = true
        activeBadge.translatesAutoresizingMaskIntoConstraints = false
        profileCard.addSubview(activeBadge)
        
        NSLayoutConstraint.activate([
            profileCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            imageContainer.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 20),
            imageContainer.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 90),
            imageContainer.heightAnchor.constraint(equalToConstant: 90),
            
            profileImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            
            cameraButton.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 2),
            cameraButton.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: 2),
            cameraButton.widthAnchor.constraint(equalToConstant: 26),
            cameraButton.heightAnchor.constraint(equalToConstant: 26),
            
            fullNameLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 14),
            fullNameLabel.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 6),
            nameField.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 60),
            nameField.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -60),
            nameField.heightAnchor.constraint(equalToConstant: 38),
            
            activeBadge.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
            activeBadge.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            activeBadge.heightAnchor.constraint(equalToConstant: 22),
            activeBadge.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Academic Card
    private func setupAcademicCard() {
        let sectionLabel = createSectionTitle("ACADEMIC SETTINGS")
        contentView.addSubview(sectionLabel)
        
        academicCard = makeCard()
        contentView.addSubview(academicCard)
        
        gradeField = createTextField(text: "10th-A")
        rollNumberField = createTextField(text: "24")
        studentIDField = createTextField(text: "ID #2024-5012")
        
        let gradeLabel = createFieldLabel("Grade")
        let rollLabel = createFieldLabel("Roll Number")
        let studentIDLabel = createFieldLabel("Student ID")
        
        let gradeWithDropdown = addDropdownArrow(to: gradeField)
        
        academicCard.addSubview(gradeLabel)
        academicCard.addSubview(gradeWithDropdown)
        academicCard.addSubview(rollLabel)
        academicCard.addSubview(rollNumberField)
        academicCard.addSubview(studentIDLabel)
        academicCard.addSubview(studentIDField)
        
        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            academicCard.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            academicCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            academicCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            gradeLabel.topAnchor.constraint(equalTo: academicCard.topAnchor, constant: 16),
            gradeLabel.leadingAnchor.constraint(equalTo: academicCard.leadingAnchor, constant: 16),
            
            gradeWithDropdown.topAnchor.constraint(equalTo: gradeLabel.bottomAnchor, constant: 6),
            gradeWithDropdown.leadingAnchor.constraint(equalTo: academicCard.leadingAnchor, constant: 16),
            gradeWithDropdown.trailingAnchor.constraint(equalTo: academicCard.centerXAnchor, constant: -8),
            gradeWithDropdown.heightAnchor.constraint(equalToConstant: 42),
            
            rollLabel.topAnchor.constraint(equalTo: academicCard.topAnchor, constant: 16),
            rollLabel.leadingAnchor.constraint(equalTo: academicCard.centerXAnchor, constant: 8),
            
            rollNumberField.topAnchor.constraint(equalTo: rollLabel.bottomAnchor, constant: 6),
            rollNumberField.leadingAnchor.constraint(equalTo: academicCard.centerXAnchor, constant: 8),
            rollNumberField.trailingAnchor.constraint(equalTo: academicCard.trailingAnchor, constant: -16),
            rollNumberField.heightAnchor.constraint(equalToConstant: 42),
            
            studentIDLabel.topAnchor.constraint(equalTo: gradeWithDropdown.bottomAnchor, constant: 14),
            studentIDLabel.leadingAnchor.constraint(equalTo: academicCard.leadingAnchor, constant: 16),
            
            studentIDField.topAnchor.constraint(equalTo: studentIDLabel.bottomAnchor, constant: 6),
            studentIDField.leadingAnchor.constraint(equalTo: academicCard.leadingAnchor, constant: 16),
            studentIDField.trailingAnchor.constraint(equalTo: academicCard.trailingAnchor, constant: -16),
            studentIDField.heightAnchor.constraint(equalToConstant: 42),
            studentIDField.bottomAnchor.constraint(equalTo: academicCard.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Personal Card
    private func setupPersonalCard() {
        let sectionLabel = createSectionTitle("PERSONAL DETAILS")
        contentView.addSubview(sectionLabel)
        
        personalCard = makeCard()
        contentView.addSubview(personalCard)
        
        dobField = createTextField(text: "05/15/2008")
        genderField = createTextField(text: "Male")
        bloodGroupField = createTextField(text: "O+")
        contactField = createTextField(text: "+91 555-0123")
        
        let dobWithIcon = addRightIcon(to: dobField, systemName: "calendar")
        let genderWithDropdown = addDropdownArrow(to: genderField)
        let bloodWithDropdown = addDropdownArrow(to: bloodGroupField)
        
        let dobLabel = createFieldLabel("Date of Birth")
        let genderLabel = createFieldLabel("Gender")
        let bloodLabel = createFieldLabel("Blood Group")
        let contactLabel = createFieldLabel("Contact Number")
        let addressLabel = createFieldLabel("Residential Address")
        
        addressView = UITextView()
        addressView.text = "123 Maple St, Springfield, IL 62704"
        addressView.font = .systemFont(ofSize: 14)
        addressView.textColor = .black
        addressView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1)
        addressView.layer.borderWidth = 1
        addressView.layer.borderColor = UIColor.systemGray5.cgColor
        addressView.layer.cornerRadius = 8
        addressView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        addressView.translatesAutoresizingMaskIntoConstraints = false
        
        personalCard.addSubview(dobLabel)
        personalCard.addSubview(dobWithIcon)
        personalCard.addSubview(genderLabel)
        personalCard.addSubview(genderWithDropdown)
        personalCard.addSubview(bloodLabel)
        personalCard.addSubview(bloodWithDropdown)
        personalCard.addSubview(contactLabel)
        personalCard.addSubview(contactField)
        personalCard.addSubview(addressLabel)
        personalCard.addSubview(addressView)
        
        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: academicCard.bottomAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            personalCard.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            personalCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            personalCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dobLabel.topAnchor.constraint(equalTo: personalCard.topAnchor, constant: 16),
            dobLabel.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            
            dobWithIcon.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: 6),
            dobWithIcon.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            dobWithIcon.trailingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: -8),
            dobWithIcon.heightAnchor.constraint(equalToConstant: 42),
            
            genderLabel.topAnchor.constraint(equalTo: personalCard.topAnchor, constant: 16),
            genderLabel.leadingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: 8),
            
            genderWithDropdown.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 6),
            genderWithDropdown.leadingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: 8),
            genderWithDropdown.trailingAnchor.constraint(equalTo: personalCard.trailingAnchor, constant: -16),
            genderWithDropdown.heightAnchor.constraint(equalToConstant: 42),
            
            bloodLabel.topAnchor.constraint(equalTo: dobWithIcon.bottomAnchor, constant: 14),
            bloodLabel.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            
            bloodWithDropdown.topAnchor.constraint(equalTo: bloodLabel.bottomAnchor, constant: 6),
            bloodWithDropdown.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            bloodWithDropdown.trailingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: -8),
            bloodWithDropdown.heightAnchor.constraint(equalToConstant: 42),
            
            contactLabel.topAnchor.constraint(equalTo: dobWithIcon.bottomAnchor, constant: 14),
            contactLabel.leadingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: 8),
            
            contactField.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 6),
            contactField.leadingAnchor.constraint(equalTo: personalCard.centerXAnchor, constant: 8),
            contactField.trailingAnchor.constraint(equalTo: personalCard.trailingAnchor, constant: -16),
            contactField.heightAnchor.constraint(equalToConstant: 42),
            
            addressLabel.topAnchor.constraint(equalTo: bloodWithDropdown.bottomAnchor, constant: 14),
            addressLabel.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            
            addressView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 6),
            addressView.leadingAnchor.constraint(equalTo: personalCard.leadingAnchor, constant: 16),
            addressView.trailingAnchor.constraint(equalTo: personalCard.trailingAnchor, constant: -16),
            addressView.heightAnchor.constraint(equalToConstant: 70),
            addressView.bottomAnchor.constraint(equalTo: personalCard.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Parent Cards
    private func setupParentCards() {
        let sectionLabel = createSectionTitle("PARENT INFORMATION")
        contentView.addSubview(sectionLabel)
        
        let fatherResult = createParentCard(
            title: "Father's Details",
            namePlaceholder: "Robert Johnson",
            occupationPlaceholder: "Architect"
        )
        fatherCard = fatherResult.card
        fatherNameField = fatherResult.nameField
        fatherOccupationField = fatherResult.occupationField
        contentView.addSubview(fatherCard)
        
        let motherResult = createParentCard(
            title: "Mother's Details",
            namePlaceholder: "Sarah Johnson",
            occupationPlaceholder: "Software Engineer"
        )
        motherCard = motherResult.card
        motherNameField = motherResult.nameField
        motherOccupationField = motherResult.occupationField
        contentView.addSubview(motherCard)
        
        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: personalCard.bottomAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            fatherCard.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            fatherCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fatherCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            motherCard.topAnchor.constraint(equalTo: fatherCard.bottomAnchor, constant: 16),
            motherCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            motherCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            motherCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Helpers
    
    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTextField(text: String) -> UITextField {
        let tf = UITextField()
        tf.text = text
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .black
        tf.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.layer.cornerRadius = 8
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    private func addDropdownArrow(to tf: UITextField) -> UITextField {
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.tintColor = .darkGray
        arrow.contentMode = .scaleAspectFit
        arrow.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        container.addSubview(arrow)
        tf.rightView = container
        tf.rightViewMode = .always
        return tf
    }
    
    private func addRightIcon(to tf: UITextField, systemName: String) -> UITextField {
        let icon = UIImageView(image: UIImage(systemName: systemName))
        icon.tintColor = .darkGray
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 16))
        container.addSubview(icon)
        tf.rightView = container
        tf.rightViewMode = .always
        return tf
    }
    
    private func createParentCard(
        title: String,
        namePlaceholder: String,
        occupationPlaceholder: String
    ) -> (card: UIView, nameField: UITextField, occupationField: UITextField) {
        
        let card = makeCard()
        
        let iconImageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iconImageView.tintColor = primaryColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = createFieldLabel("Name")
        let nameField = createTextField(text: namePlaceholder)
        let occupationLabel = createFieldLabel("Occupation")
        let occupationField = createTextField(text: occupationPlaceholder)
        
        card.addSubview(iconImageView)
        card.addSubview(titleLabel)
        card.addSubview(nameLabel)
        card.addSubview(nameField)
        card.addSubview(occupationLabel)
        card.addSubview(occupationField)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            
            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            nameField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            nameField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            nameField.heightAnchor.constraint(equalToConstant: 42),
            
            occupationLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            occupationLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            
            occupationField.topAnchor.constraint(equalTo: occupationLabel.bottomAnchor, constant: 6),
            occupationField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            occupationField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            occupationField.heightAnchor.constraint(equalToConstant: 42),
            occupationField.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        return (card, nameField, occupationField)
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveTapped() {
        let alert = UIAlertController(
            title: "Success",
            message: "Profile updated successfully!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func cameraTapped() {
        let alert = UIAlertController(
            title: "Change Photo",
            message: "Select an option",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
