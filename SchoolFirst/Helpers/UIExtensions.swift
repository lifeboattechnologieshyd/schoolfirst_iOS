//
//  UIExtensions.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 21/06/25.
//

import UIKit
import ObjectiveC


extension UIViewController {
    func showAlert(msg: String){
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default) { action in
            }
            alert.addAction(action)
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
        shadowRadius: CGFloat = 4,
        shadowHeight: CGFloat = 3
    ) {
        layer.masksToBounds = false
        superview?.clipsToBounds = false
        
        // This offset pushes shadow only downward
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        
        // Create a shadow path only at the bottom
        let shadowRect = CGRect(
            x: 0,
            y: bounds.height - shadowHeight,
            width: bounds.width,
            height: shadowHeight
        )
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
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
import Photos

extension String {

    func downloadImage() {
        guard let url = URL(string: self) else { return }
        
        // Download image data
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Download error:", error.localizedDescription)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Invalid image data")
                return
            }
            
            // Save to Photos
            DispatchQueue.main.async {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized || status == .limited {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        print("✅ Image saved to gallery")
                    } else {
                        print("⚠️ Permission denied to save image")
                    }
                }
            }
        }.resume()
    }

    
    func isValidIndianMobile() -> Bool {
        let regex = "^[6-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        // Simple & reliable regex for most apps
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    
    
    func to12HourTime() -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm:ss"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "hh:mm a"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")

            guard let date = inputFormatter.date(from: self) else {
                return self
            }
            return outputFormatter.string(from: date)
        }
    
    /// converts yyyy-MM-dd type string into dd MMM, yyyy

    func fromyyyyMMddtoDDMMMYYYY() -> String {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           inputFormatter.locale = Locale(identifier: "en_US_POSIX")

           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "dd MMM, yyyy"
           outputFormatter.locale = Locale(identifier: "en_IN")  // or .current

           guard let date = inputFormatter.date(from: self) else {
               return self
           }
           return outputFormatter.string(from: date)
       }
    
    func fromyyyyMMddtoDDMMM() -> String {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           inputFormatter.locale = Locale(identifier: "en_US_POSIX")

           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "dd MMM"
           outputFormatter.locale = Locale(identifier: "en_IN")  // or .current

           guard let date = inputFormatter.date(from: self) else {
               return self
           }
           return outputFormatter.string(from: date)
       }
    
    /// converts yyyy-MM-dd type string into dd MM yyyy
    
    func fromyyyyMMddtoDDMMYYYY() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = inputFormatter.date(from: self) else {
            return self // fallback to original if parsing fails
        }
        return outputFormatter.string(from: date)
    }
    
    
    
    /// converts yyyy-dd-MM type string into dd MM yyyy
    
    func toDDMMYYYY() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-dd-MM"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = inputFormatter.date(from: self) else {
            return self // fallback to original if parsing fails
        }
        return outputFormatter.string(from: date)
    }
    
    /// converts yyyy-MM-dd type string into dd MMM yyyy
    func toddMMMyyyy() -> String{
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
        // ADD THIS NEW FUNCTION 👇
            func formatDate() -> String {
                let inputFormatter = DateFormatter()
                inputFormatter.locale = Locale(identifier: "en_US_POSIX")
                inputFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = inputFormatter.date(from: self) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "dd MMM yyyy"  // Output: "31 Dec 2025"
                    return outputFormatter.string(from: date)
                }
                
                return self
            }
        
        // MARK: - Extract YouTube Video ID (All URL formats)
        func extractYoutubeId() -> String? {
            
            // Pattern 1: https://youtu.be/VIDEO_ID
            if self.contains("youtu.be/") {
                let components = self.components(separatedBy: "youtu.be/")
                if components.count > 1 {
                    let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                    return videoID
                }
            }
            
            // Pattern 2: https://www.youtube.com/watch?v=VIDEO_ID
            if self.contains("youtube.com/watch") {
                if let url = URL(string: self),
                   let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                    for item in queryItems {
                        if item.name == "v", let value = item.value {
                            return value
                        }
                    }
                }
            }
            
            // Pattern 3: https://youtube.com/shorts/VIDEO_ID
            if self.contains("youtube.com/shorts") {
                if let url = URL(string: self) {
                    return url.lastPathComponent
                }
            }
            
            // Pattern 4: https://youtube.com/embed/VIDEO_ID
            if self.contains("youtube.com/embed/") {
                let components = self.components(separatedBy: "embed/")
                if components.count > 1 {
                    let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                    return videoID
                }
            }
            
            // Pattern 5: https://youtube.com/v/VIDEO_ID
            if self.contains("youtube.com/v/") {
                let components = self.components(separatedBy: "/v/")
                if components.count > 1 {
                    let videoID = components[1].components(separatedBy: "?").first ?? components[1]
                    return videoID
                }
            }
            
            return nil
        }
        
        // MARK:  Get YouTube Thumbnail URL
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
    
    
    func loadImage(url: String, placeHolderImage: String = "SchoolFirst") {
        guard let url = URL(string: url) else {
            self.image = UIImage(named: placeHolderImage)
            return
        }
        
        DispatchQueue.main.async {
            let size = self.bounds.size
            
            let finalSize = (size.width > 0 && size.height > 0)
            ? size
            : CGSize(width: UIScreen.main.bounds.width / 3,
                     height: UIScreen.main.bounds.width / 3)
            
            let processor = DownsamplingImageProcessor(size: finalSize)
            
            self.kf.indicatorType = .activity
            
            self.kf.setImage(
                with: url,
                placeholder: UIImage(named: placeHolderImage),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage,
                    .memoryCacheExpiration(.days(21)),
                    .diskCacheExpiration(.days(30))
                ]
            )
        }
    }
    
    
    /// as of now not using as this is downloading image if cell is being reused.
    func loadImage2(url: String, placeHolderImage: String = "SchoolFirst"){
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
        
//        let minute = 60
//        let hour = 60 * minute
//        let day = 24 * hour
//        let week = 7 * day
//        let month = 30 * day
        
        if secondsAgo < 60 {
            return "just now"
        } else if secondsAgo < 3600 {
            let minutes = secondsAgo / 60
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        } else if secondsAgo < 86400 {
            let hours = secondsAgo / 3600
            return hours == 1 ? "1 hr ago" : "\(hours) hrs ago"
        } else if secondsAgo < 604800 {
            let days = secondsAgo / 86400
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if secondsAgo < 2_592_000 {
            let weeks = secondsAgo / 604800
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if secondsAgo < 31_536_000 {
            let months = secondsAgo / 2_592_000
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else {
            let years = secondsAgo / 31_536_000
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
    }
    
    func toddMMYYYY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDateString = dateFormatter.string(from: self)
        return formattedDateString
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
    
    /// Set HTML string to label as attributed text.
    ///
    /// - Parameters:
    ///   - html: HTML string (may include <b>, <i>, <br>, <p>, <a>, <img> etc.)
    ///   - font: optional font to apply as a base (preserves bold/italic traits)
    ///   - color: optional color to apply as a base
    ///   - lineBreakMode: optional lineBreakMode (defaults to label's current)
    func setHTML(_ html: String,
                 font baseFont: UIFont? = nil,
                 color baseColor: UIColor? = nil,
                 lineBreakMode: NSLineBreakMode? = nil) {
        // Ensure UI work on main thread
        let apply: (NSAttributedString?) -> Void = { [weak self] attributed in
            guard let self = self else { return }
            if let lineBreak = lineBreakMode {
                self.lineBreakMode = lineBreak
            }
            if let attributed = attributed {
                self.numberOfLines = 0
                self.attributedText = attributed
            } else {
                // fallback to plain text if parsing fails
                self.text = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            }
        }
        
        if Thread.isMainThread == false {
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
                _ = self // capture self to silence unused warning in closure
            }
        }
        
        // Convert HTML -> Data
        guard let data = html.data(using: .utf8) else {
            apply(nil)
            return
        }
        
        // Read options
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Parse HTML into NSAttributedString
            let parsed: NSAttributedString?
            do {
                let raw = try NSMutableAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )
                // If a base font or color is provided, normalize fonts & colors while preserving traits
                if let baseFont = baseFont {
                    raw.beginEditing()
                    raw.enumerateAttribute(.font, in: NSRange(location: 0, length: raw.length), options: []) { value, range, _ in
                        if let currentFont = value as? UIFont {
                            // Preserve traits (bold/italic)
                            let traits = currentFont.fontDescriptor.symbolicTraits
                            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
                                let newFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                                raw.addAttribute(.font, value: newFont, range: range)
                            } else {
                                raw.addAttribute(.font, value: baseFont, range: range)
                            }
                        } else {
                            raw.addAttribute(.font, value: baseFont, range: range)
                        }
                    }
                    raw.endEditing()
                }
                
                if let baseColor = baseColor {
                    raw.addAttribute(.foregroundColor, value: baseColor, range: NSRange(location: 0, length: raw.length))
                }
                
                parsed = raw
            } catch {
                parsed = nil
            }
            
            // Apply on main thread
            DispatchQueue.main.async {
                apply(parsed)
            }
        }
    }
    
    
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
    func setTyping(text: String, charInterval: TimeInterval = 0.06) {
        self.text = ""
        var index = 0
        let characters = Array(text)
        
        Timer.scheduledTimer(withTimeInterval: charInterval, repeats: true) { timer in
            if index < characters.count {
                self.text?.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func animateTyping(text: String, interval: TimeInterval = 0.06, completion: (() -> Void)? = nil) {
        self.text = ""
        var index = 0
        let characters = Array(text)

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if index < characters.count {
                self.text?.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
                completion?()
            }
        }
    }
    
    
    
}

extension UITextView {
    /// Converts HTML string into formatted attributed text and displays in the UITextView
    ///
    /// - Parameters:
    ///   - html: The HTML string you want to render
    ///   - font: Optional base font (applied while preserving HTML styles)
    ///   - color: Optional base color (default = label color)
    func setHTML(_ html: String,
                 font: UIFont? = .lexend(.regular, size: 16),
                 color: UIColor? = .black) {
        
        guard let data = html.data(using: .utf8) else {
            self.text = html
            return
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            let attributed: NSMutableAttributedString?
            
            do {
                let raw = try NSMutableAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )
                attributed = raw
            } catch {
                attributed = nil
            }
            
            DispatchQueue.main.async {
                self.isEditable = false
                self.isScrollEnabled = true
                self.isSelectable = true
                self.dataDetectorTypes = [.link]
                self.attributedText = attributed
                self.textAlignment = .natural
            }
        }
    }
}

