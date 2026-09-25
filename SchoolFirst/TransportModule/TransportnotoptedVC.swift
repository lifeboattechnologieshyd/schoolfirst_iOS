
//
//  TransportnotoptedVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 22/09/26.
//

import UIKit
import SwiftUI

class TransportnotoptedVC: UIViewController {

    private var hostingController: UIHostingController<TransportNotOptedView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("🚍 TransportnotoptedVC - viewDidLoad")

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )

        // Make sure background is visible
        view.backgroundColor = UIColor(
            red: 0.97,
            green: 0.98,
            blue: 0.99,
            alpha: 1.0
        )

        // Create SwiftUI View
        let swiftUIView = TransportNotOptedView { [weak self] in

            print("⬅️ TransportnotoptedVC back button tapped")

            guard let self = self else {
                return
            }

            if let nav = self.navigationController,
               nav.viewControllers.count > 1 {

                print("⬅️ Popping TransportnotoptedVC")

                nav.popViewController(animated: true)

            } else {

                print("⬅️ Dismissing TransportnotoptedVC")

                self.dismiss(animated: true)
            }
        }

        // Create Hosting Controller
        let hostingController = UIHostingController(
            rootView: swiftUIView
        )

        self.hostingController = hostingController

        addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([

            hostingController.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            hostingController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            hostingController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            hostingController.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        hostingController.didMove(toParent: self)

        print("✅ TransportnotoptedVC SwiftUI UI loaded")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("👀 TransportnotoptedVC - viewWillAppear")

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("✅ TransportnotoptedVC - viewDidAppear")
    }
}

// MARK: - SwiftUI View

struct TransportNotOptedView: View {

    var backAction: () -> Void

    @State private var studentName: String =
        UserManager.shared.resolvedStudentName

    @State private var studentGrade: String =
        UserManager.shared.resolvedGradeSection

    @State private var photoURL: String =
        UserManager.shared.resolvedStudentPhotoURL

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Custom Navigation Bar

