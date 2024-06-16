//
//  Homepage.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.

import SwiftUI

struct Homepage: View {
    @State private var isCreatingNewGoal = false
    @ObservedObject var goalManager = GoalManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if goalManager.userGoals.isEmpty {
                    EmptyMyGoalsView {
                        isCreatingNewGoal = true
                    }
                } else if goalManager.areAllGoalsSameFrequency() {
                    MyGoalsView(goalManager: goalManager) {
                        isCreatingNewGoal = true
                    }
                } else {
                    GroupedGoalsView(goalManager: goalManager) {
                        isCreatingNewGoal = true
                    }
                }
            }
            .sheet(isPresented: $isCreatingNewGoal) {
                CreateNewGoal(goalManager: goalManager)
            }
        }
    }
}



struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
