//
//  EdStoreViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 23/10/25.
//

import UIKit

class EdStoreViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var inspiroLbl: UILabel!
    @IBOutlet weak var topbarVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var products: [Product] = []
    var currentPage = 1
    var isLoading = false
    var totalProducts = 0
    let pageSize = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.register(UINib(nibName: "EdStoreTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "EdStoreTableViewCell")
        
        tblVw.dataSource = self
        tblVw.delegate = self
        
        topbarVw.addBottomShadow()
        fetchProducts()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 120 {
            // Only fetch if more products exist
            if !isLoading && products.count < totalProducts {
                fetchProducts()
            }
        }
    }
    
    private func setupTopbarShadow() {
        topbarVw.layer.shadowColor = UIColor.black.cgColor
        topbarVw.layer.shadowOpacity = 0.15
        topbarVw.layer.shadowOffset = CGSize(width: 0, height: 3)
        topbarVw.layer.shadowRadius = 5
        topbarVw.layer.masksToBounds = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchProducts() {
        guard !isLoading else { return }
        isLoading = true

        NetworkManager.shared.request(
            urlString: API.ONLINE_STORE_PRODUCTS,
            method: .GET,
            parameters: [
                "page": currentPage,
                "limit": pageSize
            ]
        ) { [weak self] (result: Result<APIResponse<[Product]>, NetworkError>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    // Update total products
                    self.totalProducts = response.total ?? 0
                    
                    // Append new products
                    if let newProducts = response.data, !newProducts.isEmpty {
                        self.products.append(contentsOf: newProducts)
                        self.tblVw.reloadData()
                        self.currentPage += 1
                    }

                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
}

extension EdStoreViewController: UITableViewDataSource, UITableViewDelegate, EdStoreCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EdStoreTableViewCell",
            for: indexPath
        ) as! EdStoreTableViewCell
        
        let product = products[indexPath.row]
        cell.delegate = self
        
        cell.titleLbl.text = product.itemName
        cell.priceLbl.text = "₹\(product.finalPrice)"
        cell.discountLbl.text = product.discountTag
        
        if let discountTag = product.discountTag {
            cell.discountLbl?.text = discountTag.components(separatedBy: "-").first
        } else {
            cell.discountLbl?.text = "0% off"
        }
       // cell.discountLbl.text = product.highlights?.joined(separator: ", ") ?? ""

        
        if let url = URL(string: product.thumbnailImage) {
            cell.imgVw.loadImage(from: url)
        } else {
            cell.imgVw.image = UIImage(named: "thumbnailImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 246
    }
    
    // EdStoreCellDelegate method
    func didTapImage(in cell: EdStoreTableViewCell) {
        guard let indexPath = tblVw.indexPath(for: cell) else { return }
        let product = products[indexPath.row]
        
        let storyboard = UIStoryboard(name: "EdStore", bundle: nil)
        if let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckOutViewController") as? CheckOutViewController {
            checkoutVC.selectedProduct = product
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }
    }
}
   

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
}
