//
//   UIImageView+Extension.swift
//  
//
//  Created by vamshi krishna on 11/10/26.
//

//
//  UIImageView+Extension.swift
//  SchoolFirst
//

import UIKit

extension UIImageView {
    func loadAsync(from urlString: String?, placeholder: UIImage? = UIImage(systemName: "photo")) {
        self.image = placeholder
        self.tintColor = .lightGray
        
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let downloadedImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.image = downloadedImage
            }
        }.resume()
    }
}
