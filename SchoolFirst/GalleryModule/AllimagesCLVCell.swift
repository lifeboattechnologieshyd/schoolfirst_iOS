import UIKit

class AllimagesCLVCell: UICollectionViewCell {
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var EventnameLabel: UILabel!
    @IBOutlet weak var Backgroundview: UIView!
    @IBOutlet weak var EventtypeLabel: UILabel!
    @IBOutlet weak var Imageview: UIImageView!

    func configure(title: String, eventType: String, dateText: String, imageURL: String?) {
        EventnameLabel.text = title
        DateLabel.text = dateText
        EventtypeLabel.text = "  \(eventType)  "
        // Uses the async image extension
        Imageview.loadAsync(from: imageURL)
    }
}
