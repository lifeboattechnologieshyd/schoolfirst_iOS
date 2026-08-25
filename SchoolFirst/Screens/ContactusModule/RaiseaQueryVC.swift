//
//  RaiseaQueryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class RaiseaQueryVC: UIViewController {

    @IBOutlet weak var Descriptiontextfield: UITextField!
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var SumitqueryButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Optional: Dismiss keyboard when tapping outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Submit Query Button
    @IBAction func SubmitqueryButtonTapped(_ sender: UIButton) {
        // 1. Dismiss Keyboard
        view.endEditing(true)
        
        // 2. Validate Inputs
        guard let title = titletextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlert(msg: "Please enter a query title.")
            return
        }
        
        guard let description = Descriptiontextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty else {
            showAlert(msg: "Please enter a description.")
            return
        }
        
        // 3. Setup API Payload
        let parameters: [String: Any] = [
            "title": title,
            "description": description
        ]
        
        // 4. Call API
        postTicketAPI(parameters: parameters)
    }
    
    // MARK: - API Integration
    private func postTicketAPI(parameters: [String: Any]) {
        self.showLoader()
        
        let url = API.CREATE_TICKET
        
        // Use .POST method and pass parameters
        NetworkManager.shared.request(urlString: url, method: .POST, parameters: parameters) { [weak self] (result: Result<APIResponse<EmptyTicketData>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success {
                    // Success! Navigate to next screen
                    DispatchQueue.main.async {
                        self.navigateToSuccessScreen()
                    }
                } else {
                    // API returned false success
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                // Network or Parsing Error
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    private func navigateToSuccessScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let querySubmittedVC = storyboard.instantiateViewController(withIdentifier: "QuerysubmittedVC") as? QuerysubmittedVC {
            
            // Clear textfields so they are empty if the user comes back
            self.titletextfield.text = ""
            self.Descriptiontextfield.text = ""
            
            self.navigationController?.pushViewController(querySubmittedVC, animated: true)
        }
    }
}
