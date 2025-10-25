//
//  FeelPlayerController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 18/10/25.
//

import UIKit

class FeelPlayerController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = ""
        topView.addBottomShadow()

    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
