//
//  StudentdetailsTableViewCell.swift
//  SchoolFirst
//

import UIKit

class StudentdetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var HosteldetailsLbl: UIView!
    @IBOutlet weak var PickuppointLbl: UILabel!
    @IBOutlet weak var TransportrequiredLbl: UILabel!
    @IBOutlet weak var ExampercentageLbl: UILabel!
    @IBOutlet weak var TCnumberLbl: UILabel!
    @IBOutlet weak var PreviousschoolnameLbl: UILabel!
    @IBOutlet weak var EmergencycontactnumberLbl: UILabel!
    @IBOutlet weak var EmergencycontactnameLbl: UILabel!
    @IBOutlet weak var GuardianaccupationLbl: UILabel!
    @IBOutlet weak var GuardianmobilenumberLbl: UILabel!
    @IBOutlet weak var GuardiannameLbl: UILabel!
    @IBOutlet weak var MotherAccupationLbl: UILabel!
    @IBOutlet weak var MothermobilenumberLbl: UILabel!
    @IBOutlet weak var MothernameLbl: UILabel!
    @IBOutlet weak var FatheraccupationLbl: UILabel!
    @IBOutlet weak var FathermobilenumberLbl: UILabel!
    @IBOutlet weak var FatherNameLbl: UILabel!
    @IBOutlet weak var IdentificationmarkLbl: UILabel!
    @IBOutlet weak var SubcasteLbl: UILabel!
    @IBOutlet weak var CasteLbl: UILabel!
    @IBOutlet weak var RegionLbl: UILabel!
    @IBOutlet weak var AddressLbl: UILabel!
    @IBOutlet weak var MailLbl: UILabel!
    @IBOutlet weak var MothertongueLbl: UILabel!
    @IBOutlet weak var NationalityLbl: UILabel!
    @IBOutlet weak var BloodgroupLbl: UILabel!
    @IBOutlet weak var GenderLbl: UILabel!
    @IBOutlet weak var DateofbirthLbl: UILabel!
    @IBOutlet weak var StudentcategeryLbl: UILabel!
    @IBOutlet weak var EnrollmenttypeLbl: UILabel!
    @IBOutlet weak var AdmissiondateLbl: UILabel!
    @IBOutlet weak var AcadamicyearLbl: UILabel!
    @IBOutlet weak var BoardLbl: UILabel!
    @IBOutlet weak var SchoolnameLbl: UILabel!
    @IBOutlet weak var GradeLbl: UILabel!
    @IBOutlet weak var RollnumberLbl: UILabel!
    @IBOutlet weak var AdmitionLbl: UILabel!
    @IBOutlet weak var StudentnameLbl: UILabel!
    @IBOutlet weak var StudentImage: UIImageView!
    
    private var imageRequestURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearAllFields()
    }
    
    private func setupUI() {
        StudentImage?.layer.cornerRadius = (StudentImage?.frame.height ?? 80) / 2
        StudentImage?.clipsToBounds = true
        StudentImage?.contentMode = .scaleAspectFill
        StudentImage?.layer.borderWidth = 1.0
        StudentImage?.layer.borderColor = UIColor.systemGray5.cgColor
    }

    // MARK: - API Mapping Configuration
    
    func configure(with data: StudentProfileData) {
        
        // ── 1. Basic Information ────────────────────────────
        StudentnameLbl.text = data.name.isEmpty ? "--" : data.name
        AdmitionLbl.text    = data.admissionNumber.isEmpty ? "Admission No: --" : " \(data.admissionNumber)"
        RollnumberLbl.text  = data.rollNumber == 0 ? "Roll No: --" : " \(data.rollNumber)"
        
        let gradeName = data.grade?.name ?? "--"
        let sectionName = data.section?.name ?? "--"
        GradeLbl.text       = "\(gradeName) - \(sectionName)"
        
        // ── 2. School Context ──────────────────────────────
        SchoolnameLbl.text   = data.school?.name.isEmpty == false ? data.school?.name : "--"
        BoardLbl.text        = data.board.isEmpty ? "--" : data.board
        AcadamicyearLbl.text = data.academicYear?.name.isEmpty == false ? data.academicYear?.name : "--"
        AdmissiondateLbl.text = data.formattedAdmissionDate
        EnrollmenttypeLbl.text = data.enrollmentType.isEmpty ? "--" : data.enrollmentType
        StudentcategeryLbl.text = data.studentCategory.isEmpty ? "--" : data.studentCategory
        
        // ── 3. Personal Metadata ────────────────────────────
        DateofbirthLbl.text     = data.formattedDateOfBirth
        GenderLbl.text          = data.gender.isEmpty ? "--" : data.gender.capitalized
        BloodgroupLbl.text      = data.bloodGroup.isEmpty ? "--" : data.bloodGroup
        NationalityLbl.text     = data.nationality.isEmpty ? "--" : data.nationality
        MothertongueLbl.text    = data.motherTongue.isEmpty ? "--" : data.motherTongue
        MailLbl.text            = data.email.isEmpty ? "--" : data.email
        AddressLbl.text         = data.address.isEmpty ? "--" : data.address
        
        // ── 4. Demographics ─────────────────────────────────
        RegionLbl.text             = data.religion.isEmpty ? "--" : data.religion
        CasteLbl.text              = data.caste.isEmpty ? "--" : data.caste
        SubcasteLbl.text           = data.subCaste.isEmpty ? "--" : data.subCaste
        IdentificationmarkLbl.text = data.identificationMarks.isEmpty ? "--" : data.identificationMarks
        
        // ── 5. Parent & Guardian Struct Mapping ─────────────
        if let parent = data.parent {
            FatherNameLbl.text           = parent.fatherName.isEmpty ? "--" : parent.fatherName
            FathermobilenumberLbl.text   = parent.fatherMobile.isEmpty ? "--" : parent.fatherMobile
            FatheraccupationLbl.text     = parent.fatherOccupation.isEmpty ? "--" : parent.fatherOccupation
            
            MothernameLbl.text           = parent.motherName.isEmpty ? "--" : parent.motherName
            MothermobilenumberLbl.text   = parent.motherMobile.isEmpty ? "--" : parent.motherMobile
            MotherAccupationLbl.text     = parent.motherOccupation.isEmpty ? "--" : parent.motherOccupation
            
            GuardiannameLbl.text         = parent.guardianName?.isEmpty == false ? parent.guardianName : "--"
            GuardianmobilenumberLbl.text = parent.guardianMobile.isEmpty ? "--" : parent.guardianMobile
            GuardianaccupationLbl.text   = parent.guardianOccupation?.isEmpty == false ? parent.guardianOccupation : "--"
        } else {
            FatherNameLbl.text = "--"; FathermobilenumberLbl.text = "--"; FatheraccupationLbl.text = "--"
            MothernameLbl.text = "--"; MothermobilenumberLbl.text = "--"; MotherAccupationLbl.text = "--"
            GuardiannameLbl.text = "--"; GuardianmobilenumberLbl.text = "--"; GuardianaccupationLbl.text = "--"
        }
        
        // ── 6. Emergency Contact ───────────────────────────
        if let emergency = data.emergencyContact {
            EmergencycontactnameLbl.text   = emergency.name.isEmpty ? "--" : emergency.name
            EmergencycontactnumberLbl.text = emergency.mobile.isEmpty ? "--" : emergency.mobile
        } else {
            EmergencycontactnameLbl.text = "--"
            EmergencycontactnumberLbl.text = "--"
        }
        
        // ── 7. Academic Legacy ──────────────────────────────
        if let previous = data.previousSchool {
            PreviousschoolnameLbl.text = previous.name.isEmpty ? "--" : previous.name
            TCnumberLbl.text           = previous.tcNumber.isEmpty ? "--" : previous.tcNumber
            ExampercentageLbl.text     = previous.examPercentage == 0 ? "--" : "\(previous.examPercentage)%"
        } else {
            PreviousschoolnameLbl.text = "--"
            TCnumberLbl.text           = "--"
            ExampercentageLbl.text     = "--"
        }
        
        // ── 8. Logistical Details ───────────────────────────
        if let transport = data.transport {
            TransportrequiredLbl.text = transport.required ? "Yes" : "No"
            PickuppointLbl.text       = transport.pickupPoint.isEmpty ? "--" : transport.pickupPoint
        } else {
            TransportrequiredLbl.text = "No"
            PickuppointLbl.text       = "--"
        }
        
        // Handle Hostel Container Layout State
        if !data.hostelType.isEmpty {
            HosteldetailsLbl.isHidden = false
        } else {
            HosteldetailsLbl.isHidden = true
        }
        
        // ── 9. Image Loading Engine ────────────────────────
        if let photoString = data.photoUrl, !photoString.isEmpty {
            loadImage(from: photoString)
        } else {
            StudentImage.image = UIImage(named: "avatar_placeholder") // Default avatar fallback asset
        }
    }
    
    // MARK: - Reset Layout / Skeleton Placeholders
    
    func clearAllFields() {
        StudentnameLbl.text = "Loading..."
        AdmitionLbl.text = "Admission No: --"
        RollnumberLbl.text = "Roll No: --"
        GradeLbl.text = "--"
        SchoolnameLbl.text = "--"
        BoardLbl.text = "--"
        AcadamicyearLbl.text = "--"
        AdmissiondateLbl.text = "--"
        EnrollmenttypeLbl.text = "--"
        StudentcategeryLbl.text = "--"
        DateofbirthLbl.text = "--"
        GenderLbl.text = "--"
        BloodgroupLbl.text = "--"
        NationalityLbl.text = "--"
        MothertongueLbl.text = "--"
        MailLbl.text = "--"
        AddressLbl.text = "--"
        RegionLbl.text = "--"
        CasteLbl.text = "--"
        SubcasteLbl.text = "--"
        IdentificationmarkLbl.text = "--"
        FatherNameLbl.text = "--"; FathermobilenumberLbl.text = "--"; FatheraccupationLbl.text = "--"
        MothernameLbl.text = "--"; MothermobilenumberLbl.text = "--"; MotherAccupationLbl.text = "--"
        GuardiannameLbl.text = "--"; GuardianmobilenumberLbl.text = "--"; GuardianaccupationLbl.text = "--"
        EmergencycontactnameLbl.text = "--"; EmergencycontactnumberLbl.text = "--"
        PreviousschoolnameLbl.text = "--"; TCnumberLbl.text = "--"; ExampercentageLbl.text = "--"
        TransportrequiredLbl.text = "--"; PickuppointLbl.text = "--"
        HosteldetailsLbl.isHidden = true
        StudentImage.image = UIImage(named: "avatar_placeholder")
        imageRequestURL = nil
    }
    
    // MARK: - Image Loader
    
    private func loadImage(from urlString: String) {
        imageRequestURL = urlString
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, error == nil, let data = data, let downloadedImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                // Ensure image matches the current requested URL to prevent cell scrolling mismatch
                if self.imageRequestURL == urlString {
                    self.StudentImage.image = downloadedImage
                }
            }
        }.resume()
    }
}
