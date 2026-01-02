//
//  KidsCell.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/08/25.
//

import UIKit

class KidsCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
    
    func setupCell(student: Student) {
        nameLabel.text = student.name
        
        if !student.grade.isEmpty {
            gradeLabel.text = student.grade
        } else {
            gradeLabel.text = "No Grade"
        }
        
        if let imageUrl = student.image, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(named: "userImage")
        }
    }
    
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(named: "userImage")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
}
