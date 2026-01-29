//
//  ImageViewerVC.swift
//  SchoolFirst
//
//  Created by Lifeboat on 13/11/25.
//

import UIKit

class ImageViewerVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var passedImageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        scrollView.backgroundColor = .white
        imageView.backgroundColor = .white
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        loadImage()
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        guard let image = imageView.image else {
            print("No image to share")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        
        present(activityVC, animated: true)
    }
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Error", message: "Image could not be saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "Image saved to Photos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func loadImage() {
        showLoader()
        guard let urlString = passedImageURL,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let d = data, let img = UIImage(data: d) else { return }
            
            DispatchQueue.main.async {
                self.hideLoader()
                self.imageView.image = img
                self.imageView.contentMode = .scaleAspectFit
                
                let screenWidth = self.view.frame.width
                let newHeight = screenWidth * (img.size.height / img.size.width)
                
                self.imageView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: screenWidth,
                    height: newHeight
                )
                
                self.scrollView.contentSize = self.imageView.frame.size
                self.centerImage()
            }
        }.resume()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

