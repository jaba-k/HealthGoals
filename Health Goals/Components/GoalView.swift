//
//  GoalView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 4/6/24.
//

import SwiftUI

struct GoalView: View {
    @ObservedObject var goalManager: GoalManager
    var userGoal: UserGoal
    @State private var progressValue: Double = 0.0
    @State private var icon: String = "questionmark"
    @State private var color: Color = .gray
    @State private var goalValue: Int = 0
    @State private var goalUnit: String = ""

    private var formattedPercentage: String {
        let percentage = goalValue == 0 ? 0 : (progressValue / Double(goalValue)) * 100
        return "\(Int(percentage.rounded()))%"
    }

    private var formattedProgressValue: String {
        "\(Int(progressValue.rounded()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(userGoal.goalType.name)
                    .font(.headline)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(formattedPercentage)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(formattedProgressValue)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                Text(" / \(goalValue) \(goalUnit)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            fetchGoalDetails()
        }
    }

    private func fetchGoalDetails() {
        if let category = categories.first(where: { $0.id == userGoal.categoryId }) {
            icon = category.icon
            color = category.color
        }
        goalValue = Int(userGoal.goal ?? 0)
        goalUnit = userGoal.goalType.HKUnit.unitString

        goalManager.fetchHealthData(identifier: userGoal.goalType.HKQuantityTypeIdentifier, unit: userGoal.goalType.HKUnit, frequency: userGoal.frequency) { result in
            DispatchQueue.main.async {
                progressValue = result
            }
        }
    }
}
