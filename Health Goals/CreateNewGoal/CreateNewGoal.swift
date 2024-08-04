//
//  CreateNewGoal.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//

import SwiftUI
import Foundation
import HealthKit

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

struct CreateNewGoal: View {
    @Binding var isSheetPresented: Bool
    let goalManager: GoalManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.name) { category in
                    Section(header: CategoryHeader(category: category)) {
                        ForEach(category.goals, id: \.name) { item in
                            NavigationLink(destination: CreateGoal(goalManager: goalManager, goal: item, isSheetPresented: $isSheetPresented)) {
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


struct CreateGoal: View {
    let goalManager: GoalManager
    let goal: GoalType
    @Binding var isSheetPresented: Bool

    @State private var selectedFrequency: GoalFrequency
    @State private var goalValue: Double = 0
    @State private var hasPermission: Bool = false
    @Environment(\.presentationMode) var presentationMode

    init(goalManager: GoalManager, goal: GoalType, isSheetPresented: Binding<Bool>) {
        self.goalManager = goalManager
        self.goal = goal
        self._isSheetPresented = isSheetPresented
        _selectedFrequency = State(initialValue: goal.frequency)
    }

    var body: some View {
        Form {
            if selectedFrequency != .continuous {
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
                        Text("Access not granted")
                            .foregroundColor(.red)
                        Button("Grant HealthKit Permission") {
                            requestPermission()
                        }
                    }
                }
            }

            Button("Set Goal") {
                goalManager.setUserGoal(for: goal.categoryId, goalType: goal, goal: goalValue, frequency: selectedFrequency)
                isSheetPresented = false
            }
            .disabled(!hasPermission)
        }
        .navigationTitle(goal.name)
        .onAppear {
            checkPermission()
        }
    }

    private func checkPermission() {
        goalManager.checkHealthKitPermission(for: HKQuantityTypeIdentifier(rawValue: goal.HKQuantityTypeIdentifierRawValue)) { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }

    private func requestPermission() {
        goalManager.requestHealthKitPermission(for: HKQuantityTypeIdentifier(rawValue: goal.HKQuantityTypeIdentifierRawValue)) { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
}


