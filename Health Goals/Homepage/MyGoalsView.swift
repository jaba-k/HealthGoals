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
    
    @State private var progressValues: [UUID: Double] = [:]
    
    private func calculateProgress(for goal: UserGoal, completion: @escaping (Double) -> Void) {
        goalManager.fetchHealthData(identifier: goal.goalType.HKQuantityTypeIdentifier, unit: goal.goalType.HKUnit, frequency: .daily) { result in
            let progress = (result / (goal.goal ?? 1)) * 100
            completion(progress)
        }
    }

    var body: some View {
        List {
            ForEach(goalManager.userGoals) { userGoal in
                let category = categories.first(where: { $0.id == userGoal.categoryId })
                let icon = category?.icon ?? "questionmark"
                let color = category?.color ?? Color.gray
                let goalValue = Int(userGoal.goal ?? 0)
                let goalUnit = userGoal.goalType.HKUnit.unitString
                let progressValue = progressValues[userGoal.id] ?? 0
                
                GoalView(
                    icon: icon,
                    color: color,
                    title: userGoal.goalType.name,
                    goalValue: goalValue,
                    goalUnit: goalUnit,
                    progressValue: progressValue
                )
                .onAppear {
                    calculateProgress(for: userGoal) { progress in
                        DispatchQueue.main.async {
                            progressValues[userGoal.id] = progress
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("My Goals")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: action) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
