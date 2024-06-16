//
//  UserGoal.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/19/24.
//

import SwiftUI
import HealthKit

enum GoalFrequency: String, CaseIterable {
    case daily, weekly, monthly, continuous
}

struct UserGoal: Identifiable {
    let id = UUID()
    let categoryId: CategoryId
    let goalType: GoalType
    let goal: Double?
    let frequency: GoalFrequency

    init(categoryId: CategoryId, goalType: GoalType, goal: Double? = nil, frequency: GoalFrequency) {
        self.categoryId = categoryId
        self.goalType = goalType
        self.goal = goal
        self.frequency = frequency
    }
}

class GoalManager: ObservableObject {
    @Published var userGoals: [UserGoal] = []
    private let healthStore = HKHealthStore()
      
    
    func setUserGoal(for categoryId: CategoryId, goalType: GoalType, goal: Double, frequency: GoalFrequency) {
        if let index = userGoals.firstIndex(where: { $0.categoryId == categoryId && $0.goalType.id == goalType.id }) {
            let updatedGoal = UserGoal(categoryId: categoryId, goalType: goalType, goal: goal, frequency: frequency)
            userGoals[index] = updatedGoal
        } else {
            let newUserGoal = UserGoal(categoryId: categoryId, goalType: goalType, goal: goal, frequency: frequency)
            userGoals.append(newUserGoal)
        }
    }

    func getUserGoal(for categoryId: CategoryId, goalType: GoalType) -> Double? {
        return userGoals.first(where: { $0.categoryId == categoryId && $0.goalType.id == goalType.id })?.goal
    }

    func checkHealthKitPermission(for goalType: GoalType, completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: goalType.HKQuantityTypeIdentifier) else {
            completion(false)
            return
        }
        healthStore.getRequestStatusForAuthorization(toShare: [], read: [quantityType]) { status, _ in
            completion(status == .unnecessary)
        }
    }

    func requestHealthKitPermission(for goalType: GoalType, completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: goalType.HKQuantityTypeIdentifier) else {
            completion(false)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [quantityType]) { success, _ in
            completion(success)
        }
    }
    
    func fetchHealthData(identifier: HKQuantityTypeIdentifier, unit: HKUnit, frequency: GoalFrequency, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(1)
            return
        }
        
        
        let now = Date()
        var interval = DateComponents()
        var anchorDate: Date?
        
        switch frequency {
        case .daily:
            interval.day = 1
            anchorDate = Calendar.current.startOfDay(for: now)
        case .weekly:
            interval.day = 7
            anchorDate = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
        case .monthly:
            interval.month = 1
            anchorDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now))
        case .continuous:
            interval.day = 1
            anchorDate = nil
        }
        
        guard let startDate = anchorDate else {
            completion(2)
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                   quantitySamplePredicate: nil,
                                                   options: [.cumulativeSum],
                                                   anchorDate: startDate,
                                                   intervalComponents: interval)
           
           query.initialResultsHandler = { query, results, error in
               guard let results = results else {
                   completion(3)
                   return
               }
               
               var sum = 0.0
               results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                   if let statisticsSum = statistics.sumQuantity() {
                       sum += statisticsSum.doubleValue(for: unit)
                   }
               }
               completion(sum)
           }
        
        
        healthStore.execute(query)
    }
}