extension NSAttributedString {
    /// Converts HTML string into an attributed string with custom font family applied
    static func fromHTML(_ html: String,
                         regularFont: UIFont,
                         boldFont: UIFont? = nil,
                         italicFont: UIFont? = nil,
                         textColor: UIColor = .label) -> NSAttributedString? {
        
        // Step 1: convert to data
        guard let data = html.data(using: .utf8) else { return nil }
        
        // Step 2: parse HTML to attributed string
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let raw = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            
            // Step 3: Replace fonts with your Lexend variants
            raw.enumerateAttribute(.font, in: NSRange(location: 0, length: raw.length)) { value, range, _ in
                guard let oldFont = value as? UIFont else { return }
                let traits = oldFont.fontDescriptor.symbolicTraits
                
                if traits.contains(.traitBold), let boldFont = boldFont {
                    raw.addAttribute(.font, value: boldFont, range: range)
                } else if traits.contains(.traitItalic), let italicFont = italicFont {
                    raw.addAttribute(.font, value: italicFont, range: range)
                } else {
                    raw.addAttribute(.font, value: regularFont, range: range)
                }
            }
            
            // Step 4: Ensure correct text color
            raw.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: raw.length))
            
            return raw
            
        } catch {
            print("❌ HTML parse error:", error)
            return nil
        }
    }
}




class PillLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                      height: size.height + contentInsets.top + contentInsets.bottom)
    }
}
extension UIButton {
    func loadImage(url: String, placeholder: UIImage? = nil) {
        // Set placeholder if provided
        if let placeholder = placeholder {
            self.setImage(placeholder, for: .normal)
        } else {
            self.setImage(nil, for: .normal)
        }
        
        guard let imageUrl = URL(string: url) else { return }

        // Fetch image asynchronously
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.setImage(image, for: .normal)
            }
        }.resume()
    }
}
import UIKit

extension UIView {
    /// Recursively find a superview of the specified type.
    func superview<T: UIView>(of type: T.Type) -> T? {
        return (superview as? T) ?? superview?.superview(of: type)
    }
}
extension UIView {
    func addCardShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
    }
}
extension TimeInterval {
    func toMonthYear() -> String {
        let date = Date(timeIntervalSince1970: self / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
}

import UIKit

extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIView {
    
    func applyDropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false
    }
    
    func addTopShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowRadius = 3
        layer.masksToBounds = false
    }
    
    func addBottomShadow(shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 3, shadowHeight: CGFloat = 4) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    
}

struct PasswordValidator {
    
    static func validate(password: String, confirmPassword: String) -> String? {
        // 1. Empty check
        guard !password.isEmpty else { return "Password cannot be empty" }
        guard !confirmPassword.isEmpty else { return "Confirm password cannot be empty" }
        
        // 2. Length check
        guard password.count >= 8 else { return "Password must be at least 8 characters long" }
        
        // 3. Strong password
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$&*]).{8,}$"
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) {
            return "Password must contain uppercase, lowercase, number, and special character"
        }
        
        // 4. Match check
        guard password == confirmPassword else { return "Passwords do not match" }
        
        // ✅ All good
        return nil
    }
}


