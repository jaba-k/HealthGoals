//
//  GroupedGoalsView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 6/16/24.
//

import SwiftUI

struct GroupedGoalsView: View {
    @ObservedObject var goalManager: GoalManager
    @State private var editMode = EditMode.inactive
    var action: () -> Void

    var body: some View {
        List {
            ForEach(GoalFrequency.allCases, id: \.self) { frequency in
                if let goals = goalManager.groupedGoalsByFrequency()[frequency], !goals.isEmpty {
                    Section(header: Text(frequency.rawValue.capitalized)) {
                        ForEach(goals) { userGoal in
                            GoalView(goalManager: goalManager, userGoal: userGoal)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let goal = goals[index]
                                goalManager.deleteGoal(by: goal.id)
                            }
                        }
                    }
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
