//
//  MultiColorCalendarCell.swift
//  SchoolFirst
//

import UIKit
import FSCalendar

class MultiColorCalendarCell: FSCalendarCell {

    private let multiColorContainer = UIView()
    private var colorViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMultiColorContainer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMultiColorContainer()
    }

    private func setupMultiColorContainer() {
        multiColorContainer.translatesAutoresizingMaskIntoConstraints = false
        multiColorContainer.clipsToBounds = true
        multiColorContainer.layer.cornerRadius = 8
        multiColorContainer.isHidden = true
        contentView.insertSubview(multiColorContainer, at: 0)

        NSLayoutConstraint.activate([
            multiColorContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            multiColorContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            multiColorContainer.widthAnchor.constraint(equalToConstant: 36),
            multiColorContainer.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showMultiColor(false)
    }

    // MARK: - Original method (backward compatible)
    func showMultiColor(_ show: Bool) {
        if show {
            // Default 2-color split (backward compatible)
            showMultiColorWithColors([.systemOrange, .systemBlue])
        } else {
            multiColorContainer.isHidden = true
            colorViews.forEach { $0.removeFromSuperview() }
            colorViews.removeAll()
        }
    }

    // MARK: - Dynamic colors method
    func showMultiColorWithColors(_ colors: [UIColor]) {
        // Remove old color views
        colorViews.forEach { $0.removeFromSuperview() }
        colorViews.removeAll()

        guard !colors.isEmpty else {
            multiColorContainer.isHidden = true
            return
        }

        multiColorContainer.isHidden = false
        multiColorContainer.backgroundColor = .clear

        let uniqueColors = Array(Set(colors.map { $0.cgColor.hashValue }).prefix(4)
            .enumerated()
            .map { colors[min($0.offset, colors.count - 1)] })

        // Use actual colors array (up to 4)
        let displayColors = Array(colors.prefix(4))

        switch displayColors.count {
        case 1:
            // Single color fills entire cell
            multiColorContainer.backgroundColor = displayColors[0]

        case 2:
            // Left-right split
            let leftView = UIView()
            leftView.translatesAutoresizingMaskIntoConstraints = false
            leftView.backgroundColor = displayColors[0]
            multiColorContainer.addSubview(leftView)
            colorViews.append(leftView)

            let rightView = UIView()
            rightView.translatesAutoresizingMaskIntoConstraints = false
            rightView.backgroundColor = displayColors[1]
            multiColorContainer.addSubview(rightView)
            colorViews.append(rightView)

            NSLayoutConstraint.activate([
                leftView.leadingAnchor.constraint(equalTo: multiColorContainer.leadingAnchor),
                leftView.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                leftView.bottomAnchor.constraint(equalTo: multiColorContainer.bottomAnchor),
                leftView.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),

                rightView.trailingAnchor.constraint(equalTo: multiColorContainer.trailingAnchor),
                rightView.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                rightView.bottomAnchor.constraint(equalTo: multiColorContainer.bottomAnchor),
                rightView.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5)
            ])

        case 3:
            // Top-left, top-right, bottom-full
            let topLeft = UIView()
            topLeft.translatesAutoresizingMaskIntoConstraints = false
            topLeft.backgroundColor = displayColors[0]
            multiColorContainer.addSubview(topLeft)
            colorViews.append(topLeft)

            let topRight = UIView()
            topRight.translatesAutoresizingMaskIntoConstraints = false
            topRight.backgroundColor = displayColors[1]
            multiColorContainer.addSubview(topRight)
            colorViews.append(topRight)

            let bottom = UIView()
            bottom.translatesAutoresizingMaskIntoConstraints = false
            bottom.backgroundColor = displayColors[2]
            multiColorContainer.addSubview(bottom)
            colorViews.append(bottom)

            NSLayoutConstraint.activate([
                topLeft.leadingAnchor.constraint(equalTo: multiColorContainer.leadingAnchor),
                topLeft.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                topLeft.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                topLeft.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5),

                topRight.trailingAnchor.constraint(equalTo: multiColorContainer.trailingAnchor),
                topRight.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                topRight.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                topRight.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5),

                bottom.leadingAnchor.constraint(equalTo: multiColorContainer.leadingAnchor),
                bottom.trailingAnchor.constraint(equalTo: multiColorContainer.trailingAnchor),
                bottom.bottomAnchor.constraint(equalTo: multiColorContainer.bottomAnchor),
                bottom.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5)
            ])

        default:
            // 4 quadrants
            let topLeft = UIView()
            topLeft.translatesAutoresizingMaskIntoConstraints = false
            topLeft.backgroundColor = displayColors[0]
            multiColorContainer.addSubview(topLeft)
            colorViews.append(topLeft)

            let topRight = UIView()
            topRight.translatesAutoresizingMaskIntoConstraints = false
            topRight.backgroundColor = displayColors[1]
            multiColorContainer.addSubview(topRight)
            colorViews.append(topRight)

            let bottomLeft = UIView()
            bottomLeft.translatesAutoresizingMaskIntoConstraints = false
            bottomLeft.backgroundColor = displayColors[2]
            multiColorContainer.addSubview(bottomLeft)
            colorViews.append(bottomLeft)

            let bottomRight = UIView()
            bottomRight.translatesAutoresizingMaskIntoConstraints = false
            bottomRight.backgroundColor = displayColors[3]
            multiColorContainer.addSubview(bottomRight)
            colorViews.append(bottomRight)

            NSLayoutConstraint.activate([
                topLeft.leadingAnchor.constraint(equalTo: multiColorContainer.leadingAnchor),
                topLeft.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                topLeft.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                topLeft.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5),

                topRight.trailingAnchor.constraint(equalTo: multiColorContainer.trailingAnchor),
                topRight.topAnchor.constraint(equalTo: multiColorContainer.topAnchor),
                topRight.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                topRight.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5),

                bottomLeft.leadingAnchor.constraint(equalTo: multiColorContainer.leadingAnchor),
                bottomLeft.bottomAnchor.constraint(equalTo: multiColorContainer.bottomAnchor),
                bottomLeft.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                bottomLeft.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5),

                bottomRight.trailingAnchor.constraint(equalTo: multiColorContainer.trailingAnchor),
                bottomRight.bottomAnchor.constraint(equalTo: multiColorContainer.bottomAnchor),
                bottomRight.widthAnchor.constraint(equalTo: multiColorContainer.widthAnchor, multiplier: 0.5),
                bottomRight.heightAnchor.constraint(equalTo: multiColorContainer.heightAnchor, multiplier: 0.5)
            ])
        }
    }
}
