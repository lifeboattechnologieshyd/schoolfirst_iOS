import UIKit

class FeefulltransactioVCTableViewCell2: UITableViewCell {

    @IBOutlet weak var Containerview: UIView!

    private let iconBackground = UIView()
    private let feeImage = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let statusLabel = UILabel()
    private let arrowImage = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupContainer()
        setupUI()
    }

    private func setupContainer() {
        Containerview.layer.cornerRadius = 12
        Containerview.layer.borderWidth = 1
        Containerview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        Containerview.backgroundColor = .white
    }

    private func setupUI() {
        [iconBackground, titleLabel, dateLabel, amountLabel, statusLabel, arrowImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            Containerview.addSubview($0)
        }

        iconBackground.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        iconBackground.layer.cornerRadius = 12

        feeImage.translatesAutoresizingMaskIntoConstraints = false
        feeImage.contentMode = .scaleAspectFit
        iconBackground.addSubview(feeImage)

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .gray

        amountLabel.font = .systemFont(ofSize: 16, weight: .bold)
        amountLabel.textAlignment = .right

        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 6
        statusLabel.clipsToBounds = true

        arrowImage.image = UIImage(systemName: "chevron.down")
        arrowImage.tintColor = .lightGray
        arrowImage.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: Containerview.leadingAnchor, constant: 12),
            iconBackground.centerYAnchor.constraint(equalTo: Containerview.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 50),
            iconBackground.heightAnchor.constraint(equalToConstant: 50),

            feeImage.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            feeImage.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            feeImage.widthAnchor.constraint(equalToConstant: 24),
            feeImage.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: iconBackground.topAnchor, constant: 2),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            // Pinned to trailing
            arrowImage.trailingAnchor.constraint(equalTo: Containerview.trailingAnchor, constant: -12),
            arrowImage.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 12),
            arrowImage.heightAnchor.constraint(equalToConstant: 12),

            amountLabel.trailingAnchor.constraint(equalTo: arrowImage.trailingAnchor),
            amountLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),

            statusLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -4),
            statusLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            statusLabel.widthAnchor.constraint(equalToConstant: 75),
            statusLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(title: String, date: String, amount: String, status: String, isPaid: Bool, iconName: String, themeColor: UIColor, overdueNote: String? = nil) {
        titleLabel.text = title
        dateLabel.text = overdueNote ?? date
        dateLabel.textColor = overdueNote != nil ? .systemRed : .gray
        amountLabel.text = "₹\(amount)"
        feeImage.image = UIImage(systemName: iconName)
        feeImage.tintColor = themeColor
        iconBackground.backgroundColor = themeColor.withAlphaComponent(0.1)

        if isPaid {
            statusLabel.text = "Paid"
            statusLabel.textColor = .systemGreen
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            arrowImage.isHidden = false
            Containerview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        } else {
            statusLabel.text = "Pay Now"
            statusLabel.textColor = .white
            statusLabel.backgroundColor = UIColor(red: 26/255, green: 35/255, blue: 126/255, alpha: 1.0)
            arrowImage.isHidden = true
            Containerview.layer.borderColor = themeColor.withAlphaComponent(0.2).cgColor
        }
    }
}