            HStack(spacing: 16) {

                Button(action: backAction) {

                    Image(systemName: "arrow.left")
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.12,
                                green: 0.18,
                                blue: 0.30
                            )
                        )
                }

                Text("Transport Details")
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        Color(
                            red: 0.12,
                            green: 0.18,
                            blue: 0.30
                        )
                    )

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, safeAreaTop() + 16)
            .padding(.bottom, 16)
            .background(Color.white)

            Divider()
                .background(
                    Color(
                        red: 0.93,
                        green: 0.95,
                        blue: 0.97
                    )
                )

            // MARK: - Main Content

            ScrollView(showsIndicators: false) {

                VStack(spacing: 24) {

                    // Student Card
                    studentCard

                    // Empty State Card
                    emptyStateCard

                    // Helpdesk Section
                    helpdeskSection
                }
                .padding(16)
            }
            .background(
                Color(
                    red: 0.97,
                    green: 0.98,
                    blue: 0.99
                )
            )
        }
        .edgesIgnoringSafeArea(.top)
    }

    // MARK: - Student Card

    private var studentCard: some View {

        HStack(spacing: 12) {

            // Student Avatar

            if !photoURL.isEmpty,
               let url = URL(string: photoURL) {

                AsyncImage(url: url) { phase in

                    switch phase {

                    case .success(let image):

                        image
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: 44,
                                height: 44
                            )
                            .clipShape(Circle())

                    default:

                        placeholderAvatar
                    }
                }

            } else {

                placeholderAvatar
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    studentName.isEmpty
                    ? "Student"
                    : studentName
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.12,
                        green: 0.18,
                        blue: 0.30
                    )
                )

                Text(
                    studentGrade.isEmpty
                    ? "--"
                    : studentGrade
                )
                .font(
                    .system(
                        size: 12,
                        weight: .regular
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.45,
                        green: 0.50,
                        blue: 0.58
                    )
                )
            }

            Spacer()

            // NOT OPTED Badge

            Text("NOT OPTED")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.88,
                        green: 0.55,
                        blue: 0.15
                    )
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Color(
                        red: 1.0,
                        green: 0.97,
                        blue: 0.88
                    )
                )
                .cornerRadius(6)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Placeholder Avatar

    private var placeholderAvatar: some View {

        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(
                width: 44,
                height: 44
            )
            .clipShape(Circle())
            .foregroundColor(
                .gray.opacity(0.3)
            )
    }

    // MARK: - Empty State Card

    private var emptyStateCard: some View {

        VStack(spacing: 16) {

            ZStack {

                Circle()
                    .fill(
                        Color(
                            red: 0.95,
                            green: 0.97,
                            blue: 1.0
                        )
                    )
                    .frame(
                        width: 100,
                        height: 100
                    )

                // MARK: - Bus Illustration

                if let busImage = UIImage(
                    named: "Illustration Placeholder"
                ) {

                    Image(uiImage: busImage)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(
                            width: 240,
                            height: 160
                        )

                } else {

                    // Fallback if asset is not found

                    Image(systemName: "bus.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 50,
                            height: 50
                        )
                        .foregroundColor(
                            Color(
                                red: 0.14,
                                green: 0.38,
                                blue: 0.92
                            )
                        )

                    Text("")
                        .onAppear {

                            print(
                                "❌ Illustration Placeholder image NOT FOUND in Assets.xcassets"
                            )
                        }
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 160
            )
            .onAppear {

                if UIImage(
                    named: "Illustration Placeholder"
                ) != nil {

                    print(
                        "✅ Illustration Placeholder image loaded successfully"
                    )

                } else {

                    print(
                        "❌ Illustration Placeholder image NOT FOUND"
                    )
                }
            }
            .padding(.top, 16)

            Text("No Active Transport Plan")
                .font(
                    .system(
                        size: 18,
                        weight: .bold
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.12,
                        green: 0.18,
                        blue: 0.30
                    )
                )

            Text(
                "\(studentName.isEmpty ? "The student" : studentName) is currently not registered for the school bus service. Live bus tracking, routes, pickup/drop times, and driver contacts are only available for enrolled students."
            )
            .font(
                .system(
                    size: 13,
                    weight: .regular
                )
            )
            .foregroundColor(
                Color(
                    red: 0.45,
                    green: 0.50,
                    blue: 0.58
                )
            )
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 8)
            .padding(.bottom, 24)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    // MARK: - Helpdesk Section

    private var helpdeskSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("NEED HELP OR HAVE QUERIES?")
                .font(
                    .system(
                        size: 11,
                        weight: .semibold
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.60,
                        green: 0.65,
                        blue: 0.70
                    )
                )
                .padding(.leading, 4)

            HStack(spacing: 12) {

                Circle()
                    .fill(
                        Color(
                            red: 0.95,
                            green: 0.96,
                            blue: 0.98
                        )
                    )
                    .frame(
                        width: 40,
                        height: 40
                    )
                    .overlay(
                        Image(systemName: "phone.fill")
                            .font(
                                .system(size: 16)
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.45,
                                    green: 0.50,
                                    blue: 0.58
                                )
                            )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text("Transport Helpdesk")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.12,
                                green: 0.18,
                                blue: 0.30
                            )
                        )

                    Text("+1 (555) 019-2834")
                        .font(
                            .system(
                                size: 12,
                                weight: .regular
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.45,
                                green: 0.50,
                                blue: 0.58
                            )
                        )
                }

                Spacer()

                Button(action: {
                    callHelpdesk()
                }) {

                    Circle()
                        .fill(
                            Color(
                                red: 0.93,
                                green: 0.96,
                                blue: 1.0
                            )
                        )
                        .frame(
                            width: 40,
                            height: 40
                        )
                        .overlay(
                            Image(
                                systemName: "phone.fill"
                            )
                            .font(
                                .system(size: 16)
                            )
                            .foregroundColor(
                                Color(
                                    red: 0.14,
                                    green: 0.38,
                                    blue: 0.92
                                )
                            )
                        )
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }

    // MARK: - Helpers

    private func safeAreaTop() -> CGFloat {

        guard
            let windowScene =
                UIApplication.shared.connectedScenes.first
                as? UIWindowScene,

            let window =
                windowScene.windows.first
        else {
            return 44
        }

        return window.safeAreaInsets.top
    }

    private func callHelpdesk() {

        let phone = "15550192834"

        if let url = URL(
            string: "tel://\(phone)"
        ),
        UIApplication.shared.canOpenURL(url) {

            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil
            )
        }
    }
}
