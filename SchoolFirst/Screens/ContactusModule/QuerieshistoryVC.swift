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

        // Hide the history UI initially.
        // This prevents QuerieshistoryVC from being visibly shown
        // before we know whether tickets are available.
        tableview.isHidden = true
        Addquerybutton.isHidden = true
        backButton.isHidden = true
    }

    // MARK: - View Will Appear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Refresh the ticket list whenever we come back
        // from ChatVC.
        fetchTicketList()
    }

    // MARK: - Button Actions

    @IBAction func backButtonTapped(
        _ sender: UIButton
    ) {

        // Always pop back to HomeViewController
        popToHomeViewController()
    }

    // MARK: - Pop To Home ViewController

    private func popToHomeViewController() {

        guard let navigationController = navigationController else {
            return
        }

        // Search for HomeViewController in the navigation stack
        for viewController in navigationController.viewControllers {

            if let homeVC = viewController as? HomeController    {

                // Found HomeViewController — pop to it
                navigationController.popToViewController(
                    homeVC,
                    animated: true
                )

                return
            }
        }

        // Fallback:
        // If HomeViewController is not in the stack,
        // pop to root view controller
        navigationController.popToRootViewController(
            animated: true
        )
    }

    @IBAction func addQueryButtonTapped(
        _ sender: UIButton
    ) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        if let raiseQueryVC =
            storyboard.instantiateViewController(
                withIdentifier: "RaiseaQueryVC"
            ) as? RaiseaQueryVC {

            navigationController?.pushViewController(
                raiseQueryVC,
                animated: true
            )
        }
    }

    // MARK: - TableView Setup

    private func setupTableView() {

        tableview.delegate = self
        tableview.dataSource = self

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

        // Prevent duplicate requests while one request
        // is already running.
        guard !isLoading else {
            return
        }

        isLoading = true

        let url = API.GET_TICKETS_LIST

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (
            result: Result<APIResponse<[TicketItem]>, NetworkError>
        ) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.isLoading = false

                switch result {

                case .success(let info):

                    if info.success {

                        self.tickets = info.data ?? []

                        // ==========================================
                        // CHECK IF TICKETS ARE AVAILABLE
                        // ==========================================

                        if self.tickets.isEmpty {

                            // No queries available.
                            // Navigate directly to ComingSoonVC.
                            self.navigateToComingSoon()

                            return
                        }

                        // ==========================================
                        // TICKETS AVAILABLE
                        // ==========================================

                        // Show history UI only when tickets exist.
                        self.tableview.isHidden = false
                        self.Addquerybutton.isHidden = false
                        self.backButton.isHidden = false

                        // ==========================================
                        // SORT TICKETS BY STATUS
                        // ==========================================
                        //
                        // OPEN        -> TOP
                        // REPLY SENT  -> AFTER OPEN
                        // RESOLVED    -> BOTTOM
                        //
                        // Other statuses stay between Reply Sent
                        // and Resolved.
                        // ==========================================

                        self.sortTicketsByStatus()

                        // Reload table
                        self.tableview.reloadData()

                    } else {

                        self.showAlert(
                            msg: info.description
                        )
                    }

                case .failure(let error):

                    self.showAlert(
                        msg: error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: - Sort Tickets By Status

    private func sortTicketsByStatus() {

        tickets.sort { firstTicket, secondTicket in

            let firstPriority = statusPriority(
                firstTicket.status
            )

            let secondPriority = statusPriority(
                secondTicket.status
            )

            return firstPriority < secondPriority
        }
    }

    // MARK: - Status Priority

    private func statusPriority(
        _ rawStatus: String?
    ) -> Int {

        let status = (rawStatus ?? "")
            .replacingOccurrences(
                of: "_",
                with: " "
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        switch status {

        case "OPEN":

            // Highest priority
            // Shows at the TOP
            return 0

        case "REPLY SENT":

            // Shows after OPEN
            return 1

        case "RESOLVED":

            // Lowest priority
            // Shows at the BOTTOM
            return 3

        default:

            // Other statuses
            // Stay between REPLY SENT and RESOLVED
            return 2
        }
    }

    // MARK: - Empty State

    private func navigateToComingSoon() {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        let comingSoonVC =
            storyboard.instantiateViewController(
                withIdentifier: "ComingSoonVC"
            )

        if var viewControllers =
            navigationController?.viewControllers {

            // Remove QuerieshistoryVC from the navigation stack
            // before adding ComingSoonVC.
            if !viewControllers.isEmpty {
                viewControllers.removeLast()
            }

            viewControllers.append(
                comingSoonVC
            )

            navigationController?.setViewControllers(
                viewControllers,
                animated: false
            )

        } else {

            present(
                comingSoonVC,
                animated: false
            )
        }
    }

    // MARK: - API 2: Ticket Details

    private func fetchTicketDetailsAndNavigate(
        ticket: TicketItem
    ) {

        guard let ticketId = ticket.id,
              !ticketId.isEmpty
        else {

            showAlert(
                msg: "Invalid ticket id"
            )

            return
        }

        showLoader()

        var base = API.GET_TICKET_DETAIL

        if !base.hasSuffix("/") {
            base += "/"
        }

        let url = base + ticketId

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (
            result: Result<APIResponse<TicketData>, NetworkError>
        ) in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.hideLoader()

                switch result {

                case .success(let info):

                    if info.success,
                       let ticketData = info.data {

                        self.navigateToChatVC(
                            ticketId: ticketId,
                            listItem: ticket,
                            detail: ticketData
                        )

                    } else {

                        // Even if details API fails,
                        // allow user to open the chat.

                        self.navigateToChatVC(
                            ticketId: ticketId,
                            listItem: ticket,
                            detail: nil
                        )
                    }

                case .failure:

                    // Allow navigation even if detail API
                    // fails.

                    self.navigateToChatVC(
                        ticketId: ticketId,
                        listItem: ticket,
                        detail: nil
                    )
                }
            }
        }
    }

    // MARK: - Navigate To Chat

    private func navigateToChatVC(
        ticketId: String,
        listItem: TicketItem,
        detail: TicketData?
    ) {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let chatVC =
            storyboard.instantiateViewController(
                withIdentifier: "ChatVC"
            ) as? ChatVC
        else {
            return
        }

        chatVC.ticketId = ticketId
        chatVC.ticketItem = listItem
        chatVC.ticketDetail = detail

        navigationController?.pushViewController(
            chatVC,
            animated: true
        )
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension QuerieshistoryVC:
    UITableViewDelegate,
    UITableViewDataSource {

    // MARK: - Number Of Sections

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {

        return 1
    }

    // MARK: - Number Of Rows

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return tickets.count
    }

    // MARK: - Cell For Row

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "QueryTableViewCell",
                for: indexPath
            ) as! QueryTableViewCell

        cell.selectionStyle = .none

        let ticket = tickets[indexPath.row]

        cell.configure(
            with: ticket
        )

        return cell
    }

    // MARK: - Cell Height

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 150
    }

    // MARK: - Did Select Row

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let selectedTicket =
            tickets[indexPath.row]

        guard let ticketId = selectedTicket.id,
              !ticketId.isEmpty
        else {

            showAlert(
                msg: "Invalid ticket"
            )

            return
        }

        // Fetch latest details before opening ChatVC.
        fetchTicketDetailsAndNavigate(
            ticket: selectedTicket
        )
    }
}
