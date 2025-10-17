//
//  FeelsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

 
class FeelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
   
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var feelsLbl: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var topVw: UIView!
    
    
    private var items: [FeelItem] = [
        
    ]

    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colVw.delegate = self
        colVw.dataSource = self
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeelsCollectionViewCell")
        
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
        }
        
      
         self.getEdutainment()
    }
   
    
    // MARK: - Collection View DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell", for: indexPath) as! FeelsCollectionViewCell
        
        let firstIndex = indexPath.row * 2
        let secondIndex = firstIndex + 1
        
       
        
        
               
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = width / 2
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Button Actions
    @objc func likeTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < items.count else { return }
        items[index].likes += 1
        colVw.reloadData()
    }
    
    @objc func playTapped(_ sender: UIButton) {
        let index = sender.tag
        print("Play tapped on item at index \(index)")
    }
    
    // MARK: - API Method
    func getEdutainment() {
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEEL, method: .GET) { [weak self] (result: Result<APIResponse<[Feed]>, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.apiFeed = data
                    }
                    DispatchQueue.main.async {
                        self.colVw.reloadData()
                    }
                } else {
                    self.showAlert(msg: info.description)
                }
            case .failure(let error):
                self.showAlert(msg: error.localizedDescription)
            }
        }
    }
    
}
