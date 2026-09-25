//
//  TRSPRpickupUITableviewcell3.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 17/09/26.
//

import UIKit

class TRSPRpickupUITableviewcell3: UITableViewCell {

    @IBOutlet weak var Callbutton: UIButton!
    @IBOutlet weak var MessageButton: UIButton!
    @IBOutlet weak var DriverimageView: UIImageView!
    @IBOutlet weak var DrivernameLabel: UILabel!
    
    // Callbacks to forward click operations
    var onCallTapped: (() -> Void)?
    var onMessageTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupFonts()
    }
    private func setupFonts() {
        DrivernameLabel?.font = .hankenBold(size: 16)
        
    }
    

    private func setupUI() {
        // Round the image profile layout automatically
        DriverimageView.layer.cornerRadius = DriverimageView.frame.size.height / 2
        DriverimageView.clipsToBounds = true
        
        Callbutton.addTarget(self, action: #selector(callActionTapped), for: .touchUpInside)
        MessageButton.addTarget(self, action: #selector(messageActionTapped), for: .touchUpInside)
    }

    func configure(driverName: String?, imageURL: String?) {
        DrivernameLabel.text = driverName ?? "N/A"
        
        // Reset old image so reused cells don't show wrong driver image while downloading
        DriverimageView.image = UIImage(named: "placeholder_driver") // Change "placeholder_driver" with your local placeholder name
        
        guard let urlString = imageURL, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let fetchedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.DriverimageView.image = fetchedImage
                }
            }
        }.resume()
    }

    @objc private func callActionTapped() {
        onCallTapped?()
    }

    @objc private func messageActionTapped() {
        onMessageTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
