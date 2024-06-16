//
//  CreateNewGoal.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//

import SwiftUI
import Foundation
import HealthKit

struct CreateNewGoal: View {
    let goalManager: GoalManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.name) { category in
                    Section(header: CategoryHeader(category: category)) {
                        ForEach(category.goals, id: \.name) { item in
                            NavigationLink(destination: CreateGoal(goalManager: goalManager, goal: item)) {
                                Text(item.name)
                            }
                        }
                    }
                }
            }
                        .navigationTitle("Available Goals")
            .headerProminence(.increased)
        }
    }
}

struct CategoryHeader: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
            Text(category.name)
                .font(.headline)
        }
    }
}

struct CreateGoal: View {
    let goalManager: GoalManager
    let goal: GoalType
      @State private var selectedFrequency: GoalFrequency
      @State private var goalValue: Double = 0
      @State private var hasPermission: Bool = false
      @Environment(\.presentationMode) var presentationMode

    init(goalManager: GoalManager, goal: GoalType) {
          self.goalManager = goalManager
          self.goal = goal
        _selectedFrequency = State(initialValue: goal.frequency)
      }


    var body: some View {
        Form {
            if selectedFrequency != .continuous { // Hide frequency section if .continuous
                           Section(header: Text("Frequency")) {
                               Picker("Frequency", selection: $selectedFrequency) {
                                   ForEach(GoalFrequency.allCases.filter { $0 != .continuous }, id: \.self) { frequency in
                                       Text(frequency.rawValue.capitalized)
                                   }
                               }
                               .pickerStyle(.segmented)
                           }
                       }
            Section(header: Text("Goal")) {
                TextField("Enter your goal", value: $goalValue, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                if hasPermission {
                    Text("HealthKit permission granted")
                        .foregroundColor(.green)
                } else {
                    VStack {
                        Text("access not granted")
                            .foregroundColor(.red)
                        Button("Grant HealthKit Permission") {
                            requestPermission()
                        }
                    }
                }
            }
            
            Button("Set Goal") {
                goalManager.setUserGoal(for: goal.categoryId, goalType: goal, goal: goalValue, frequency: selectedFrequency)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(!hasPermission)
        }
        .navigationTitle(goal.name)
        .onAppear {
            checkPermission()
        }
    }
    
    private func checkPermission() {
        goalManager.checkHealthKitPermission(for: goal) { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }

    private func requestPermission() {
        goalManager.requestHealthKitPermission(for: goal) { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
}


#Preview {
    CreateNewGoal(goalManager: GoalManager())
}
