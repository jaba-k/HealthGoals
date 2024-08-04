//
//  GoalData.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/17/24.
//
import Foundation
import SwiftUI
import HealthKit

public enum GoalFrequency: String, CaseIterable, Codable {
    case daily, weekly, monthly, continuous
}

public enum CategoryId: String, Codable {
    case activity = "activity"
    case bodyMeasurement = "body_measurement"
    case nutrition = "nutrition"
    case vitalSigns = "vital_signs"
}

public struct Category {
    public let id: CategoryId
    public let name: String
    public let icon: String
    public let color: Color
    public let goals: [GoalType]
    
    public init(id: CategoryId, name: String, icon: String, color: Color, goals: [GoalType]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.goals = goals
    }
}

public struct GoalType: Identifiable, Codable {
    public var id = UUID()
    public let name: String
    public let categoryId: CategoryId
    public let frequency: GoalFrequency
    public let HKQuantityTypeIdentifierRawValue: String
    public let HKUnitString: String
    
    public init(name: String, categoryId: CategoryId, frequency: GoalFrequency, HKQuantityTypeIdentifierRawValue: String, HKUnitString: String) {
        self.name = name
        self.categoryId = categoryId
        self.frequency = frequency
        self.HKQuantityTypeIdentifierRawValue = HKQuantityTypeIdentifierRawValue
        self.HKUnitString = HKUnitString
    }
}

public let categories: [Category] = [
    Category(id: .activity, name: "Activity", icon: "flame.fill", color: .orange, goals: [
        GoalType(name: "Steps", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.stepCount.rawValue, HKUnitString: HKUnit.count().unitString),
        GoalType(name: "Active Energy", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.activeEnergyBurned.rawValue, HKUnitString: HKUnit.largeCalorie().unitString),
        // Add additional goals if needed
    ]),
//    Category(id: .bodyMeasurement, name: "Body Measurements", icon: "figure.mixed.cardio", color: .purple, goals: [
//        GoalType(name: "Weight", categoryId: .bodyMeasurement, frequency: .continuous, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.bodyMass.rawValue, HKUnitString: HKUnit.gramUnit(with: .kilo).unitString),
//        GoalType(name: "Body Fat", categoryId: .bodyMeasurement, frequency: .continuous, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.bodyFatPercentage.rawValue, HKUnitString: HKUnit.percent().unitString),
//    ]),
    Category(id: .nutrition, name: "Nutrition", icon: "leaf.fill", color: .green, goals: [
        GoalType(name: "Dietary Energy", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.dietaryEnergyConsumed.rawValue, HKUnitString: HKUnit.largeCalorie().unitString),
        GoalType(name: "Protein", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.dietaryProtein.rawValue, HKUnitString: HKUnit.gram().unitString),
        GoalType(name: "Carbs", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.dietaryCarbohydrates.rawValue, HKUnitString: HKUnit.gram().unitString),
        GoalType(name: "Total Fat", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.dietaryFatTotal.rawValue, HKUnitString: HKUnit.gram().unitString),
    ]),
//    Category(id: .vitalSigns, name: "Vital Signs", icon: "heart.fill", color: .red, goals: [
//        GoalType(name: "Respiratory Rate", categoryId: .vitalSigns, frequency: .continuous, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.respiratoryRate.rawValue, HKUnitString: HKUnit.count().unitDivided(by: .minute()).unitString),
//        GoalType(name: "Resting Heart Rate", categoryId: .vitalSigns, frequency: .continuous, HKQuantityTypeIdentifierRawValue: HKQuantityTypeIdentifier.restingHeartRate.rawValue, HKUnitString: HKUnit.count().unitDivided(by: .minute()).unitString),
//    ]),
]

