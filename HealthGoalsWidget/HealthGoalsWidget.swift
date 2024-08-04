import WidgetKit
import SwiftUI
import HealthKit
import GoalFramework

struct Provider: TimelineProvider {
    let goalManager = GoalManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), goal: sampleGoal, progressValue: 5000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), goal: sampleGoal, progressValue: 5000)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let goal = goalManager.userGoals.first else {
            completion(Timeline(entries: [SimpleEntry(date: Date(), goal: sampleGoal, progressValue: 0)], policy: .atEnd))
            return
        }
        
        goalManager.fetchHealthData(identifier: HKQuantityTypeIdentifier(rawValue: goal.goalType.HKQuantityTypeIdentifierRawValue), unit: HKUnit(from: goal.goalType.HKUnitString), frequency: goal.frequency) { result in
            let entry = SimpleEntry(date: Date(), goal: goal, progressValue: result)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let goal: UserGoal
    let progressValue: Double
}

struct HealthGoalsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetGoalView(userGoal: entry.goal, progressValue: entry.progressValue, icon: iconForCategory(entry.goal.categoryId), color: colorForCategory(entry.goal.categoryId))
    }
    
    func iconForCategory(_ categoryId: CategoryId) -> String {
        categories.first(where: { $0.id == categoryId })?.icon ?? "questionmark"
    }
    
    func colorForCategory(_ categoryId: CategoryId) -> Color {
        categories.first(where: { $0.id == categoryId })?.color ?? .gray
    }
}

struct HealthGoalsWidget: Widget {
    let kind: String = "HealthGoalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HealthGoalsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Health Goal")
        .description("Display your health goal progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HealthGoalsWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthGoalsWidgetEntryView(entry: SimpleEntry(date: Date(), goal: sampleGoal, progressValue: 5000))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

// Sample data for preview and placeholder
let sampleGoal = UserGoal(categoryId: .activity, goalType: GoalType(name: "Steps", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifierRawValue: "HKQuantityTypeIdentifierStepCount", HKUnitString: "count"), goal: 10000, frequency: .daily)
