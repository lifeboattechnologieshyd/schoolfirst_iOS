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

    // MARK: - View Will Appear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Refresh the ticket list whenever we come back
        // from ChatVC.
        fetchTicketList()
    }

    // MARK: - Button Actions

    @IBAction func backButtonTapped(_ sender: UIButton) {

        navigationController?.popViewController(animated: true)
    }

    @IBAction func addQueryButtonTapped(_ sender: UIButton) {

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

                        // Reload the table every time we return
                        // from ChatVC.
                        self.tableview.reloadData()

                        // Optional empty state
                        if self.tickets.isEmpty {
                            self.navigateToComingSoon()
                        }

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

            if !viewControllers.isEmpty {
                viewControllers.removeLast()
            }

            viewControllers.append(comingSoonVC)

            navigationController?.setViewControllers(
                viewControllers,
                animated: true
            )

        } else {

            present(
                comingSoonVC,
                animated: true
            )
        }
    }

    // MARK: - API 2: Ticket Details

    private func fetchTicketDetailsAndNavigate(
        ticket: TicketItem
    ) {

        guard let ticketId = ticket.id,
              !ticketId.isEmpty else {

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
            ) as? ChatVC else {

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

        let selectedTicket = tickets[indexPath.row]

        guard let ticketId = selectedTicket.id,
              !ticketId.isEmpty else {

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
