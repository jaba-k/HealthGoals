//
//  EmptyGoalsView.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/18/24.
//

import SwiftUI

struct EmptyMyGoalsView: View {
    var action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "plus.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Tap here to start")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding()
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            action()
        }
        .navigationTitle("My Goals")
    }
}

#Preview {
    EmptyMyGoalsView(action: {})
}
