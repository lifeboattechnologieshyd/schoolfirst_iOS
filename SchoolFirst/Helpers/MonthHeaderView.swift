//
//  MonthHeaderView.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 06/09/25.
//

import UIKit

class MonthHeaderView: UIView {
    @IBOutlet weak var btnLeft: UIButton!
    
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var currentDate = Date() {
        didSet {
            updateTitle()
        }
    }
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MonthHeaderView", owner: self, options: nil)
        guard let contentView = subviews.first else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        setupUI()
    }
    
    private func setupUI() {
       
        
        btnTitle.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btnTitle.setTitleColor(.black, for: .normal)
        
        btnLeft.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        btnNext.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        btnTitle.addTarget(self, action: #selector(titleTapped), for: .touchUpInside)
        
        updateTitle()
    }
    
    private func updateTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let title = formatter.string(from: currentDate)
        btnTitle.setTitle(title + " ⌄", for: .normal)
    }
    
    @objc private func prevTapped() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        onDateChanged?(currentDate)
    }
    
    @objc private func nextTapped() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        onDateChanged?(currentDate)
    }
    
    @objc private func titleTapped() {
        // Show UIDatePicker in a popup
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .inline
            datePicker.date = currentDate
            
            let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
            
            alert.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
                datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
                datePicker.heightAnchor.constraint(equalToConstant: 300)
            ])
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                self.currentDate = datePicker.date
                self.onDateChanged?(self.currentDate)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            vc.present(alert, animated: true)
        }
    }
}
