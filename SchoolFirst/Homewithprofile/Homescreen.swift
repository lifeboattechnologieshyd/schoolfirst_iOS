//
//  Homescreen.swift
//  SchoolFirst
//

import UIKit

class Homescreen: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var ContainerView: UIView!
    
    // MARK: - MODULE DATA
    
    var modulesData: [[String: String]] = [
        
        [
            "title" : "Profile",
            "image" : "studentprofile"
        ],
        
        [
            "title" : "Bulletin",
            "image" : "bulletin"
        ],
        
        [
            "title" : "Homework",
            "image" : "homework"
        ],
        
        [
            "title" : "Fee Management",
            "image" : "feemanagement"
        ],
        
        [
            "title" : "Time Table",
            "image" : "time_table"
        ],
        
        [
            "title" : "Attendance",
            "image" : "attedence"
        ],
        
        [
            "title" : "Exams",
            "image" : "exams"
        ],
        
        [
            "title" : "Gallery",
            "image" : "gallery 1"
        ],
        
        [
            "title" : "Communicate",
            "image" : "communicate"
        ],
        
        [
            "title" : "Calendar",
            "image" : "calender"
        ],
        
        [
            "title" : "Remarks",
            "image" : "Remarks"
        ],
        
        [
            "title" : "Transport",
            "image" : "transport"
        ]
    ]
    
    // MARK: - CARD DATA
    
    var cardData: [[String: String]] = [
        
        [
            "title" : "HOMEWORK",
            "value" : "85%",
            "subtitle" : "35/30"
        ],
        
        [
            "title" : "ATTENDANCE",
            "value" : "92.5%",
            "subtitle" : "15/180 Absents"
        ],
        
        [
            "title" : "FEES",
            "value" : "Paid",
            "subtitle" : "No Dues"
        ],
        
        [
            "title" : "GRADE",
            "value" : "A+",
            "subtitle" : "Rank #2"
        ]
    ]
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionView.isScrollEnabled = true
        setupContainer()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createCards()
    }
}

// MARK: - COLLECTIONVIEW SETUP

extension Homescreen {
    
    private func setupCollectionView() {
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        CollectionView.backgroundColor = .clear
        
        CollectionView.register(
            UINib(
                nibName: "ModulesCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "ModulesCollectionViewCell"
        )
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        
        layout.minimumLineSpacing = 14
        
        layout.minimumInteritemSpacing = 12
        
        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0
        )
        
        layout.itemSize = CGSize(
            width: 100,
            height: 104
        )
        
        CollectionView.collectionViewLayout = layout
    }
}

// MARK: - COLLECTIONVIEW METHODS

extension Homescreen:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return modulesData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ModulesCollectionViewCell",
            for: indexPath
        ) as! ModulesCollectionViewCell
        
        let item = modulesData[indexPath.row]
        
        // TITLE
        
        cell.ModuleTitle.text = item["title"]
        
        // IMAGE
        
        cell.ImageView.image = UIImage(
            named: item["image"] ?? ""
        )
        
        // CELL DESIGN
        
        cell.view.backgroundColor = .white
        
        cell.view.layer.cornerRadius = 20
        
        cell.view.layer.cornerCurve = .continuous
        
        // SHADOW
        
        cell.layer.shadowColor = UIColor.black.cgColor
        
        cell.layer.shadowOpacity = 0.08
        
        cell.layer.shadowOffset = CGSize(
            width: 0,
            height: 2
        )
        
        cell.layer.shadowRadius = 8
        
        cell.layer.masksToBounds = false
        
        // IMAGE
        
        cell.ImageView.contentMode = .scaleAspectFit
        
        // TITLE
        
        cell.ModuleTitle.textAlignment = .center
        
        cell.ModuleTitle.numberOfLines = 2
        
        cell.ModuleTitle.font = UIFont.systemFont(
            ofSize: 14,
            weight: .semibold
        )
        
        cell.ModuleTitle.textColor = UIColor.darkGray
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.frame.width - 24) / 3
        return CGSize(width: width, height: 104)
    }
}

// MARK: - UI

extension Homescreen {
    
    private func setupContainer() {
        
        ContainerView.backgroundColor = UIColor(
            red: 0/255,
            green: 92/255,
            blue: 170/255,
            alpha: 1
        )
        
        ContainerView.layer.cornerRadius = 20
        
        ContainerView.clipsToBounds = true
    }
    
    private func createCards() {
        
        // REMOVE OLD VIEWS
        
        ContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        // CARD SETTINGS
        
        let horizontalPadding: CGFloat = 14
        
        let verticalPadding: CGFloat = 12
        
        let spacing: CGFloat = 12
        
        let cardWidth =
        (ContainerView.frame.width - (horizontalPadding * 2) - spacing) / 2
        
        let cardHeight: CGFloat = 85
        
        // TOTAL CONTENT HEIGHT
        
        let totalCardsHeight =
        (cardHeight * 2) + spacing
        
        // CENTER VERTICALLY
        
        let startY =
        (ContainerView.frame.height - totalCardsHeight) / 2
        
        for (index, item) in cardData.enumerated() {
            
            let row = index / 2
            
            let column = index % 2
            
            let x =
            horizontalPadding +
            CGFloat(column) * (cardWidth + spacing)
            
            let y =
            startY +
            CGFloat(row) * (cardHeight + spacing)
            
            // CARD VIEW
            
            let cardView = UIView(frame: CGRect(
                x: x,
                y: y,
                width: cardWidth,
                height: cardHeight
            ))
            
            cardView.backgroundColor = UIColor(
                red: 50/255,
                green: 115/255,
                blue: 185/255,
                alpha: 1
            )
            
            cardView.layer.cornerRadius = 18
            
            cardView.layer.borderWidth = 1
            
            cardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor
            
            ContainerView.addSubview(cardView)
            
            // TITLE LABEL
            
            let titleLabel = UILabel(frame: CGRect(
                x: 14,
                y: 10,
                width: cardWidth - 28,
                height: 15
            ))
            
            titleLabel.text = item["title"]
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            titleLabel.textColor = UIColor(
                white: 0.85,
                alpha: 1
            )
            
            cardView.addSubview(titleLabel)
            
            // VALUE LABEL
            
            let valueLabel = UILabel()
            
            valueLabel.font = UIFont.boldSystemFont(ofSize: 24)
            
            valueLabel.textColor = .white
            
            // FEES CARD
            
            if item["title"] == "FEES" {
                
                let greenDot = UIView(frame: CGRect(
                    x: 14,
                    y: 40,
                    width: 14,
                    height: 14
                ))
                
                greenDot.backgroundColor = .systemGreen
                
                greenDot.layer.cornerRadius = 7
                
                cardView.addSubview(greenDot)
                
                valueLabel.frame = CGRect(
                    x: 36,
                    y: 28,
                    width: cardWidth - 40,
                    height: 30
                )
                
                valueLabel.text = item["value"]
                
            } else {
                
                valueLabel.frame = CGRect(
                    x: 14,
                    y: 32,
                    width: cardWidth - 28,
                    height: 26
                )
                
                valueLabel.text = item["value"]
            }
            
            cardView.addSubview(valueLabel)
            
            // SUBTITLE
            
            let subtitleLabel = UILabel(frame: CGRect(
                x: 14,
                y: 62,
                width: cardWidth - 28,
                height: 15
            ))
            
            subtitleLabel.text = item["subtitle"]
            
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            
            subtitleLabel.textColor = .yellow
            
            cardView.addSubview(subtitleLabel)
        }
    }
}
