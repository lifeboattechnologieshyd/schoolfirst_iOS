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
    
    @IBOutlet weak var backButton: UIButton!
    
    var passedImageURL: String?    // <- received from previous VC
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        loadImage()
    }
    
    @IBAction func onClickDownload(_ sender: UIButton) {
        passedImageURL?.downloadImage()
    }
    func loadImage() {
        guard let urlString = passedImageURL,
              let url = URL(string: urlString) else {
            return
        }
        
        // Load image from URL
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let d = data, let img = UIImage(data: d) {
                DispatchQueue.main.async {
                    self.imageView.image = img
                    self.imageView.contentMode = .scaleAspectFit
                }
            }
        }.resume()
    }
    
    // ZOOM SUPPORT
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        print("share button clicked")
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