extension UIView {

    func addFourSideShadow(
        color: UIColor = .black,
        opacity: Float = 0.25,
        radius: CGFloat = 6,
        offset: CGSize = .zero
    ) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
}
extension UILabel {

    func applyOutlineWithBottomShadow(
        textColor: UIColor,
        outlineColor: UIColor = .white,
        outlineWidth: CGFloat = 3,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.35,
        shadowOffset: CGSize = CGSize(width: 1, height: 1),
        shadowRadius: CGFloat = 1
    ) {
        guard let text = self.text else { return }

        // 1️⃣ Outline + Fill
        let attributes: [NSAttributedString.Key: Any] = [
            .strokeColor: outlineColor,
            .foregroundColor: textColor,
            .strokeWidth: -outlineWidth
        ]

        self.attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )

        // 2️⃣ Bottom Shadow
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
// Key for associated object
private var loaderKey: UInt8 = 0

extension UIViewController {

    private var loaderView: UIView? {
        get {
            return objc_getAssociatedObject(self, &loaderKey) as? UIView
        }
        set {
            objc_setAssociatedObject(
                self,
                &loaderKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func showLoader() {
        DispatchQueue.main.async {
            // Don't add if already showing
            if self.loaderView != nil { return }

            // Create background view
            let loader = UIView(frame: self.view.bounds)
            loader.backgroundColor = UIColor.black.withAlphaComponent(0.4)

            // Create spinner
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.center = loader.center
            spinner.color = .white
            spinner.startAnimating()

            // Add to view
            loader.addSubview(spinner)
            self.view.addSubview(loader)
            self.view.bringSubviewToFront(loader)

            // Store reference
            self.loaderView = loader
        }
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView?.removeFromSuperview()
            self.loaderView = nil
        }
    }
}
