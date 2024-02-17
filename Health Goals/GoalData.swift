//
//  GoalData.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/17/24.
//

import Foundation
import SwiftUI

struct Category {
    let name: String
    let icon: String
    let color: Color
    let items: [QuantityType]
}

struct QuantityType {
    let name: String
    let unit: String
}

let categories: [Category] = [
    Category(name: "Activity", icon: "flame.fill", color: Color.orange, items: [
        QuantityType(name: "Active Energy", unit: "cal"),
        QuantityType(name: "Steps", unit: "steps"),
    ]),
    
    Category(name: "Body Measurements", icon: "figure.mixed.cardio", color: Color.purple, items: [
        QuantityType(name: "Weight", unit: "kg"),
        QuantityType(name: "Body Fat", unit: "%"),
    ]),
    
    Category(name: "Nutrition", icon: "leaf.fill", color: Color.green, items: [
        QuantityType(name: "Dietary Energy", unit: "Cal"),
        QuantityType(name: "Protein", unit: "g"),
    ]),
    
    Category(name: "Vital Signs", icon: "heart.fill", color: Color.red, items: [
        QuantityType(name: "Respiratory Rate", unit: "breaths/min"),
        QuantityType(name: "Resting Heart Rate", unit: "BPM"),
    ]),
]
