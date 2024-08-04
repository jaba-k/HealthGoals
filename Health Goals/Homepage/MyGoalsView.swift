import SwiftUI
import HealthKit

struct MyGoalsView: View {
    @ObservedObject var goalManager: GoalManager
    var action: () -> Void
    @State private var editMode = EditMode.inactive

    var body: some View {
        NavigationView {
            List {
                ForEach(goalManager.userGoals) { userGoal in
                    ZStack {
                        NavigationLink(destination: GoalDetailView(goalManager: goalManager, userGoal: userGoal)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        GoalView(goalManager: goalManager, userGoal: userGoal)
                    }
                    .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let goal = goalManager.userGoals[index]
                        goalManager.deleteGoal(by: goal.id)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("My Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: action) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

