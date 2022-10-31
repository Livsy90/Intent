//
//  Step.swift
//  Intent
//
//  Created by Livsy on 30.10.2022.
//

import Foundation

enum Step: String, CaseIterable {
    case fourHours = "Four hours"
    case threeHours = "Three hours"
    case twoHours = "Two hours"
    case hour = "Hour"
    case halfAnHour = "30 minutes"
    
    var calendar: (component: Calendar.Component, value: Int) {
        switch self {
        case .fourHours:
            return (.hour, 4)
        case .threeHours:
            return (.hour, 3)
        case .twoHours:
            return (.hour, 2)
        case .hour:
            return (.hour, 1)
        case .halfAnHour:
            return (.minute, 30)
        }
    }
}
