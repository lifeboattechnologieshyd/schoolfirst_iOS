//
//  VedioplayerviewVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 11/10/26.
//

import UIKit
import AVFoundation
import AVKit

class VedioplayerviewVC: UIViewController {

    // MARK: - Incoming Data
    var videoURLString: String = ""
    var videoTitle: String = ""
    var videoDescription: String = ""
    var videoDate: String = ""
    var videoDuration: String = ""
    var albumTitle: String = ""
    var subtitleText: String = ""          // e.g. "Finale performance · 4 of 10 videos"
    var items: [GalleryItem] = []
    var currentIndex: Int = 0
    var album: GalleryAlbum?

    // MARK: - UI Elements
    private let topBarView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    private let videoContainerView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?

    private let centerPlayButton = UIButton(type: .system)
    private let controlsContainer = UIView()
    private let playPauseButton = UIButton(type: .system)
    private let volumeButton = UIButton(type: .system)
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let progressSlider = UISlider()
    private let fullscreenButton = UIButton(type: .system)

    private let bottomInfoContainer = UIView()
    private let bottomGradientLayer = CAGradientLayer()
    private let infoTitleLabel = UILabel()
    private let infoDescriptionLabel = UILabel()
    private let dateIcon = UIImageView()
    private let dateLabel = UILabel()
    private let durationIcon = UIImageView()
    private let durationInfoLabel = UILabel()
    private let hdBadge = UILabel()

