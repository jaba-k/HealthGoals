//
//  Item.swift
//  Health Goals
//
//  Created by Jaba Kochashvili on 2/17/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
