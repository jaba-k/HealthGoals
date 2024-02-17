//
//  Homepage.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.

import SwiftUI

struct Goal: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let items: [QuantityType]
}


struct Homepage: View {
    @StateObject private var viewModel = HomepageViewModel()
    @State private var isCreatingNewGoal = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.goals.isEmpty {
                    EmptyMyGoalsView {
                        isCreatingNewGoal = true
                    }
                } else {
                    MyGoalsView {
                        isCreatingNewGoal = true
                    }
                }
            }
            .sheet(isPresented: $isCreatingNewGoal) {
                CreateNewGoal()
            }
        }
        .onAppear {
            viewModel.fetchGoals()
        }
    }
}




class HomepageViewModel: ObservableObject {
    @Published var showAddGoalView = false
    @Published var goals = [Goal]()
    
    func fetchGoals() {
        // Fetch goals from a data source
        goals = []
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
