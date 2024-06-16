//
//  GoalView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 4/6/24.
//

import SwiftUI

struct GoalView: View {
    var icon: String
    var color: Color
    var title: String
    var goalValue: Int
    var goalUnit: String
    var progressValue: Double

    private var formattedPercentage: String {
        "\(Int((progressValue / Double(goalValue) * 100).rounded()))%"
    }

    private var formattedProgressValue: String {
        "\(Int(progressValue.rounded()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
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
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(icon: "flame.fill", color: .red, title: "Daily Steps", goalValue: 10000, goalUnit: "steps", progressValue: 7500)
    }
}
