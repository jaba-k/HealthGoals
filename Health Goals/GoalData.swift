//
//  GoalData.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/17/24.
//
import Foundation
import SwiftUI
import HealthKit

enum CategoryId: String {
    case activity = "activity"
    case bodyMeasurement = "body_measurement"
    case nutrition = "nutrition"
    case vitalSigns = "vital_signs"
}

struct Category {
    let id: CategoryId
    let name: String
    let icon: String
    let color: Color
    let goals: [GoalType]
}

struct GoalType: Identifiable {
    let id = UUID()
    let name: String
    let categoryId: CategoryId
    let frequency: GoalFrequency
    let HKQuantityTypeIdentifier: HKQuantityTypeIdentifier
    let HKUnit: HKUnit
}


let categories: [Category] = [
    Category(id: .activity, name: "Activity", icon: "flame.fill", color: .tomato, goals: [
        GoalType(name: "Steps", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifier: .stepCount, HKUnit: .count()),
        GoalType(name: "Active Energy", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifier: .activeEnergyBurned, HKUnit: .smallCalorie()),
//        GoalType(name: "Resting Energy", categoryId: .activity, frequency: .daily, HKQuantityTypeIdentifier: .basalEnergyBurned, HKUnit: .smallCalorie()),
    ]),
    
//    Category(id: .bodyMeasurement, name: "Body Measurements", icon: "figure.mixed.cardio", color: .purple, goals: [
//        GoalType(name: "Weight", categoryId: .bodyMeasurement, frequency: .continuous, HKQuantityTypeIdentifier: .bodyMass, HKUnit: .gramUnit(with: .kilo)),
//        GoalType(name: "Body Fat", categoryId: .bodyMeasurement, frequency: .continuous, HKQuantityTypeIdentifier: .bodyFatPercentage, HKUnit: .percent()),
//    ]),
    
    Category(id: .nutrition, name: "Nutrition", icon: "leaf.fill", color: .green, goals: [
        GoalType(name: "Dietary Energy", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifier: .dietaryEnergyConsumed, HKUnit: .largeCalorie()),
        GoalType(name: "Protein", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifier: .dietaryProtein, HKUnit: .gram()),
        GoalType(name: "Carbs", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifier: .dietaryCarbohydrates, HKUnit: .gram()),
        GoalType(name: "Total Fat", categoryId: .nutrition, frequency: .daily, HKQuantityTypeIdentifier: .dietaryFatTotal, HKUnit: .gram()),
    ]),
    
//    Category(id: .vitalSigns, name: "Vital Signs", icon: "heart.fill", color: .red, goals: [
//        GoalType(name: "Respiratory Rate", categoryId: .vitalSigns, frequency: .continuous, HKQuantityTypeIdentifier: .respiratoryRate, HKUnit: .count().unitDivided(by: .minute())),
//        GoalType(name: "Resting Heart Rate", categoryId: .vitalSigns, frequency: .continuous, HKQuantityTypeIdentifier: .restingHeartRate, HKUnit: .count().unitDivided(by: .minute())),
//    ]),
]
