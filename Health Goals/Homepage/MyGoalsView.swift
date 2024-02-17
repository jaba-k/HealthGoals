//
//  MyGoalsView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//

import SwiftUI

struct MyGoalsView: View {
    var action: () -> Void

    var body: some View {
        List {
         Text("Goals View Coming soon")
        }
        .listStyle(.plain)
        .navigationTitle("My Goals")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: action) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    MyGoalsView(action: {})
}
