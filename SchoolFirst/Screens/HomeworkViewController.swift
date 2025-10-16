//
//  HomeworkViewController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 22/09/25.
//

import UIKit

class HomeworkViewController: UIViewController {
    @IBOutlet weak var lblTItle: UILabel!
    
    var screen_title = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTItle.text = screen_title
        
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
