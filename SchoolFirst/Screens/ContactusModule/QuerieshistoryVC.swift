//
//  QuerieshistoryVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QuerieshistoryVC: UIViewController {

    @IBOutlet weak var Addquerybutton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableview: UITableView!

    private var tickets: [TicketItem] = []
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // Changing to viewWillAppear ensures the list refreshes automatically
    // when you come back from creating a new ticket!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTicketList()
    }
    
    // MARK: - Button Actions
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // 👉 ADDED: Action to navigate to RaiseaQueryVC
    @IBAction func addQueryButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let raiseQueryVC = storyboard.instantiateViewController(withIdentifier: "RaiseaQueryVC") as? RaiseaQueryVC {
            self.navigationController?.pushViewController(raiseQueryVC, animated: true)
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self

        // Register Query Cell
        tableview.register(
            UINib(
                nibName: "QueryTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "QueryTableViewCell"
        )

        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
    }
    
    // MARK: - API 1: Fetch Tickets List
    
    private func fetchTicketList() {
        guard !isLoading else { return }
        isLoading = true
        showLoader()
        
        // Exact URL matching Django pattern: user/support/tickets
        let url = API.GET_TICKETS_LIST
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<[TicketItem]>, NetworkError>) in
            guard let self = self else { return }
            self.isLoading = false
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success {
                    self.tickets = info.data ?? []
                    DispatchQueue.main.async {
                        
                        // 👉 CHECK IF TICKETS ARE EMPTY
                        if self.tickets.isEmpty {
                            self.navigateToComingSoon()
                        } else {
                            self.tableview.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Empty State Navigation
    
    private func navigateToComingSoon() {
        // NOTE: Change "Main" if ComingSoonVC is inside a different storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let comingSoonVC = storyboard.instantiateViewController(withIdentifier: "ComingSoonVC")
        
        // We replace this current view controller in the stack.
        // This ensures that hitting "Back" on the ComingSoonVC goes back to the Dashboard/Home,
        // preventing an infinite loop of empty screens.
        if var viewControllers = self.navigationController?.viewControllers {
            viewControllers.removeLast() // Removes QuerieshistoryVC from stack
            viewControllers.append(comingSoonVC) // Adds ComingSoonVC
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        } else {
            // Fallback if no navigation controller
            self.present(comingSoonVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - API 2: Fetch Ticket Details on Item Selection
    
    private func fetchTicketDetailsAndNavigate(ticketId: String) {
        showLoader()
        
        // Matches Django pattern: user/support/tickets/<uuid:ticket_id>/
        let url = API.GET_TICKET_DETAIL + ticketId
        
        NetworkManager.shared.request(urlString: url, method: .GET) { [weak self] (result: Result<APIResponse<TicketData>, NetworkError>) in
            guard let self = self else { return }
            self.hideLoader()
            
            switch result {
            case .success(let info):
                if info.success, let ticketData = info.data {
                    DispatchQueue.main.async {
                        self.navigateToChatVC(with: ticketData)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: info.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(msg: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToChatVC(with ticketDetails: TicketData) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            // Pass the details (including messages) to ChatVC
            // chatVC.ticketData = ticketDetails
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension QuerieshistoryVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "QueryTableViewCell",
            for: indexPath
        ) as! QueryTableViewCell

        cell.selectionStyle = .none
        let ticket = tickets[indexPath.row]
        cell.configure(with: ticket)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTicket = tickets[indexPath.row]
        if let ticketId = selectedTicket.id, !ticketId.isEmpty {
            // Calls API 2 to load details before opening ChatVC
            fetchTicketDetailsAndNavigate(ticketId: ticketId)
        }
    }
}
