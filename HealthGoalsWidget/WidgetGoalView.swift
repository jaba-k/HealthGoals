import SwiftUI
import WidgetKit
import GoalFramework

struct WidgetGoalView: View {
    var userGoal: UserGoal
    var progressValue: Double
    var icon: String
    var color: Color

    private var formattedPercentage: String {
        let percentage = userGoal.goal == 0 ? 0 : (progressValue / userGoal.goal!) * 100
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
                Text(" / \(Int(userGoal.goal ?? 0)) \(userGoal.goalType.HKUnitString)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.secondarySystemBackground)
                .cornerRadius(12)
        }
    }
}
