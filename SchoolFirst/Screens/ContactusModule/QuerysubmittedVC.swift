//
//  QuerysubmittedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 20/08/26.
//

import UIKit

class QuerysubmittedVC: UIViewController {

    @IBOutlet weak var TicketidLbl: UILabel!
    @IBOutlet weak var Raiseanotherquery: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ViewthisqueryButton: UIButton!

    // Receive this ID from RaiseaQueryVC after ticket creation
    var ticketId: String?

    // Stores data received from ticket detail API
    private var ticketDetails: TicketData?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        // First show received ticket ID immediately
        configureTicketIdLabel(ticketId)

        // Then get full ticket details using ticket ID
        fetchTicketDetails()
    }

    // MARK: - Configure Ticket ID Label

    private func configureTicketIdLabel(_ id: String?) {
        guard let ticketId = id?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ticketId.isEmpty else {
            TicketidLbl.text = "Ticket ID unavailable"
            return
        }

        // Same formatting used in QueryTableViewCell
        TicketidLbl.text = ticketId.hasPrefix("#") ? ticketId : "#\(ticketId)"
    }

    // MARK: - Get Ticket Details API

    private func fetchTicketDetails() {
        guard let ticketId = ticketId?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ticketId.isEmpty else {
            print("Ticket ID is nil. Cannot call Ticket Detail API.")
            return
        }

        showLoader()

        // Example:
        // API.GET_TICKET_DETAIL =
        // "https://dev-api.schoolfirst.ai/user/support/tickets/"
        let url = API.GET_TICKET_DETAIL + ticketId

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<TicketData>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }

                self.hideLoader()

                switch result {
                case .success(let info):

                    if info.success, let ticketData = info.data {
                        self.ticketDetails = ticketData

                        // Detail API ID is preferred.
                        // If not received, retain original ID.
                        let receivedTicketId = ticketData.id ?? self.ticketId

                        self.ticketId = receivedTicketId
                        self.configureTicketIdLabel(receivedTicketId)

                        print("Ticket Detail API Success")
                        print("Ticket ID:", receivedTicketId ?? "No ID received")

                    } else {
                        // Keep incoming ticket ID on the screen.
                        // Only log error; do not remove already displayed ID.
                        print("Ticket detail API error:", info.description)
                    }

                case .failure(let error):
                    // Keep received ticket ID visible even if detail API fails.
                    print("Ticket detail API failed:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Back Button

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Raise Another Query Button

    @IBAction func RaiseanotherqueryTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let raiseVC = storyboard.instantiateViewController(
            withIdentifier: "RaiseaQueryVC"
        ) as? RaiseaQueryVC {
            navigationController?.pushViewController(
                raiseVC,
                animated: true
            )
        }
    }

    // MARK: - View This Query Button

    @IBAction func ViewthisqueryButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let queriesHistoryVC = storyboard.instantiateViewController(
            withIdentifier: "QuerieshistoryVC"
        ) as? QuerieshistoryVC {
            navigationController?.pushViewController(
                queriesHistoryVC,
                animated: true
            )
        }
    }
}
