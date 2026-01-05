//
//  SubmitLeaveViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 30/10/25.
//

import UIKit

class SubmitLeaveViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var bottomVw: UIView!
    
    private var leaveCell: SubmitLeaveTableCell?
    private var activityIndicator: UIActivityIndicatorView?
    
    // Selected student index
    var selected_student = 0
    
    // Track current cell height - Start with initial height
    private var currentCellHeight: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupActivityIndicator()
        setupKeyboardDismiss()
    }
    
    func setupUI() {
        topVw.addBottomShadow(shadowOpacity: 0.15, shadowRadius: 3, shadowHeight: 4)
        bottomVw.addTopShadow()
        submitButton.layer.cornerRadius = 8
    }
    
    func setupTableView() {
        tblVw.register(
            UINib(nibName: "SubmitLeaveTableCell", bundle: nil),
            forCellReuseIdentifier: "SubmitLeaveTableCell"
        )
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.allowsSelection = false
        tblVw.tableFooterView = UIView()
        tblVw.showsVerticalScrollIndicator = true
        
        // Enable scrolling
        tblVw.isScrollEnabled = true
        tblVw.bounces = true
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .gray
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        if let indicator = activityIndicator {
            view.addSubview(indicator)
        }
    }
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tblVw.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        view.endEditing(true) // Dismiss keyboard first
        submitLeaveRequest()
    }
    
    // MARK: - API Call
    
    func submitLeaveRequest() {
        
        guard let cell = leaveCell else {
            showAlert(title: "Error", message: "Unable to get leave data")
            return
        }
        
        guard let parameters = cell.getLeaveParameters() else {
            return
        }
        
        print("📤 Submitting Leave Request...")
        print("📋 Parameters: \(parameters)")
        
        showLoading(true)
        
        NetworkManager.shared.request(
            urlString: API.APPLY_LEAVE,
            method: .POST,
            parameters: parameters
        ) { [weak self] (result: Result<APIResponse<LeaveResponseData>, NetworkError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.showLoading(false)
                
                switch result {
                case .success(let response):
                    print("✅ API Response: \(response)")
                    
                    if response.success {
                        self.handleSuccess(response: response)
                    } else {
                        self.showAlert(title: "Error", message: response.description)
                    }
                    
                case .failure(let error):
                    print("❌ API Error: \(error)")
                    self.handleError(error: error)
                }
            }
        }
    }
    
    func handleSuccess(response: APIResponse<LeaveResponseData>) {
        let message = "Leave request submitted successfully!"
        
        let alert = UIAlertController(
            title: "Success ✅",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func handleError(error: NetworkError) {
        var message = "Failed to submit leave request. Please try again."
        
        switch error {
        case .serverError(let errorMessage):
            message = errorMessage
        case .noaccess:
            message = "Session expired. Please login again."
        case .noData:
            message = "No response from server. Please try again."
        case .decodingError(let errorMessage):
            message = "Data error: \(errorMessage)"
        case .invalidURL:
            message = "Invalid request. Please contact support."
        }
        
        showAlert(title: "Error", message: message)
    }
    
    func showLoading(_ show: Bool) {
        if show {
            activityIndicator?.startAnimating()
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator?.stopAnimating()
            submitButton.isEnabled = true
            submitButton.alpha = 1.0
            view.isUserInteractionEnabled = true
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateCellHeight(_ height: CGFloat) {
        guard height > 0, !height.isNaN, !height.isInfinite else {
            return
        }
        
        if currentCellHeight != height {
            currentCellHeight = height
            
            UIView.animate(withDuration: 0.3) {
                self.tblVw.beginUpdates()
                self.tblVw.endUpdates()
            }
        }
    }
}
    extension SubmitLeaveViewController: UITableViewDelegate, UITableViewDataSource {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SubmitLeaveTableCell",
                for: indexPath
            ) as! SubmitLeaveTableCell
            
            cell.selectionStyle = .none
            
            self.leaveCell = cell
            
            cell.configureWithKids(
                kids: UserManager.shared.kids,
                selectedIndex: selected_student
            )
            
            cell.onLayoutUpdate = { [weak self] height in
                guard let self = self else { return }
                self.updateCellHeight(height)
            }
            
            cell.onKidSelected = { [weak self] index in
                self?.selected_student = index
            }
            
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return currentCellHeight
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return currentCellHeight
        }
    }
