import UIKit
import Photos

class FullimageVC: UIViewController {

    var items: [GalleryItem] = []
    var currentIndex: Int = 0
    var album: GalleryAlbum?

    // Backward compatibility
    var imageName: String = "Media"
    var albumTitle: String = ""
    var selectedIndex: Int = 0

    private let topBarView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let bottomInfoContainer = UIView()
    private let bottomGradientLayer = CAGradientLayer()
    private let imageTitleLabel = UILabel()
    private let imageDescriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupGestures()
        loadCurrentImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomGradientLayer.frame = bottomInfoContainer.bounds
    }

    private func setupUI() {
        // Top Bar
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        // Back Button
        let backImage = UIImage(named: "Whitebackbutton")
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.contentHorizontalAlignment = .leading
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(backButton)


        // Title Label (Album Title)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(titleLabel)

        // Subtitle Label (Count)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(subtitleLabel)

        // Scroll View for zoom
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Image View
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)

        // Activity Indicator
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        // Bottom Info Container
        bottomInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomInfoContainer)

        // Bottom Gradient
        bottomGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.92).cgColor
        ]
        bottomGradientLayer.locations = [0.0, 1.0]
        bottomInfoContainer.layer.addSublayer(bottomGradientLayer)

        // Image Title Label
        imageTitleLabel.textColor = .white
        imageTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        imageTitleLabel.numberOfLines = 2
        imageTitleLabel.lineBreakMode = .byTruncatingTail
        imageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(imageTitleLabel)

        // Image Description Label
        imageDescriptionLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        imageDescriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        imageDescriptionLabel.numberOfLines = 3
        imageDescriptionLabel.lineBreakMode = .byTruncatingTail
        imageDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(imageDescriptionLabel)

        // Date Label
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.numberOfLines = 1
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(dateLabel)

        // Save Button (UPDATED TO MATCH FIGMA)
        saveButton.setTitle(" Save", for: .normal)
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        saveButton.setImage(UIImage(systemName: "arrow.down.to.line", withConfiguration: iconConfig), for: .normal)
        saveButton.tintColor = .white
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        saveButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        saveButton.layer.cornerRadius = 14 // Pill shape
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        saveButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(saveButton)

        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBarView.trailingAnchor, constant: -12),
            titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            bottomInfoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomInfoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomInfoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageTitleLabel.topAnchor.constraint(equalTo: bottomInfoContainer.topAnchor, constant: 44),
            imageTitleLabel.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor, constant: 16),
            imageTitleLabel.trailingAnchor.constraint(equalTo: bottomInfoContainer.trailingAnchor, constant: -16),

            imageDescriptionLabel.topAnchor.constraint(equalTo: imageTitleLabel.bottomAnchor, constant: 6),
            imageDescriptionLabel.leadingAnchor.constraint(equalTo: imageTitleLabel.leadingAnchor),
            imageDescriptionLabel.trailingAnchor.constraint(equalTo: imageTitleLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: imageDescriptionLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: imageTitleLabel.leadingAnchor),
            // UPDATED CONSTRAINT: using lessThanOrEqualTo prevents the button from stretching
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: saveButton.leadingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: bottomInfoContainer.safeAreaLayoutGuide.bottomAnchor, constant: -14),

            saveButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: bottomInfoContainer.trailingAnchor, constant: -16),
            // UPDATED CONSTRAINTS: Height modified for pill shape, width added to maintain compact size
            saveButton.heightAnchor.constraint(equalToConstant: 28),
            saveButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75)
        ])

        view.bringSubviewToFront(topBarView)
        view.bringSubviewToFront(bottomInfoContainer)
    }

    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapZoom))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    private func loadCurrentImage() {
        if items.isEmpty {
            let item = GalleryItem(id: UUID().uuidString, url: imageName, type: .image, order: 0, caption: nil)
            items = [item]
            currentIndex = max(0, selectedIndex)
        }

        guard currentIndex >= 0 && currentIndex < items.count else { return }

        let currentItem = items[currentIndex]
        let imageURLString = currentItem.url

        // Top Bar
        titleLabel.text = album?.title ?? albumTitle

        let totalCount = items.count
        let currentCount = currentIndex + 1
        subtitleLabel.text = "\(currentCount) / \(totalCount)"

        // Bottom Info
        let imageTitle = currentItem.caption?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let imageTitle = imageTitle, !imageTitle.isEmpty {
            imageTitleLabel.text = imageTitle
            imageTitleLabel.isHidden = false
        } else {
            imageTitleLabel.text = album?.title ?? ""
            imageTitleLabel.isHidden = imageTitleLabel.text?.isEmpty == true
        }

        let descriptionText = album?.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let descriptionText = descriptionText, !descriptionText.isEmpty {
            imageDescriptionLabel.text = descriptionText
            imageDescriptionLabel.isHidden = false
        } else {
            imageDescriptionLabel.isHidden = true
        }

        dateLabel.text = album?.formattedEventDate ?? ""

        // Save Button Visibility
        saveButton.isHidden = !(album?.allowDownloads ?? false)

        // Reset Zoom
        scrollView.setZoomScale(1.0, animated: false)

        // Load Image
        activityIndicator.startAnimating()
        imageView.image = nil

        if let url = URL(string: imageURLString), !imageURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if let data = data, error == nil, let img = UIImage(data: data) {
                        self?.imageView.image = img
                    } else {
                        self?.imageView.image = UIImage(named: "Media")
                    }
                }
            }.resume()
        } else {
            activityIndicator.stopAnimating()
            imageView.image = UIImage(named: "Media")
        }
    }

    @objc private func swipeLeft() {
        guard currentIndex < items.count - 1 else { return }
        currentIndex += 1
        loadCurrentImage()
    }

    @objc private func swipeRight() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        loadCurrentImage()
    }

    @objc private func doubleTapZoom() {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
            let zoomRect = CGRect(x: center.x - 50, y: center.y - 50, width: 100, height: 100)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }

    @objc private func closeTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func downloadTapped() {
        guard let image = imageView.image else { return }

        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    self?.showAlert(title: "Permission Denied", message: "Please allow access to Photos to save this image.")
                }
            }
        }
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
        } else {
            showAlert(title: "Saved", message: "Image saved to Photos successfully.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension FullimageVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    private func centerImage() {
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        imageView.frame = frameToCenter
    }
}
