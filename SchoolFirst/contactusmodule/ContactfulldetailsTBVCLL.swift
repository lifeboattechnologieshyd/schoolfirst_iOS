//
//  ContactfulldetailsTBVCLL.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 15/09/26.
//

import UIKit

class ContactfulldetailsTBVCLL: UITableViewCell {

    @IBOutlet weak var ChatButton: UIButton!

    // MARK: - Callback closure
    var onChatButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        ChatButton?.addTarget(self, action: #selector(chatButtonAction), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc private func chatButtonAction() {
        onChatButtonTapped?()
    }
}
