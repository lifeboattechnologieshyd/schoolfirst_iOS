//
//  VocabBeeResultPopup.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 01/11/25.
//

import UIKit

class VocabBeeResultPopup: UIView {
    @IBOutlet weak var cardView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("VocabBeeResultPopup", owner: self, options: nil)
        guard let contentView = subviews.first else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    static func instantiate() -> VocabBeeResultPopup {
        return Bundle.main.loadNibNamed("VocabBeeResultPopup", owner: nil, options: nil)?.first as! VocabBeeResultPopup
    }
    func show(on parent: UIView) {
        self.frame = parent.bounds
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        parent.addSubview(self)
        self.alpha = 0
        self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }
}
