//
//  Homepage.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.

import SwiftUI

struct Homepage: View {
    @State private var isSheetPresented = false
    @ObservedObject private var goalManager = GoalManager()

    var body: some View {
        NavigationView {
            VStack {
                if goalManager.userGoals.isEmpty {
                    EmptyMyGoalsView {
                        isSheetPresented = true
                    }
                } else if goalManager.areAllGoalsSameFrequency() {
                    MyGoalsView(goalManager: goalManager) {
                        isSheetPresented = true
                    }
                } else {
                    GroupedGoalsView(goalManager: goalManager) {
                        isSheetPresented = true
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                CreateNewGoal(isSheetPresented: $isSheetPresented, goalManager: goalManager)
            }
        }
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
