import UIKit

class FeefulltransactionVC: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var TopView: UIView!

    let feeData: [(section: String, items: [(title: String, date: String, amount: String, status: String, isPaid: Bool, icon: String, color: UIColor, note: String?)])] = [
        ("School Transport (Van Fee)", [
            ("July Transport Fee", "01 Jul'26", "5,000", "Paid", true, "bus.fill", .systemBlue, nil),
            ("August Transport Fee", "28 Aug'26", "5,000", "Pay Now", false, "bus.fill", .systemRed, "Overdue by 5 days")
        ]),
        ("Academic Fees (Term 1)", [
            ("Admission Fee", "10 Feb'26", "34,000", "Paid", true, "graduationcap.fill", .systemBrown, nil),
            ("Tuition Fee - Phase 1", "Due 15 Aug'26", "15,000", "Pay Now", false, "book.fill", .systemGray, nil)
        ]),
        ("Activities & Events", [
            ("Annual Sports Day", "Registration Pending", "2,500", "Pay Now", false, "party.popper.fill", .systemOrange, "Registration Pending")
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopViewShadow()
        setupTableView()
    }
    
    @IBAction func BackButtonTapped(_ sender: UIButton) {

        if let nav = navigationController {

            nav.popViewController(
                animated: true
            )

        } else {

            dismiss(
                animated: true
            )
        }
    }


    private func setupTopViewShadow() {
        TopView.layer.shadowColor = UIColor.lightGray.cgColor
        TopView.layer.shadowOpacity = 0.3
        TopView.layer.shadowOffset = CGSize(width: 0, height: 3)
        TopView.layer.shadowRadius = 2
        TopView.layer.masksToBounds = false
    }

    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.separatorStyle = .none
        tableview.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        
        tableview.register(UINib(nibName: "FeefulltransactioVCTableViewCell1", bundle: nil), forCellReuseIdentifier: "FeefulltransactioVCTableViewCell1")
        tableview.register(UINib(nibName: "FeefulltransactioVCTableViewCell2", bundle: nil), forCellReuseIdentifier: "FeefulltransactioVCTableViewCell2")
    }
}

extension FeefulltransactionVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + feeData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : feeData[section - 1].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeefulltransactioVCTableViewCell1", for: indexPath) as! FeefulltransactioVCTableViewCell1
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeefulltransactioVCTableViewCell2", for: indexPath) as! FeefulltransactioVCTableViewCell2
            let item = feeData[indexPath.section - 1].items[indexPath.row]
            cell.configure(title: item.title, date: item.date, amount: item.amount, status: item.status, isPaid: item.isPaid, iconName: item.icon, themeColor: item.color, overdueNote: item.note)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = feeData[section - 1].section
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8) // Closer to cell
        ])
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 20 // Reduced from 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 92 // Tighter cell height
    }
}
