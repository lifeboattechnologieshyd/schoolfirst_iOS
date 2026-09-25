//
//  TRSPTpaymentbuttonUITableViewCell4.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 29/07/26.
//

import UIKit

class TRSPTpaymentbuttonUITableViewCell4: UITableViewCell {

    @IBOutlet weak var ConnectwithsupportteamLabel: UILabel!
    @IBOutlet weak var NeedhelpLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func setupFonts() {
        // --- Student Header Profile Card ---
        // Prominent name (e.g., "Ananya Reddy")
        NeedhelpLabel?.font = .hankenBold(size: 16)
        ConnectwithsupportteamLabel?.font = .hankenSemiBold(size: 14)
    }
    
}
