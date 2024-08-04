//
//  GoalManager.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 6/16/24.
//

import HealthKit

public class UserGoal: Identifiable, Codable {
    public let id: UUID
    public let categoryId: CategoryId
    public let goalType: GoalType
    public let goal: Double?
    public let frequency: GoalFrequency

    public init(categoryId: CategoryId, goalType: GoalType, goal: Double? = nil, frequency: GoalFrequency) {
        self.id = UUID()
        self.categoryId = categoryId
        self.goalType = goalType
        self.goal = goal
        self.frequency = frequency
    }
    
    public enum CodingKeys: String, CodingKey {
           case id, categoryId, goalType, goal, frequency
       }
}

public class GoalManager: ObservableObject {
    @Published public var userGoals: [UserGoal] = []
    private let healthStore = HKHealthStore()
    
    public init() {
        self.loadUserGoals()
    }

    private func loadUserGoals() {
        if let data = UserDefaults.standard.data(forKey: "userGoals"),
           let decodedGoals = try? JSONDecoder().decode([UserGoal].self, from: data) {
            self.userGoals = decodedGoals
        }
    }

    private func saveUserGoals() {
        if let encodedData = try? JSONEncoder().encode(userGoals) {
            UserDefaults.standard.set(encodedData, forKey: "userGoals")
        }
    }

    public func setUserGoal(for categoryId: CategoryId, goalType: GoalType, goal: Double, frequency: GoalFrequency) {
        let newUserGoal = UserGoal(categoryId: categoryId, goalType: goalType, goal: goal, frequency: frequency)
        userGoals.append(newUserGoal)
        saveUserGoals()
    }

    public func deleteGoal(by id: UUID) {
        userGoals.removeAll { $0.id == id }
        saveUserGoals()
    }

    public func getUserGoal(for categoryId: CategoryId, goalType: GoalType) -> Double? {
        return userGoals.first(where: { $0.categoryId == categoryId && $0.goalType.id == goalType.id })?.goal
    }

    public func checkHealthKitPermission(for identifier: HKQuantityTypeIdentifier, completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(false)
            return
        }
        healthStore.getRequestStatusForAuthorization(toShare: [], read: [quantityType]) { status, _ in
            completion(status == .unnecessary)
        }
    }
    
    public func areAllGoalsSameFrequency() -> Bool {
        guard !userGoals.isEmpty else { return true }
        let firstFrequency = userGoals.first?.frequency
        return userGoals.allSatisfy { $0.frequency == firstFrequency }
    }

    public func groupedGoalsByFrequency() -> [GoalFrequency: [UserGoal]] {
        var groupedGoals = [GoalFrequency: [UserGoal]]()
        for goal in userGoals {
            groupedGoals[goal.frequency, default: []].append(goal)
        }
        return groupedGoals
    }

    public func requestHealthKitPermission(for identifier: HKQuantityTypeIdentifier, completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(false)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [quantityType]) { success, _ in
            completion(success)
        }
    }
    
    public func fetchHealthData(identifier: HKQuantityTypeIdentifier, unit: HKUnit, frequency: GoalFrequency, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(0)
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
            completion(0)
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: [.cumulativeSum],
                                                anchorDate: startDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                completion(0)
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
    
    public struct GoalPeriodData {
        public let date: Date
        public let goal: Double
        public let actualValue: Double
        public let percentage: Double
        public let goalReached: Bool
    }
}

extension GoalManager {
    func getDailyGoalData(for goalType: GoalType, pastNDays: Int) async -> [GoalPeriodData] {
        return await getGoalData(for: goalType, pastNPeriods: pastNDays, periodComponent: .day)
    }

    func getWeeklyGoalData(for goalType: GoalType, pastNWeeks: Int) async -> [GoalPeriodData] {
        return await getGoalData(for: goalType, pastNPeriods: pastNWeeks, periodComponent: .weekOfYear)
    }

    func getMonthlyGoalData(for goalType: GoalType, pastNMonths: Int) async -> [GoalPeriodData] {
        return await getGoalData(for: goalType, pastNPeriods: pastNMonths, periodComponent: .month)
    }

    private func getGoalData(for goalType: GoalType, pastNPeriods: Int, periodComponent: Calendar.Component) async -> [GoalPeriodData] {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: goalType.HKQuantityTypeIdentifierRawValue)),
              let goal = getUserGoal(for: goalType.categoryId, goalType: goalType) else {
            return []
        }
        let unit = HKUnit(from: goalType.HKUnitString)

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: periodComponent, value: -pastNPeriods + 1, to: now)!
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: startDate)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)!

        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: DateComponents(day: 1)
        )

        return await withCheckedContinuation { continuation in
            query.initialResultsHandler = { query, results, error in
                guard let results = results else {
                    continuation.resume(returning: [])
                    return
                }
                
                var periodData: [GoalPeriodData] = []
                results.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                    let date = statistics.startDate
                    let actualValue = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
                    let percentage = (actualValue / goal) * 100
                    let goalReached = actualValue >= goal
                    let data = GoalPeriodData(date: date, goal: goal, actualValue: actualValue, percentage: percentage, goalReached: goalReached)
                    periodData.append(data)
                }

                continuation.resume(returning: periodData)
            }

            self.healthStore.execute(query)
        }
    }
}
