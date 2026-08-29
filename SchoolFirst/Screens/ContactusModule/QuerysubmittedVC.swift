
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

    /// Passed from RaiseaQueryVC after ticket creation.
    /// May be nil because the create API returns "data": {}
    var ticketId: String?

    /// Full ticket data from the detail API
    private var ticketDetails: TicketData?

    /// Number of characters shown in the ticket id label
    /// Changed from 4 to 6
    private let ticketIdDisplayLength = 6

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        print(
            "📥 QuerysubmittedVC received ticketId:",
            ticketId ?? "nil"
        )

        loadTicketId()
    }

    // MARK: - Ticket ID Resolution

    /*
     The create ticket API currently returns "data": {} with no id.

     So the flow is:
     1. If an id was passed in -> show it, then confirm with detail API
     2. If no id was passed in -> fetch the ticket list and use the
        most recently created ticket
     */

    private func loadTicketId() {

        let incomingId = ticketId?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        if incomingId.isEmpty {

            TicketidLbl.text = "Fetching ticket ID..."

            fetchLatestTicketFromList()

        } else {

            configureTicketIdLabel(incomingId)

            fetchTicketDetails(for: incomingId)
        }
    }

    // MARK: - Ticket ID Label

    private func configureTicketIdLabel(_ id: String?) {

        guard let rawId = id?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            !rawId.isEmpty
        else {

            TicketidLbl.text = "Ticket ID unavailable"

            return
        }

        TicketidLbl.text =
            "\(shortTicketId(from: rawId))"
    }

    /// Returns only the last 6 characters of the ticket id.
    ///
    /// Same cleaning logic used in QueryTableViewCell.
    ///
    /// Example:
    /// "38d2ba22-9bff-4561-9b4e-c58b3ffc3b33" -> "3B3C33"
    /// "#1024"                              -> "1024"
    /// "7"                                  -> "7"

    private func shortTicketId(from id: String) -> String {

        let cleaned = id
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "#",
                with: ""
            )
            .replacingOccurrences(
                of: "-",
                with: ""
            )

        guard !cleaned.isEmpty else {
            return ""
        }

        // ==========================================
        // Show LAST 6 characters
        // ==========================================

        guard cleaned.count > ticketIdDisplayLength else {
            return cleaned.uppercased()
        }

        return String(
            cleaned.suffix(ticketIdDisplayLength)
        ).uppercased()
    }

    // MARK: - API: Latest Ticket From List (fallback)

    /*
     Used when the create API did not return an id.

     The newest ticket in the list is the one just created.
     */

    private func fetchLatestTicketFromList() {

        showLoader()

        NetworkManager.shared.request(
            urlString: API.GET_TICKETS_LIST,
            method: .GET
        ) { [weak self] (
            result: Result<APIResponse<[TicketItem]>, NetworkError>
        ) in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                self.hideLoader()

                switch result {

                case .success(let info):

                    guard info.success,
                          let tickets = info.data,
                          !tickets.isEmpty
                    else {

                        print(
                            "⚠️ Ticket list empty or failed:",
                            info.description
                        )

                        self.configureTicketIdLabel(nil)

                        return
                    }

                    guard let newest =
                            self.newestTicket(from: tickets),
                          let newestId = newest.id,
                          !newestId.isEmpty
                    else {

                        print(
                            "⚠️ Could not determine newest ticket id."
                        )

                        self.configureTicketIdLabel(nil)

                        return
                    }

                    self.ticketId = newestId

                    self.configureTicketIdLabel(
                        newestId
                    )

                    print(
                        "✅ Recovered ticket id from list:",
                        newestId
                    )

                    print(
                        "Displayed ID:",
                        self.TicketidLbl.text ?? ""
                    )

                case .failure(let error):

                    print(
                        "❌ Ticket list API failed:",
                        error.localizedDescription
                    )

                    self.configureTicketIdLabel(nil)
                }
            }
        }
    }

    /// Picks the ticket with the latest createdAt.
    /// Falls back to the first item if dates cannot be parsed.

    private func newestTicket(
        from tickets: [TicketItem]
    ) -> TicketItem? {

        let sorted = tickets.sorted { lhs, rhs in

            let lhsDate =
                parseServerDate(lhs.createdAt)

            let rhsDate =
                parseServerDate(rhs.createdAt)

            switch (lhsDate, rhsDate) {

            case let (l?, r?):
                return l > r

            case (_?, nil):
                return true

            case (nil, _?):
                return false

            default:
                return false
            }
        }

        return sorted.first ?? tickets.first
    }

    private func parseServerDate(
        _ dateString: String?
    ) -> Date? {

        guard let dateString = dateString,
              !dateString.isEmpty
        else {
            return nil
        }

        let isoFormatter =
            ISO8601DateFormatter()

        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date =
            isoFormatter.date(
                from: dateString
            ) {
            return date
        }

        isoFormatter.formatOptions = [
            .withInternetDateTime
        ]

        if let date =
            isoFormatter.date(
                from: dateString
            ) {
            return date
        }

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        for format in formats {

            formatter.dateFormat =
                format

            if let date =
                formatter.date(
                    from: dateString
                ) {
                return date
            }
        }

        return nil
    }

    // MARK: - API: Ticket Details

    private func fetchTicketDetails(
        for id: String
    ) {

        showLoader()

        // API.GET_TICKET_DETAIL =
        // "https://dev-api.schoolfirst.ai/user/support/tickets/"

        let url =
            API.GET_TICKET_DETAIL + id

        NetworkManager.shared.request(
            urlString: url,
            method: .GET
        ) { [weak self] (
            result: Result<APIResponse<TicketData>, NetworkError>
        ) in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                self.hideLoader()

                switch result {

                case .success(let info):

                    if info.success,
                       let ticketData = info.data {

                        self.ticketDetails =
                            ticketData

                        // Prefer the id from the detail API,
                        // otherwise keep the one we already have.

                        let confirmedId =
                            ticketData.id ?? self.ticketId

                        self.ticketId =
                            confirmedId

                        self.configureTicketIdLabel(
                            confirmedId
                        )

                        print(
                            "✅ Ticket Detail API Success"
                        )

                        print(
                            "Full Ticket ID:",
                            confirmedId ?? "No ID received"
                        )

                        print(
                            "Displayed ID:",
                            self.TicketidLbl.text ?? ""
                        )

                    } else {

                        // Keep the already displayed id, only log

                        print(
                            "⚠️ Ticket detail API error:",
                            info.description
                        )
                    }

                case .failure(let error):

                    // Keep the already displayed id visible

                    print(
                        "❌ Ticket detail API failed:",
                        error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: - Back Button

    @IBAction func backButtonTapped(
        _ sender: UIButton
    ) {

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let queriesHistoryVC =
                storyboard.instantiateViewController(
                    withIdentifier: "QuerieshistoryVC"
                ) as? QuerieshistoryVC
        else {
            return
        }

        navigationController?.pushViewController(
            queriesHistoryVC,
            animated: true
        )
    }

    // MARK: - Raise Another Query

    @IBAction func RaiseanotherqueryTapped(
        _ sender: UIButton
    ) {

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let raiseVC =
                storyboard.instantiateViewController(
                    withIdentifier: "RaiseaQueryVC"
                ) as? RaiseaQueryVC
        else {
            return
        }

        navigationController?.pushViewController(
            raiseVC,
            animated: true
        )
    }

    // MARK: - View This Query

    @IBAction func ViewthisqueryButtonTapped(
        _ sender: UIButton
    ) {

        let storyboard =
            UIStoryboard(
                name: "Main",
                bundle: nil
            )

        guard let queriesHistoryVC =
                storyboard.instantiateViewController(
                    withIdentifier: "QuerieshistoryVC"
                ) as? QuerieshistoryVC
        else {
            return
        }

        navigationController?.pushViewController(
            queriesHistoryVC,
            animated: true
        )
    }
}
