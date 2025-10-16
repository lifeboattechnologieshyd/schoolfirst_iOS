//
//  MainTabBarController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 05/09/25.
//

import UIKit
import Kingfisher

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTabBarIcons()
        // Do any additional setup after loading the view.
    }
    func updateTabBarIcons()  {
        guard let url = UserManager.shared.user?.schools.first?.smallLogo else { return
        }
        Task {
            
            if let tabBarItems = tabBar.items {
                let url = URL(string: url)!
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: 28, height: 28), mode: .aspectFit)

                do {
                    let result = try await KingfisherManager.shared.retrieveImage(with: url, options: [.processor(processor)])
                    let image = result.image.withRenderingMode(.alwaysOriginal)
                    tabBarItems[2].image = image
                    tabBarItems[2].selectedImage = image
                } catch {
                    print("❌ Failed to load image: \(error)")
                }
            }
        }
    }

  

}
