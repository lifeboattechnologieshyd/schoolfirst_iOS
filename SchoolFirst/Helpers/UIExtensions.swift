//
//  UIExtensions.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/06/25.
//

import UIKit


extension UIViewController {
    func showAlert(msg: String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { action in
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func shareApp(from viewController: UIViewController) {
        let appLink = "https://apps.apple.com/us/app/schoolfirst/id6744517880"
        let message = "Hey! if you are looking for a smarter way to stay involved with school and learning, try School First. Totally worth a download!        "
        let items: [Any] = [message, appLink]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                        y: viewController.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func handleLogout() {
        let defaults = UserDefaults.standard
        if let appDomain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: appDomain)
            defaults.synchronize()
        }
        UserDefaults.standard.removeObject(forKey: "ACCESSTOKEN")
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = story.instantiateViewController(identifier: "navbar") as? UINavigationController
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                print("Unable to find a valid window")
                return
            }
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
    
    func uploadFile(
        image : UIImage,
        url: String,
        fileName: String,
        additionalParams: [String: String],
        accessToken : String
    ) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            FileUploader.uploadFile(
                urlString: url,
                fileData: imageData,
                fileName: fileName,
                mimeType: "image/jpeg",
                additionalParams: additionalParams,
                headers: ["Authorization": "Bearer \(accessToken)"]
            ) { result in
                switch result {
                case .success(let responseData):
                    print("✅ Uploaded successfully:\(responseData.data)")
                case .failure(let error):
                    print("❌ Upload failed:", error)
                }
            }
        }
    }
}


@IBDesignable
extension UIView {
    
    func addBottomShadow(
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.2,
        shadowRadius: CGFloat = 6,
        shadowHeight: CGFloat = 6
    ) {
        // Very important: allow shadow outside bounds
        self.layer.masksToBounds = false
        self.superview?.clipsToBounds = false
        
        // Define a rectangle only at the bottom of the view
        let shadowRect = CGRect(
            x: 0,
            y: self.bounds.height - shadowHeight,
            width: self.bounds.width,
            height: shadowHeight
        )
        let path = UIBezierPath(rect: shadowRect)
        
        // Apply shadow properties
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = .zero
        layer.shadowPath = path.cgPath
    }
    
    func applyCardShadow(
        cornerRadius: CGFloat = 8,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 3,
        shadowOffset: CGSize = CGSize(width: 0, height: 2)
    ){
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        self.backgroundColor = .white
        
    }
    
    func homeScreenCardLook (
        cornerRadius: CGFloat = 8,
        shadowColor: UIColor = UIColor.black.withAlphaComponent(0.3),
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 12,
        shadowOffset: CGSize = CGSize(width: 0, height: 8)
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        layer.borderWidth = 0.5
    }
    
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}

enum LexendFont: String {
    case regular = "Lexend-Regular"
    case bold = "Lexend-Bold"
    case light = "Lexend-Light"
    case medium = "Lexend-Medium"
    case semiBold = "Lexend-SemiBold"
    case extraLight = "Lexend-ExtraLight"
    case thin = "Lexend-Thin"
    case black = "Lexend-Black"
}

extension UIFont {
    static func lexend(_ style: LexendFont, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension String {
    func isValidIndianMobile() -> Bool {
        let regex = "^[6-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// converts yyyy-MM-dd type string into dd MMM yyyy
    func convertTo() -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            return self // fallback if parsing fails
        }
    }
    
    func getTimeAgo() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        if let sampleDate = formatter.date(from: self) {
            return sampleDate.timeAgo()
        }else{
            return "recent"
        }
    }
    func extractYoutubeId() -> String? {
        if let url = URL(string: self) {
            if url.absoluteString.contains("youtube.com/shorts") {
                return url.lastPathComponent
            }
        }
        return nil
    }
    func youtubeThumbnailURL(quality: String = "hqdefault") -> String {
        "https://img.youtube.com/vi/\(self)/\(quality).jpg"
    }
    
}


import Kingfisher

struct RemoveAlphaProcessor: ImageProcessor {
    let identifier = "com.lifeboat.RemoveAlphaProcessor"
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard let cgImage = image.cgImage else { return image }
            let width = cgImage.width
            let height = cgImage.height
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
            
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            if let newCG = context?.makeImage() {
                return UIImage(cgImage: newCG)
            }
            return image
            
        case .data(_):
            return nil
        }
    }
}


extension UIImageView {
    
    func loadImage(url: String, placeHolderImage: String = "SchoolFirst"){
        let downsample = DownsamplingImageProcessor(size: self.bounds.size)
        let removeAlpha = RemoveAlphaProcessor()
        let combined = downsample |> removeAlpha
        
        let processor = DownsamplingImageProcessor(size: self.bounds.size)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(named: placeHolderImage),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("error loading image for \(error)")
                break
            }
        }
    }
}
extension Date {
    func timeAgo() -> String {
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo) sec ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) min ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hr ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) day ago"
        } else if secondsAgo < month {
            return "\(secondsAgo / week) week ago"
        } else {
            return "\(secondsAgo / month) month ago"
        }
    }
}
import UIKit

extension UIImage {
    /// Create a 1x1 image of a solid color
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UISegmentedControl {
    
    /// Apply custom style to a segmented control
    func applyCustomStyle(
        font: UIFont = .lexend(.light, size: 16),
        selectedFont: UIFont = .lexend(.semiBold, size: 16),
        textColor: UIColor = .primary,
        selectedTextColor: UIColor = .white,
        backgroundColor: UIColor = .white,
        selectedBackgroundColor: UIColor = .primary,
        cornerRadius: CGFloat = 20
    ) {
        
        setBackgroundImage(UIImage(color: backgroundColor), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage(color: selectedBackgroundColor), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage(color: selectedBackgroundColor), for: .highlighted, barMetrics: .default)
        
        // Divider (invisible)
        setDividerImage(UIImage(color: .clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        // Text attributes
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: selectedFont,
            .foregroundColor: selectedTextColor,
        ]
        setTitleTextAttributes(normalAttributes, for: .normal)
        setTitleTextAttributes(selectedAttributes, for: .selected)
        
        // Corner radius
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        layer.borderColor = UIColor.primary.cgColor
        layer.borderWidth = 1
    }
}


extension UIColor {
    convenience init?(hex: String) {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }
        
        guard cleanedHex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UILabel {
    func addPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.insertSubview(paddingView, belowSubview: self)
        
        NSLayoutConstraint.activate([
            paddingView.topAnchor.constraint(equalTo: self.topAnchor, constant: -top),
            paddingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -left),
            paddingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: right),
            paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
        ])
        paddingView.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
}
