//
//  CreateNewGoal.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//

import SwiftUI
import Foundation

struct CreateNewGoal: View {
    var body: some View {
        List(categories, id: \.name) { category in
                           NavigationLink(destination: CategoryDetailView(category: category)) {
                               HStack {
                                   Image(systemName: category.icon)
                                       .foregroundColor(category.color)
                                   Text(category.name)
                               }
                           }
                       }
                       .navigationTitle("Create Goal")
    }
}

struct CategoryDetailView: View {
    let category: Category

    var body: some View {
        List(category.items, id: \.name) { item in
            HStack {
                Text(item.name)
                Spacer()
                Text(item.unit)
            }
        }
        .navigationTitle(category.name)
    }
}

#Preview {
    CreateNewGoal()
}
