//
//  DocumentsTableViewCell2.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 02/09/26.
//

import UIKit

class DocumentsTableViewCell2: UITableViewCell {

    @IBOutlet weak var Downloadducumentbutton: UIButton!
    @IBOutlet weak var Viewdocumentbutton: UIButton!
    @IBOutlet weak var DocumentnameLabel: UILabel!

    var onViewDocumentTapped: (() -> Void)?
    var onDownloadDocumentTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        Viewdocumentbutton.addTarget(
            self,
            action: #selector(viewDocumentButtonTapped),
            for: .touchUpInside
        )

        Downloadducumentbutton.addTarget(
            self,
            action: #selector(downloadDocumentButtonTapped),
            for: .touchUpInside
        )
    }

    func configure(with document: StudentDocument) {
        let title = document.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let documentType = document.documentType.trimmingCharacters(in: .whitespacesAndNewlines)

        DocumentnameLabel.text = title.isEmpty
            ? (documentType.isEmpty ? "Document" : documentType)
            : title

        let fileURL = document.fileUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasFileURL = !fileURL.isEmpty

        Viewdocumentbutton.isEnabled = hasFileURL
        Downloadducumentbutton.isEnabled = hasFileURL
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        DocumentnameLabel.text = nil
        onViewDocumentTapped = nil
        onDownloadDocumentTapped = nil
        Viewdocumentbutton.isEnabled = true
        Downloadducumentbutton.isEnabled = true
    }

    @objc private func viewDocumentButtonTapped() {
        onViewDocumentTapped?()
    }

    @objc private func downloadDocumentButtonTapped() {
        onDownloadDocumentTapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
