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
    var items = [FeelItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        
        colVw.delegate = self
        colVw.dataSource = self
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeelsCollectionViewCell")
        self.getEdutainment()
        
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell", for: indexPath) as! FeelsCollectionViewCell
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        if let url = self.items[indexPath.row].thumbnailImage {
            cell.imgVw.loadImage(url: url)
        }else{
            if let urlstring = "\(self.items[indexPath.row].youtubeVideo!)".extractYoutubeId() {
                cell.imgVw.loadImage(url: urlstring.youtubeThumbnailURL())
            }
        }
        cell.playClicked = { index in
            self.navigateToPlayer(index: index)
        }
        cell.lblName.text = self.items[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-8)/2
        return CGSize(width: width, height: 284)
    }
    
    func navigateToPlayer(index: Int){
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToPlayer(index: indexPath.row)
    }
    
    
    func getEdutainment() {
        NetworkManager.shared.request(urlString: API.EDUTAIN_FEEL, method: .GET) { [weak self] (result: Result<APIResponse<[FeelItem]>, NetworkError>) in
            guard let self = self else { return }
            switch result {
            case .success(let info):
                if info.success {
                    if let data = info.data {
                        self.items = data
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
    