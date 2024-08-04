import SwiftUI

struct GoalDetailView: View {
    @ObservedObject var goalManager: GoalManager
    let userGoal: UserGoal
    @State private var periodData: [GoalManager.GoalPeriodData] = []
    @State private var isLoading = true
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                progressView
                historyView
                additionalInfoView
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPeriodData()
        }
    }
    
//    private var headerView: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(userGoal.goalType.name)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                Text("Goal: \(userGoal.goal?.formatted() ?? "N/A") \(userGoal.goalType.HKUnitString)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//            StreakView(streak: currentStreak)
//                .frame(width: 80, height: 80)
//        }
//    }
    
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(periodLabel)
                .font(.headline)
            HStack {
                Text(currentValue.formatted())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(userGoal.goalType.HKUnitString)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(currentProgress))%")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }
            ProgressView(value: currentProgress / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(periodData.reversed().indices, id: \.self) { index in
                        let reversedIndex = periodData.count - 1 - index
                        HistoryTileView(data: periodData[reversedIndex], isSelected: Calendar.current.isDate(periodData[reversedIndex].date, inSameDayAs: selectedDate), frequency: userGoal.frequency)
                            .onTapGesture {
                                selectedDate = periodData[reversedIndex].date
                            }
                    }
                }
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
    }
    
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional Information")
                .font(.headline)
            InfoRowView(title: "Average Progress", value: "\(averageProgress.formatted(.percent))")
            InfoRowView(title: "Best Day", value: bestDay)
            InfoRowView(title: "Current Streak", value: "\(currentStreak) \(streakPeriod)")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var currentProgress: Double {
        guard let selectedData = periodData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) else { return 0 }
        return selectedData.percentage
    }
    
    private var currentValue: Double {
        guard let selectedData = periodData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) else { return 0 }
        return selectedData.actualValue
    }
    
    private var progressColor: Color {
        if currentProgress >= 100 {
            return .green
        } else if currentProgress >= 70 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var averageProgress: Double {
        let total = periodData.reduce(0) { $0 + $1.percentage }
        return (total / Double(periodData.count)).rounded()
    }
    
    private var bestDay: String {
        guard let best = periodData.max(by: { $0.percentage < $1.percentage }) else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: best.date)) (\(Int(best.percentage))%)"
    }
    
    private var currentStreak: Int {
        var streak = 0
        let today = Calendar.current.startOfDay(for: Date())
        for data in periodData.sorted(by: { $0.date > $1.date }) {
            if Calendar.current.isDate(data.date, inSameDayAs: today) {
                // Don't count today in the streak
                continue
            }
            if data.goalReached {
                streak += 1
            } else {
                break
            }
        }
        // If today's goal is reached, add 1 to the streak
        if let todayData = periodData.first(where: { Calendar.current.isDateInToday($0.date) }),
           todayData.goalReached {
            streak += 1
        }
        return streak
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(userGoal.goalType.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Goal: \(userGoal.goal?.formatted() ?? "N/A") \(userGoal.goalType.HKUnitString)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if currentStreak > 0 {
                StreakView(streak: currentStreak)
                    .frame(width: 80, height: 80)
            }
        }
    }
    
    private var streakPeriod: String {
        switch userGoal.frequency {
        case .daily: return "days"
        case .weekly: return "weeks"
        case .monthly: return "months"
        case .continuous: return "periods"
        }
    }
    
    private var periodLabel: String {
        let today = Date()
        switch userGoal.frequency {
        case .daily:
            return Calendar.current.isDateInToday(selectedDate) ? "Today's Progress" : "Progress for \(formattedDate(selectedDate))"
        case .weekly:
            return Calendar.current.isDate(selectedDate, equalTo: today, toGranularity: .weekOfYear) ? "This Week's Progress" : "Progress for \(formattedDateRange(selectedDate))"
        case .monthly:
            return Calendar.current.isDate(selectedDate, equalTo: today, toGranularity: .month) ? "This Month's Progress" : "Progress for \(formattedMonth(selectedDate))"
        case .continuous:
            return "Current Progress"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
    
    private func formattedDateRange(_ date: Date) -> String {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    private func loadPeriodData() {
        isLoading = true
        Task {
            switch userGoal.frequency {
            case .daily:
                periodData = await goalManager.getDailyGoalData(for: userGoal.goalType, pastNDays: 7)
            case .weekly:
                periodData = await goalManager.getWeeklyGoalData(for: userGoal.goalType, pastNWeeks: 4)
            case .monthly:
                periodData = await goalManager.getMonthlyGoalData(for: userGoal.goalType, pastNMonths: 3)
            case .continuous:
                // Handle continuous goals differently if needed
                break
            }
            isLoading = false
        }
    }
}

struct StreakView: View {
    let streak: Int
    
    var body: some View {
        VStack {
            Image(systemName: "flame.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(streak > 0 ? .orange : .gray)
                .frame(width: 40, height: 40)
            Text("\(streak)")
                .font(.headline)
                .foregroundColor(streak > 0 ? .orange : .gray)
        }
    }
}

struct HistoryTileView: View {
    let data: GoalManager.GoalPeriodData
    let isSelected: Bool
    let frequency: GoalFrequency
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tileColor.opacity(0.2))
                
                VStack(spacing: 2) {
                    Text("\(Int(data.percentage))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .frame(width: 50, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .padding(2)
    }
    
    private var tileColor: Color {
        data.goalReached ? .green : .red
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        switch frequency {
        case .daily:
            formatter.dateFormat = "d MMM"
        case .weekly:
            formatter.dateFormat = "d MMM"
            let endDate = Calendar.current.date(byAdding: .day, value: 6, to: data.date)!
            return "\(formatter.string(from: data.date)) - \(formatter.string(from: endDate))"
        case .monthly:
            formatter.dateFormat = "MMM"
        case .continuous:
            formatter.dateFormat = "d MMM"
        }
        return formatter.string(from: data.date)
    }
}

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
