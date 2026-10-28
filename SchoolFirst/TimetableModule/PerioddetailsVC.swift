//
//  PerioddetailsVC.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 28/10/26.
//

import UIKit
import SwiftUI

class PerioddetailsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide standard navigation bar to use the custom Figma header
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Initialize the SwiftUI View
        var swiftUIView = PeriodDetailsView()
        
        // Navigation Callback
        swiftUIView.onViewScheduleChangesTapped = { [weak self] in
            let scheduleVC = SchedulechangesandhistoryVC()
            self?.navigationController?.pushViewController(scheduleVC, animated: true)
        }
        
        // Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup Constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

// MARK: - Dummy Model for API mapping
struct PeriodDetailsModel {
    let periodName: String
    let isSubstitution: Bool
    let subjectName: String
    let topicName: String
    let substitutionAlertTitle: String
    let substitutionAlertDesc: String
    let periodTime: String
    let teacherName: String
    let room: String
    let classSection: String
    let classTimetable: String
}

// MARK: - SwiftUI View

struct PeriodDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Navigation Callback
    var onViewScheduleChangesTapped: (() -> Void)? = nil
    
    // Dummy Data
    let model = PeriodDetailsModel(
        periodName: "PERIOD 3",
        isSubstitution: true,
        subjectName: "Science",
        topicName: "Living systems · Chapter 6",
        substitutionAlertTitle: "Teacher substitution today",
        substitutionAlertDesc: "Meera Nair is away. Arun Kapoor will take this period. Time and room are unchanged.",
        periodTime: "09:45–10:30 AM",
        teacherName: "Arun Kapoor · Substitute",
        room: "Science Lab 1",
        classSection: "Grade 5 · Section B",
        classTimetable: "Tuesday · Period 3"
    )
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255) // #0B569A
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Custom Header (Fixed height 100)
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // Subject Card
                    subjectCardView
                    
                    // Substitution Alert Box
                    if model.isSubstitution {
                        substitutionAlertView
                    }
                    
                    // Details List Card
                    detailsListCardView
                    
                    // Bottom Action Button → Navigate to SchedulechangesandhistoryVC
                    Button(action: {
                        onViewScheduleChangesTapped?()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                            Text("View schedule changes")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(mainBlue)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color.white) // Clean white background for the scroll area
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Period details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Tuesday, 22 September")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.leading, 12)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: 100, alignment: .bottom)
        .background(mainBlue)
    }
    
    private var subjectCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Period Badge
                Text(model.periodName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(mainBlue)
                    .cornerRadius(12)
                
                Spacer()
                
                // Substitution Badge
                if model.isSubstitution {
                    Text("SUBSTITUTION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.subjectName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(mainBlue)
                
                Text(model.topicName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(mainBlue.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(mainBlue.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var substitutionAlertView: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.orange)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.substitutionAlertTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text(model.substitutionAlertDesc)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 1.0, green: 0.98, blue: 0.92)) // Light yellowish-orange
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var detailsListCardView: some View {
        VStack(spacing: 0) {
            DetailRowView(
                iconName: "clock",
                title: "PERIOD TIME",
                value: model.periodTime,
                showDivider: true
            )
            DetailRowView(
                iconName: "person",
                title: "TEACHER",
                value: model.teacherName,
                showDivider: true
            )
            DetailRowView(
                iconName: "mappin.and.ellipse",
                title: "ROOM",
                value: model.room,
                showDivider: true
            )
            DetailRowView(
                iconName: "person.2",
                title: "CLASS / SECTION",
                value: model.classSection,
                showDivider: true
            )
            DetailRowView(
                iconName: "calendar",
                title: "CLASS TIMETABLE",
                value: model.classTimetable,
                showDivider: false // Last item has no divider
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Reusable Detail Row
struct DetailRowView: View {
    let iconName: String
    let title: String
    let value: String
    let showDivider: Bool
    
    let mainBlue = Color(red: 11/255, green: 86/255, blue: 154/255)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(mainBlue.opacity(0.08))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(mainBlue)
                }
                
                // Text Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            if showDivider {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 1)
                    .padding(.leading, 72) // Align divider with text
            }
        }
    }
}

// MARK: - Previews (For Xcode Canvas)
struct PeriodDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodDetailsView(onViewScheduleChangesTapped: {})
    }
}