    private var isPlaying = false
    private var isControlsVisible = true
    private var hideControlsWorkItem: DispatchWorkItem?
    private var timeObserver: Any?
    private var isSeeking = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupGestures()
        loadVideo()
        setupPlayerObservers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
        bottomGradientLayer.frame = bottomInfoContainer.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        removeTimeObserver()
    }

    deinit {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
    private func setupUI() {
        // ── Top Bar ──
        topBarView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(backButton)

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(titleLabel)

        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(subtitleLabel)

        moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        moreButton.tintColor = .white
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(moreButton)

        // ── Video Container ──
        videoContainerView.backgroundColor = .black
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoContainerView)

        // Center Play Button
        let playConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        centerPlayButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: .normal)
        centerPlayButton.tintColor = .white
        centerPlayButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        centerPlayButton.layer.cornerRadius = 36
        centerPlayButton.clipsToBounds = true
        centerPlayButton.addTarget(self, action: #selector(centerPlayTapped), for: .touchUpInside)
        centerPlayButton.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.addSubview(centerPlayButton)

        // ── Controls Bar (over video) ──
        controlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.addSubview(controlsContainer)

        playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(playPauseButton)

        volumeButton.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)), for: .normal)
        volumeButton.tintColor = .white
        volumeButton.addTarget(self, action: #selector(volumeTapped), for: .touchUpInside)
        volumeButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(volumeButton)

        currentTimeLabel.text = "00:00"
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(currentTimeLabel)

        durationLabel.text = "00:00"
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(durationLabel)

        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.value = 0
        progressSlider.minimumTrackTintColor = .white
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressSlider.thumbTintColor = .white
        // Smaller thumb
        let thumbSize = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(thumbSize, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: thumbSize)).fill()
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        progressSlider.setThumbImage(thumbImage, for: .normal)
        progressSlider.setThumbImage(thumbImage, for: .highlighted)
        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(progressSlider)

        fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)), for: .normal)
        fullscreenButton.tintColor = .white
        fullscreenButton.addTarget(self, action: #selector(fullscreenTapped), for: .touchUpInside)
        fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.addSubview(fullscreenButton)

        // ── Bottom Info ──
        bottomInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomInfoContainer)

        bottomGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.95).cgColor
        ]
        bottomGradientLayer.locations = [0.0, 0.35]
        bottomInfoContainer.layer.addSublayer(bottomGradientLayer)

        infoTitleLabel.textColor = .white
        infoTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        infoTitleLabel.numberOfLines = 2
        infoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(infoTitleLabel)

        infoDescriptionLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        infoDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        infoDescriptionLabel.numberOfLines = 3
        infoDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(infoDescriptionLabel)

        dateIcon.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        dateIcon.tintColor = UIColor.white.withAlphaComponent(0.7)
        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(dateIcon)

        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(dateLabel)

        durationIcon.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        durationIcon.tintColor = UIColor.white.withAlphaComponent(0.7)
        durationIcon.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(durationIcon)

        durationInfoLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        durationInfoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        durationInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(durationInfoLabel)

        hdBadge.text = "HD"
        hdBadge.textColor = .white
        hdBadge.font = .systemFont(ofSize: 10, weight: .bold)
        hdBadge.textAlignment = .center
        hdBadge.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        hdBadge.layer.cornerRadius = 4
        hdBadge.clipsToBounds = true
        hdBadge.translatesAutoresizingMaskIntoConstraints = false
        bottomInfoContainer.addSubview(hdBadge)

        // ── Constraints ──
        NSLayoutConstraint.activate([
            // Top Bar
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            moreButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 36),
            moreButton.heightAnchor.constraint(equalToConstant: 36),

            // Video Container
            videoContainerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.heightAnchor.constraint(equalTo: videoContainerView.widthAnchor, multiplier: 9.0/16.0),

            centerPlayButton.centerXAnchor.constraint(equalTo: videoContainerView.centerXAnchor),
            centerPlayButton.centerYAnchor.constraint(equalTo: videoContainerView.centerYAnchor),
            centerPlayButton.widthAnchor.constraint(equalToConstant: 72),
            centerPlayButton.heightAnchor.constraint(equalToConstant: 72),

            // Controls
            controlsContainer.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 44),

            playPauseButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 14),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 28),
            playPauseButton.heightAnchor.constraint(equalToConstant: 28),

            volumeButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 10),
            volumeButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            volumeButton.widthAnchor.constraint(equalToConstant: 28),
            volumeButton.heightAnchor.constraint(equalToConstant: 28),

            currentTimeLabel.leadingAnchor.constraint(equalTo: volumeButton.trailingAnchor, constant: 10),
            currentTimeLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),

            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),

            durationLabel.trailingAnchor.constraint(equalTo: fullscreenButton.leadingAnchor, constant: -10),
            durationLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),

            fullscreenButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -14),
            fullscreenButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            fullscreenButton.widthAnchor.constraint(equalToConstant: 28),
            fullscreenButton.heightAnchor.constraint(equalToConstant: 28),

            // Bottom Info
            bottomInfoContainer.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            bottomInfoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomInfoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomInfoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            infoTitleLabel.topAnchor.constraint(equalTo: bottomInfoContainer.topAnchor, constant: 20),
            infoTitleLabel.leadingAnchor.constraint(equalTo: bottomInfoContainer.leadingAnchor, constant: 16),
            infoTitleLabel.trailingAnchor.constraint(equalTo: bottomInfoContainer.trailingAnchor, constant: -16),

            infoDescriptionLabel.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 8),
            infoDescriptionLabel.leadingAnchor.constraint(equalTo: infoTitleLabel.leadingAnchor),
            infoDescriptionLabel.trailingAnchor.constraint(equalTo: infoTitleLabel.trailingAnchor),

            dateIcon.topAnchor.constraint(equalTo: infoDescriptionLabel.bottomAnchor, constant: 14),
            dateIcon.leadingAnchor.constraint(equalTo: infoTitleLabel.leadingAnchor),
            dateIcon.widthAnchor.constraint(equalToConstant: 14),
            dateIcon.heightAnchor.constraint(equalToConstant: 14),

            dateLabel.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateIcon.trailingAnchor, constant: 5),

            durationIcon.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            durationIcon.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 14),
            durationIcon.widthAnchor.constraint(equalToConstant: 14),
            durationIcon.heightAnchor.constraint(equalToConstant: 14),

            durationInfoLabel.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            durationInfoLabel.leadingAnchor.constraint(equalTo: durationIcon.trailingAnchor, constant: 5),

            hdBadge.centerYAnchor.constraint(equalTo: dateIcon.centerYAnchor),
            hdBadge.leadingAnchor.constraint(equalTo: durationInfoLabel.trailingAnchor, constant: 10),
            hdBadge.widthAnchor.constraint(equalToConstant: 28),
            hdBadge.heightAnchor.constraint(equalToConstant: 18),
            hdBadge.bottomAnchor.constraint(lessThanOrEqualTo: bottomInfoContainer.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        view.bringSubviewToFront(topBarView)
    }

    // MARK: - Gestures
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        videoContainerView.addGestureRecognizer(tap)
    }

    // MARK: - Load Video + Data
    private func loadVideo() {
        // Fill text from properties / album
        titleLabel.text = albumTitle.isEmpty ? (album?.title ?? "Video") : albumTitle
        subtitleLabel.text = subtitleText

        infoTitleLabel.text = videoTitle.isEmpty ? (items.indices.contains(currentIndex) ? (items[currentIndex].caption ?? "Video") : "Video") : videoTitle
        infoDescriptionLabel.text = videoDescription.isEmpty ? (album?.description ?? "") : videoDescription
        infoDescriptionLabel.isHidden = (infoDescriptionLabel.text ?? "").isEmpty

        dateLabel.text = videoDate.isEmpty ? (album?.formattedEventDate ?? "") : videoDate
        durationInfoLabel.text = videoDuration

        // Resolve URL
        var urlString = videoURLString
        if urlString.isEmpty, items.indices.contains(currentIndex) {
            urlString = items[currentIndex].url
        }

        guard let url = URL(string: urlString), !urlString.isEmpty else {
            showAlert(title: "Error", message: "Invalid video URL")
            return
        }

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = videoContainerView.bounds
        if let layer = playerLayer {
            videoContainerView.layer.insertSublayer(layer, at: 0)
        }

        // Auto play
        player?.play()
        isPlaying = true
        updatePlayPauseIcons()
        scheduleHideControls()
    }

    private func setupPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self, !self.isSeeking else { return }
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(self.player?.currentItem?.duration ?? .zero)
            guard total.isFinite && total > 0 else { return }

            self.progressSlider.value = Float(current / total)
            self.currentTimeLabel.text = self.formatTime(current)
            self.durationLabel.text = self.formatTime(total)

            // Update bottom duration if empty
            if self.videoDuration.isEmpty {
                self.durationInfoLabel.text = self.formatTime(total)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    private func removeTimeObserver() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        player?.pause()
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func centerPlayTapped() {
        togglePlayPause()
    }

    @objc private func playPauseTapped() {
        togglePlayPause()
    }

    private func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
            centerPlayButton.isHidden = false
        } else {
            player.play()
            isPlaying = true
            centerPlayButton.isHidden = true
            scheduleHideControls()
        }
        updatePlayPauseIcons()
    }

    private func updatePlayPauseIcons() {
        let name = isPlaying ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        playPauseButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)

        let centerConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        centerPlayButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill", withConfiguration: centerConfig), for: .normal)
        centerPlayButton.isHidden = isPlaying && isControlsVisible == false
        if isPlaying {
            centerPlayButton.isHidden = true
        } else {
            centerPlayButton.isHidden = false
        }
    }

    @objc private func volumeTapped() {
        guard let player = player else { return }
        player.isMuted.toggle()
        let name = player.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        volumeButton.setImage(UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)), for: .normal)
    }

    @objc private func fullscreenTapped() {
        guard let player = player else { return }
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) {
            player.play()
        }
    }

    @objc private func videoTapped() {
        isControlsVisible.toggle()
        UIView.animate(withDuration: 0.25) {
            self.controlsContainer.alpha = self.isControlsVisible ? 1 : 0
            self.topBarView.alpha = self.isControlsVisible ? 1 : 0
            if !self.isPlaying {
                self.centerPlayButton.alpha = 1
            } else {
                self.centerPlayButton.alpha = self.isControlsVisible ? 0 : 0
            }
        }
        if isControlsVisible && isPlaying {
            scheduleHideControls()
        } else {
            hideControlsWorkItem?.cancel()
        }
    }

    private func scheduleHideControls() {
        hideControlsWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.isControlsVisible = false
            UIView.animate(withDuration: 0.25) {
                self.controlsContainer.alpha = 0
                self.topBarView.alpha = 0
            }
        }
        hideControlsWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: work)
    }

    @objc private func sliderTouchDown() {
        isSeeking = true
        hideControlsWorkItem?.cancel()
    }

    @objc private func sliderValueChanged() {
        let total = CMTimeGetSeconds(player?.currentItem?.duration ?? .zero)
        guard total.isFinite && total > 0 else { return }
        currentTimeLabel.text = formatTime(Double(progressSlider.value) * total)
    }

    @objc private func sliderTouchUp() {
        let total = CMTimeGetSeconds(player?.currentItem?.duration ?? .zero)
        guard total.isFinite && total > 0 else { isSeeking = false; return }
        let seekTime = Double(progressSlider.value) * total
        player?.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600)) { [weak self] _ in
            self?.isSeeking = false
            self?.scheduleHideControls()
        }
    }

    @objc private func videoDidFinish() {
        isPlaying = false
        updatePlayPauseIcons()
        centerPlayButton.isHidden = false
        player?.seek(to: .zero)
        isControlsVisible = true
        controlsContainer.alpha = 1
        topBarView.alpha = 1
    }

    // MARK: - Helpers
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "00:00" }
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Keep your existing IBAction if connected in storyboard
    @IBAction func backBtnAction(_ sender: Any) {
        backTapped()
    }
}
