//
//  MyGoalsView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//
import SwiftUI
import HealthKit

struct MyGoalsView: View {
    @ObservedObject var goalManager: GoalManager
    var action: () -> Void
    @State private var editMode = EditMode.inactive

    var body: some View {
        List {
            ForEach(goalManager.userGoals) { userGoal in
                GoalView(goalManager: goalManager, userGoal: userGoal)
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
