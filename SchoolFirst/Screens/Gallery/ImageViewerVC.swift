//
//  ImageViewerVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 13/11/25.
//

import UIKit

class ImageViewerVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var passedImageURL: String?
    var imageHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
         imageView.translatesAutoresizingMaskIntoConstraints = false
        
        loadImage()
    }
    
     func loadImage() {
        guard let urlString = passedImageURL,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.imageView.image = img
                
                // Remove previous dynamic height constraint if exists
                self.imageHeightConstraint?.isActive = false
                
                // Calculate height based on aspect ratio
                let screenWidth = self.view.frame.width
                let newHeight = screenWidth * (img.size.height / img.size.width)
                
                // Create and activate new height constraint
                self.imageHeightConstraint = self.imageView.heightAnchor
                    .constraint(equalToConstant: newHeight)
                self.imageHeightConstraint?.isActive = true
                
                self.view.layoutIfNeeded()
            }
        }.resume()
    }
    
     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Center image while zooming
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageView = self.imageView!
        
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
